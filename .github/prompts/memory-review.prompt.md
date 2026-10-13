---
description: Review memory — merge duplicates, check for stale facts, tighten the index
---

Review memory following the "Memory across chats" protocol in
`.github/copilot-instructions.md`.

1. Read every file in `.copilot-memory/` and the "Index".
2. Find problems:
   - duplicates and entries on the same topic → merge into one;
   - stale facts: check referenced files, functions, flags, and branches in the
     repository; verify "not committed" / "not deployed" against `git log` and `git status`;
   - relative dates ("yesterday", "last week") → absolute if the date can be
     recovered, otherwise mark "date unknown";
   - files missing from the index, and index lines with no file;
   - index lines longer than ~150 characters or containing content instead of a pointer;
   - secrets (passwords, tokens, keys) → remove immediately;
   - any text not in English → translate to English (keep code, commands, paths,
     error messages, UI labels, and proper names as they are).
3. Apply merges, date fixes, and index fixes right away.
4. **Deleting entries** — first show the list (file + why delete) and wait for
   confirmation.
5. Finish with a short report: what was merged, what was fixed, what you propose deleting.
