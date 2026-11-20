"""Public CLI/HTTP tests using independent processes and real SQLite files."""
from contextlib import closing
import json
import os
from pathlib import Path
import runpy
import signal
import sqlite3
import subprocess
import sys
import tempfile
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "questionnaire.py"


class QuestionnaireTests(unittest.TestCase):
    def setUp(self):
        self.work = Path(tempfile.mkdtemp(prefix="questionnaire-", dir=os.environ.get("QUESTIONNAIRE_TEST_DIR")))
        self.form = self.work / "form.json"
        self.form.write_bytes((ROOT / "assets" / "example-form.json").read_bytes())
        self.state = self.work / "state.sqlite3"
        self.process = None
        self.start()

    def tearDown(self):
        self.stop()
        # Retain synthetic DB and logs for audit. Caller owns cleanup.

    def cli(self, *args):
        return subprocess.run([sys.executable, str(SCRIPT), *args, "--form", str(self.form), "--state", str(self.state)], capture_output=True, text=True, timeout=10)

    def start(self):
        self.process = subprocess.Popen([sys.executable, str(SCRIPT), "serve", "--form", str(self.form), "--state", str(self.state)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        # Startup is a single flushed JSON record. communicate has a timeout on exit.
        line = self.process.stdout.readline()
        if not line:
            out, err = self.process.communicate(timeout=10)
            self.fail("Runner did not start: " + out + err)
        info = json.loads(line)
        self.origin, fragment = info["url"].split("/#token=")
        self.token = fragment
        (self.work / "startup.json").write_text(line)

    def stop(self):
        if self.process is not None:
            self.process.send_signal(signal.SIGINT)
            out, err = self.process.communicate(timeout=15)
            self.assertEqual(self.process.returncode, 0, err)
            with (self.work / "runner.log").open("a") as log:
                log.write(out + err)
            self.process = None

    def request(self, path="/api/state", body=None, headers=None, raw=None):
        hdr = {"X-Questionnaire-Token": self.token}
        if body is not None or raw is not None:
            hdr.update({"Origin": self.origin, "Content-Type": "application/json"})
        hdr.update(headers or {})
        data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
        req = Request(self.origin + path, data=data, headers=hdr)
        try:
            with urlopen(req, timeout=10) as response:
                return response.status, response.read(), response.headers
        except HTTPError as error:
            with error:
                return error.code, error.read(), error.headers

    def save(self, mutation="m1", revision=0, value="investigate", notes="", qid="sample-choice"):
        body = {"question_id": qid, "value": value, "notes": notes, "expected_revision": revision, "mutation_id": mutation}
        status, raw, _ = self.request("/api/answer", body)
        return status, json.loads(raw), body

    def export(self):
        result = self.cli("export")
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def test_independent_restart_unicode_notes_timestamps_and_undecided(self):
        status, answer, _ = self.save(notes="Line one\n雪 🧭 e\u0301\n' <script>")
        self.assertEqual(status, 200)
        before = self.export()
        self.assertEqual(before["answers"][1]["value"], None)
        self.assertEqual(before["answers"][1]["updated_at"], None)
        self.stop()
        self.assertEqual(before, self.export())
        self.start()
        self.assertEqual(before, self.export())
        self.assertEqual(before["answers"][0], answer)
        status, raw, _ = self.request()
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(raw), before)

    def test_abrupt_process_death_after_ack_and_lost_receipt_retry(self):
        status, saved, body = self.save(notes="acknowledged before forced stop")
        self.assertEqual(status, 200)
        self.process.kill()
        out, err = self.process.communicate(timeout=10)
        (self.work / "abrupt-stop.log").write_text(out + err)
        self.process = None
        self.assertEqual(self.export()["answers"][0], saved)
        old_token = self.token
        self.start()
        self.assertNotEqual(self.token, old_token)
        self.assertEqual(self.request(headers={"X-Questionnaire-Token": old_token})[0], 403)
        status, raw, _ = self.request("/api/answer", body)
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(raw), saved)

    def test_duplicate_receipt_and_stale_tab(self):
        status, first, body = self.save()
        self.assertEqual(status, 200)
        status, newer, _ = self.save("m2", 1, "defer", "newer tab")
        self.assertEqual(status, 200)
        self.stop()
        self.start()
        status, raw, _ = self.request("/api/answer", body)
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(raw), first)  # Lost acknowledgment replay.
        self.assertEqual(self.export()["answers"][0], newer)
        status, result, _ = self.save("stale", 0)
        self.assertEqual(status, 409)
        self.assertEqual(result["current"], newer)
        status, _, _ = self.save("m1", 2, "defer")
        self.assertEqual(status, 400)  # Mutation ID cannot acquire a new meaning.

    def test_hot_journal_export_explains_recovery_and_restart_preserves_ack(self):
        self.assertEqual(self.save(notes="acknowledged before interrupted write")[0], 200)
        before = self.export()
        self.stop()
        crash = subprocess.run([sys.executable, "-c", """
import os, sqlite3, sys
db = sqlite3.connect(sys.argv[1])
db.execute('PRAGMA cache_size=1')
db.execute('BEGIN IMMEDIATE')
db.execute("UPDATE answers SET notes='uncommitted overwrite'")
for i in range(64):
    db.execute('INSERT INTO mutations VALUES (?, ?, ?)', ('crash-'+str(i), 'x'*16384, '{}'))
os._exit(0)
""", str(self.state)], capture_output=True, timeout=10)
        self.assertEqual(crash.returncode, 0, crash.stderr)
        journal = Path(str(self.state) + "-journal")
        self.assertTrue(journal.exists())
        original = self.state.read_bytes()
        original_journal = journal.read_bytes()
        (self.work / "before-recovery.sqlite3").write_bytes(original)
        (self.work / "before-recovery.sqlite3-journal").write_bytes(original_journal)
        result = self.cli("export")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("restart", result.stderr.lower())
        self.assertIn("journal", result.stderr.lower())
        self.assertEqual(self.state.read_bytes(), original)
        self.assertEqual(journal.read_bytes(), original_journal)
        self.start()  # Normal writable startup lets SQLite roll back the interrupted write.
        self.assertEqual(self.export(), before)
        self.stop()
        self.assertEqual(self.export(), before)

    def test_latest_edit_and_export(self):
        for revision in range(8):
            status, latest, _ = self.save("edit-" + str(revision), revision, "defer", "draft " + str(revision))
            self.assertEqual(status, 200)
        self.assertEqual(self.export()["answers"][0], latest)
        status, raw, _ = self.request("/api/export")
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(raw), self.export())

    def test_failed_write_does_not_ack_or_partial_commit(self):
        before = self.export()
        with closing(sqlite3.connect(self.state)) as db, db:
            db.execute("CREATE TRIGGER deny_receipt BEFORE INSERT ON mutations BEGIN SELECT RAISE(ABORT, 'synthetic failure'); END")
        status, _, body = self.save(notes="must not partially commit")
        self.assertEqual(status, 503)
        self.assertEqual(self.export(), before)
        with closing(sqlite3.connect(self.state)) as db, db:
            db.execute("DROP TRIGGER deny_receipt")
        self.assertEqual(self.request("/api/answer", body)[0], 200)
        self.assertEqual(self.export()["answers"][0]["revision"], 1)

    def test_corrupt_and_mismatched_state_never_reset(self):
        self.save()
        self.stop()
        original = self.state.read_bytes()
        form = json.loads(self.form.read_text())
        form["questions"][0]["title"] = "Changed meaning"
        self.form.write_text(json.dumps(form))
        self.assertNotEqual(self.cli("serve").returncode, 0)
        self.assertEqual(self.state.read_bytes(), original)
        self.form.write_bytes((ROOT / "assets" / "example-form.json").read_bytes())
        self.state.write_bytes(b"corrupt synthetic database")
        self.assertNotEqual(self.cli("export").returncode, 0)
        self.assertNotEqual(self.cli("serve").returncode, 0)
        self.assertEqual(self.state.read_bytes(), b"corrupt synthetic database")

    def test_missing_export_and_empty_existing_db_fail(self):
        self.stop()
        alternate = self.work / "missing.sqlite3"
        result = subprocess.run([sys.executable, str(SCRIPT), "export", "--form", str(self.form), "--state", str(alternate)], capture_output=True, timeout=10)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(alternate.exists())
        self.state.write_bytes(b"")
        self.assertNotEqual(self.cli("serve").returncode, 0)
        self.assertEqual(self.state.read_bytes(), b"")

    def test_rejects_unrelated_wal_database_without_mutating_it(self):
        self.stop()
        self.state = self.work / "unrelated.sqlite3"
        with closing(sqlite3.connect(self.state)) as db, db:
            db.execute("PRAGMA journal_mode=WAL")
            db.execute("CREATE TABLE unrelated (value TEXT)")
            db.execute("INSERT INTO unrelated VALUES ('preserve me')")
        original = self.state.read_bytes()
        self.assertNotEqual(self.cli("serve").returncode, 0)
        self.assertEqual(self.state.read_bytes(), original)
        with closing(sqlite3.connect(self.state)) as db:
            self.assertEqual(db.execute("PRAGMA journal_mode").fetchone()[0], "wal")

    def test_routes_auth_origin_and_headers(self):
        for headers in ({"X-Questionnaire-Token": "wrong"}, {"Host": "evil.example"}, {"Origin": "null"}, {"Origin": "https://unrelated.example"}):
            self.assertEqual(self.request(headers=headers)[0], 403)
        _, _, body = self.save()
        for origin in ("null", "https://unrelated.example", ""):
            self.assertEqual(self.request("/api/answer", body, {"Origin": origin})[0], 403)
        self.assertEqual(self.request("/../../etc/passwd")[0], 404)
        self.assertEqual(self.request("/api/state?path=/etc/passwd")[0], 404)
        self.assertEqual(self.request("/api/nope", body)[0], 404)
        status, _, headers = self.request("/")
        self.assertEqual(status, 200)
        self.assertEqual(headers["Referrer-Policy"], "no-referrer")
        self.assertNotIn("Access-Control-Allow-Origin", headers)
        self.assertIn("frame-ancestors 'none'", headers["Content-Security-Policy"])

    def test_browser_default_port_headers(self):
        self.stop()
        module = runpy.run_path(str(SCRIPT))

        class DefaultPortServer(module["Server"]):
            def server_bind(self):
                super().server_bind()
                # Exercise HTTP default-port metadata/headers on a real ephemeral
                # socket; CI must not require access to privileged or occupied :80.
                self.server_port = 80

        store = module["Store"](self.state, module["load_form"](self.form))
        server = DefaultPortServer(store, 0)
        thread = threading.Thread(target=server.serve_forever)
        thread.start()
        try:
            self.origin = "http://127.0.0.1:" + str(server.server_address[1])
            self.token = server.token
            headers = {"Host": "127.0.0.1", "Origin": "http://127.0.0.1"}
            self.assertEqual(self.request(headers=headers)[0], 200)
            body = {"question_id": "sample-choice", "value": "investigate", "notes": "default-port save", "expected_revision": 0, "mutation_id": "default-port"}
            self.assertEqual(self.request("/api/answer", body, headers)[0], 200)
            self.assertEqual(self.export()["answers"][0]["notes"], "default-port save")
            self.assertEqual(self.request(headers=dict(headers, Origin="http://127.0.0.1:81"))[0], 403)
        finally:
            server.shutdown()
            thread.join(timeout=5)
            server.server_close()
            store.close()

    def test_ui_saves_after_wall_clock_moves_backward(self):
        result = subprocess.run(["node", str(ROOT / "tests" / "ui_clock_probe.cjs"), self.origin, self.token], capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.export()["answers"][0]["notes"], "Draft before clock correction")

    def test_bounded_validated_input(self):
        before = self.export()
        base = {"question_id": "sample-choice", "value": "investigate", "notes": "", "expected_revision": 0, "mutation_id": "validate"}
        for key, value in (("value", "unknown"), ("notes", "x" * 20001), ("expected_revision", True), ("question_id", []), ("mutation_id", "../bad")):
            body = dict(base, **{key: value})
            self.assertEqual(self.request("/api/answer", body)[0], 400)
        for raw in (b"[1]", b"null", b"{bad", b"x" * 262145):
            self.assertEqual(self.request("/api/answer", raw=raw)[0], 400)
        self.assertEqual(self.request("/api/answer", base, {"Content-Type": "text/plain"})[0], 415)
        self.assertEqual(self.export(), before)

    def test_form_validation_rejects_unsafe_links(self):
        self.stop()
        original = self.form.read_text()
        original_state = self.state.read_bytes()
        self.assertEqual(self.cli("export").returncode, 0)  # Valid HTTPS link.
        for unsafe in ("javascript:alert(1)", "https://user:pass@example.com", "https://example.com/\nunsafe"):
            with self.subTest(url=unsafe):
                form = json.loads(original)
                form["questions"][0]["links"][0]["url"] = unsafe
                self.form.write_text(json.dumps(form))
                result = self.cli("export")
                self.assertEqual(result.returncode, 1)
                self.assertEqual(result.stderr, "questionnaire: Links require absolute HTTP(S) URLs without credentials\n")
                self.assertEqual(result.stdout, "")
                self.assertEqual(self.state.read_bytes(), original_state)

    def test_form_validation_rejects_duplicate_question_ids(self):
        self.stop()
        original_state = self.state.read_bytes()
        self.assertEqual(self.cli("export").returncode, 0)  # Distinct stable IDs.
        form = json.loads(self.form.read_text())
        form["questions"].append(form["questions"][0])
        self.form.write_text(json.dumps(form))
        result = self.cli("export")
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stderr, "questionnaire: Duplicate question ID\n")
        self.assertEqual(result.stdout, "")
        self.assertEqual(self.state.read_bytes(), original_state)

    def test_export_does_not_overwrite(self):
        target = self.work / "backup.json"
        self.assertEqual(self.cli("export", "--output", str(target)).returncode, 0)
        before = target.read_bytes()
        self.save()
        self.assertNotEqual(self.cli("export", "--output", str(target)).returncode, 0)
        self.assertEqual(target.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
