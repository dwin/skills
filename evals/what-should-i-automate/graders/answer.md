---
type: llm
weight: 2
---

PASS if, before reading any session, the response asks the user to set the scope and covers all three parts: which sessions (this tool only, or every agent tool on the machine), how far back (offering a default such as the last 30 days), and how deep (a lighter sorting pass by default, or a deeper reading). It may also say where the private working files will be kept, and it may state the defaults it will use if the user just says go.
FAIL if it reports patterns, counts, or recommendations as if it had read sessions; if it starts without asking about scope; or if its question leaves out any of the three parts.
