---
name: consolidate-memory
description: Reflective pass over the project's memory files — merge duplicates, fix stale facts, prune the index. Use when the user asks to clean up, review, or consolidate memory.
---

Follow the Memory rules from the app instructions.

1. Resolve the memory directory for the current project. Read `MEMORY.md` and every
   memory file in it.
2. Merge duplicates and memories on the same topic into one file.
3. Check for stale facts: verify files, functions, flags, and branches the memories
   name still exist; check "not committed" / "not deployed" claims against
   `git log` and `git status`. Fix or delete what is no longer true.
4. Convert any relative dates to absolute ones; if a date cannot be recovered, say so
   in the memory.
5. Translate any non-English text to English (keep code, paths, error messages, and
   UI labels verbatim). Remove any secrets.
6. Prune the index: one short line per memory, no content, no lines for missing
   files, and every memory file listed.
7. Report what you merged, fixed, and deleted.
