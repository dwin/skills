#!/usr/bin/env python3
"""Loopback questionnaire server and offline committed-answer export. Python 3.9+."""
import argparse
import hmac
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import re
import secrets
import sqlite3
import sys
import threading
from datetime import datetime, timezone
from urllib.parse import urlsplit

MAX_BODY = 262144
MAX_FORM = 2097152
ASSETS = Path(__file__).resolve().parent.parent / "assets"


class Invalid(ValueError):
    pass


class Conflict(Exception):
    def __init__(self, answer):
        self.answer = answer


def encode(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def fields(obj, required, optional=()):
    if not isinstance(obj, dict) or not set(required) <= obj.keys() or obj.keys() - set(required) - set(optional):
        raise Invalid("Missing or unknown fields")


def string(value, limit=20000, nonempty=False):
    if not isinstance(value, str) or len(value) > limit or (nonempty and not value.strip()):
        raise Invalid("Invalid text field")
    # SQLite and UTF-8 must accept the exact supplied text, including notes.
    try:
        value.encode("utf-8")
    except UnicodeError as exc:
        raise Invalid("Invalid Unicode") from exc
    return value


def identifier(value):
    if not isinstance(value, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,127}", value):
        raise Invalid("Invalid stable ID")
    return value


def load_form(path):
    with Path(path).open("rb") as source:
        raw = source.read(MAX_FORM + 1)
    if len(raw) > MAX_FORM:
        raise Invalid("Form exceeds 2 MiB")
    form = json.loads(raw)
    fields(form, ("schema_version", "form_id", "title", "questions"), ("description",))
    if type(form["schema_version"]) is not int or form["schema_version"] != 1:
        raise Invalid("Unsupported schema_version")
    identifier(form["form_id"])
    string(form["title"], 500, True)
    string(form.get("description", ""))
    questions = form["questions"]
    if not isinstance(questions, list) or not 1 <= len(questions) <= 1000:
        raise Invalid("Expected 1 to 1000 questions")
    ids = set()
    for q in questions:
        fields(q, ("id", "title", "type"), ("description", "links", "options"))
        identifier(q["id"])
        if q["id"] in ids:
            raise Invalid("Duplicate question ID")
        ids.add(q["id"])
        string(q["title"], 500, True)
        string(q.get("description", ""))
        links = q.get("links", [])
        if not isinstance(links, list) or len(links) > 20:
            raise Invalid("Too many links")
        for link in links:
            fields(link, ("label", "url"))
            string(link["label"], 500, True)
            url = string(link["url"], 2048, True)
            parsed = urlsplit(url)
            _ = parsed.port  # Reject malformed/out-of-range ports.
            if (parsed.scheme not in ("http", "https") or not parsed.hostname
                    or parsed.username is not None or parsed.password is not None
                    or any(c.isspace() or ord(c) < 32 for c in url) or "\\" in url):
                raise Invalid("Links require absolute HTTP(S) URLs without credentials")
        if q["type"] == "choice":
            opts = q.get("options")
            if not isinstance(opts, list) or not 1 <= len(opts) <= 100:
                raise Invalid("Choice requires 1 to 100 options")
            values = set()
            for opt in opts:
                fields(opt, ("value", "label"))
                string(opt["value"], 500, True)
                string(opt["label"], 500, True)
                if opt["value"] in values:
                    raise Invalid("Duplicate option value")
                values.add(opt["value"])
        elif q["type"] != "text" or "options" in q:
            raise Invalid("Expected choice or text; text cannot have options")
    return form


class Store:
    def __init__(self, path, form, readonly=False):
        self.form = form
        self.questions = {q["id"]: q for q in form["questions"]}
        self.lock = threading.RLock()
        path = Path(path).resolve()
        self.path = path
        created = False
        if not readonly:
            try:
                fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
            except FileExistsError:
                pass
            else:
                os.close(fd)
                created = True
        self.db = sqlite3.connect(path.as_uri() + ("?mode=ro" if readonly else "?mode=rw"),
                                  uri=True, timeout=5, check_same_thread=False)
        self.db.row_factory = sqlite3.Row
        try:
            self.db.execute("PRAGMA busy_timeout=5000")
            if created:
                with self.db:
                    self.db.execute("CREATE TABLE metadata (spec TEXT NOT NULL)")
                    self.db.execute("INSERT INTO metadata VALUES (?)", (encode(form),))
                    self.db.execute("CREATE TABLE answers (id TEXT PRIMARY KEY, value TEXT, notes TEXT NOT NULL, updated_at TEXT, revision INTEGER NOT NULL)")
                    self.db.executemany("INSERT INTO answers VALUES (?, NULL, '', NULL, 0)",
                                        ((qid,) for qid in self.questions))
                    self.db.execute("CREATE TABLE mutations (id TEXT PRIMARY KEY, payload TEXT NOT NULL, result TEXT NOT NULL)")
                    self.db.execute("PRAGMA user_version=1")
            if self.db.execute("PRAGMA quick_check").fetchone()[0] != "ok":
                raise Invalid("State integrity check failed")
            if self.db.execute("PRAGMA user_version").fetchone()[0] != 1:
                raise Invalid("Unsupported state version; refusing reset")
            specs = self.db.execute("SELECT spec FROM metadata").fetchall()
            if len(specs) != 1 or specs[0][0] != encode(form):
                raise Invalid("Form differs from stored specification; use original form or a new state path")
            if {r[0] for r in self.db.execute("SELECT id FROM answers")} != set(self.questions):
                raise Invalid("State question IDs differ; refusing reset")
            # Validate existing state before changing persistent database settings.
            if not readonly:
                self.db.execute("PRAGMA journal_mode=DELETE")
                self.db.execute("PRAGMA synchronous=FULL")
        except Exception:
            self.db.close()
            raise

    def close(self):
        self.db.close()

    def answer(self, qid):
        row = self.db.execute("SELECT * FROM answers WHERE id=?", (qid,)).fetchone()
        return dict(row)

    def export(self):
        with self.lock, self.db:
            # One SELECT snapshot includes all answers; no per-question torn reads.
            rows = {r["id"]: dict(r) for r in self.db.execute("SELECT * FROM answers")}
            return {"form": self.form, "answers": [rows[qid] for qid in self.questions]}

    def save(self, body):
        fields(body, ("question_id", "value", "notes", "expected_revision", "mutation_id"))
        qid = body["question_id"]
        if not isinstance(qid, str) or qid not in self.questions:
            raise Invalid("Unknown question_id")
        identifier(body["mutation_id"])
        if type(body["expected_revision"]) is not int or not 0 <= body["expected_revision"] < 2**53:
            raise Invalid("Invalid expected_revision")
        string(body["notes"])
        value = body["value"]
        if value is not None:
            string(value)
            q = self.questions[qid]
            if q["type"] == "choice" and value not in {o["value"] for o in q["options"]}:
                raise Invalid("Unknown choice value")
        payload = encode(body)
        with self.lock:
            try:
                self.db.execute("BEGIN IMMEDIATE")
                prior = self.db.execute("SELECT payload, result FROM mutations WHERE id=?", (body["mutation_id"],)).fetchone()
                if prior:
                    if prior[0] != payload:
                        raise Invalid("Mutation ID already used with different payload")
                    result = json.loads(prior[1])
                else:
                    current = self.answer(qid)
                    if current["revision"] != body["expected_revision"]:
                        raise Conflict(current)
                    stamp = datetime.now(timezone.utc).isoformat(timespec="microseconds")
                    self.db.execute("UPDATE answers SET value=?, notes=?, updated_at=?, revision=revision+1 WHERE id=?",
                                    (value, body["notes"], stamp, qid))
                    result = self.answer(qid)
                    self.db.execute("INSERT INTO mutations VALUES (?, ?, ?)", (body["mutation_id"], payload, encode(result)))
                self.db.commit()  # Acknowledge only after durable commit, including mutation receipt.
                return result
            except Exception:
                self.db.rollback()
                raise


class Server(ThreadingHTTPServer):
    daemon_threads = False
    block_on_close = True

    def __init__(self, store, port):
        self.store = store
        self.token = secrets.token_urlsafe(32)
        super().__init__(("127.0.0.1", port), Handler)
        # Browsers omit the default HTTP port in serialized Host/Origin values.
        self.origin = "http://127.0.0.1" + ("" if self.server_port == 80 else ":" + str(self.server_port))


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_args):
        pass  # No capability or answer logs.

    def setup(self):
        super().setup()
        self.connection.settimeout(10)

    def reply(self, code, content, kind="application/json; charset=utf-8"):
        data = content if isinstance(content, bytes) else encode(content).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", kind)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Content-Security-Policy", "default-src 'none'; script-src 'self'; style-src 'self'; connect-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'")
        self.end_headers()
        self.wfile.write(data)

    def allowed(self, write=False):
        if self.headers.get("Host") != self.server.origin.removeprefix("http://"):
            self.reply(403, {"error": "Invalid Host"})
            return False
        origin = self.headers.get("Origin")
        if (write and origin != self.server.origin) or (origin is not None and origin != self.server.origin):
            self.reply(403, {"error": "Invalid Origin; open the loopback URL in a browser"})
            return False
        if self.path.startswith("/api/") and not hmac.compare_digest(self.headers.get("X-Questionnaire-Token", "").encode("utf-8"), self.server.token.encode("ascii")):
            self.reply(403, {"error": "Missing or invalid capability; reopen the current startup URL"})
            return False
        return True

    def do_GET(self):
        if not self.allowed():
            return
        if self.path in ("/api/state", "/api/export"):
            try:
                self.reply(200, self.server.store.export())
            except (sqlite3.Error, OSError):
                self.reply(503, {"error": "State read failed; preserve drafts and check runner"})
        elif self.path in ("/", "/app.js", "/style.css"):
            name, kind = {"/": ("questionnaire.html", "text/html; charset=utf-8"),
                          "/app.js": ("questionnaire.js", "text/javascript; charset=utf-8"),
                          "/style.css": ("questionnaire.css", "text/css; charset=utf-8")}[self.path]
            self.reply(200, (ASSETS / name).read_bytes(), kind)
        else:
            self.reply(404, {"error": "Unknown route"})

    def do_POST(self):
        if not self.allowed(write=True):
            return
        if self.path != "/api/answer":
            self.reply(404, {"error": "Unknown route"})
            return
        if self.headers.get("Transfer-Encoding") or self.headers.get_content_type() != "application/json":
            self.reply(415, {"error": "Use bounded application/json"})
            return
        try:
            length = int(self.headers.get("Content-Length", "-1"))
            if not 0 < length <= MAX_BODY:
                raise Invalid("Body must be 1 to 262144 bytes")
            raw = self.rfile.read(length)
            if len(raw) != length:
                raise Invalid("Incomplete body")
            body = json.loads(raw)
            self.reply(200, self.server.store.save(body))
        except Conflict as exc:
            self.reply(409, {"error": "Conflict: another tab changed this answer", "current": exc.answer})
        except (ValueError, UnicodeError) as exc:
            self.reply(400, {"error": str(exc)})
        except (sqlite3.Error, OSError):
            self.reply(503, {"error": "Save failed; draft retained in this tab. Check disk/state and retry"})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("serve", "export"):
        cmd = sub.add_parser(name)
        cmd.add_argument("--form", required=True)
        cmd.add_argument("--state", required=True)
        if name == "serve":
            cmd.add_argument("--port", type=int, default=0)
        else:
            cmd.add_argument("--output")
    args = parser.parse_args()
    try:
        form = load_form(args.form)
        store = Store(args.state, form, readonly=args.command == "export")
        try:
            if args.command == "export":
                output = json.dumps(store.export(), ensure_ascii=False, indent=2) + "\n"
                if args.output:
                    # Do not overwrite an existing backup or the database/form by accident.
                    with open(args.output, "x", encoding="utf-8") as target:
                        target.write(output)
                else:
                    sys.stdout.write(output)
            else:
                if not 0 <= args.port <= 65535:
                    raise Invalid("Port must be 0 to 65535")
                server = Server(store, args.port)
                print(encode({"url": server.origin + "/#token=" + server.token,
                              "port": server.server_port, "state": str(store.path)}), flush=True)
                print("Keep this process available while answering. Ctrl+C stops it; committed state persists.", file=sys.stderr, flush=True)
                try:
                    server.serve_forever()
                except KeyboardInterrupt:
                    pass
                finally:
                    server.server_close()
        finally:
            store.close()
    except (OSError, ValueError, sqlite3.Error) as exc:
        print("questionnaire: " + str(exc), file=sys.stderr)
        if (args.command == "export" and isinstance(exc, sqlite3.Error)
                and Path(str(Path(args.state).resolve()) + "-journal").exists()):
            print("A rollback journal is present. If the runner crashed, preserve the database and "
                  "its -journal file together while stopped, restart serve with the same form/state "
                  "to let SQLite recover, stop it normally, then retry export. Do not delete the journal.",
                  file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
