# Memory across chats

You remember nothing between chats except what is written in the `.copilot-memory/`
folder at the repository root. This section and the memory index at its end live in
`.github/copilot-instructions.md`, which is loaded into every chat automatically.
The entries themselves are separate files; open them yourself when they are
relevant to the task.

This only works in **Agent** mode (Ask/Edit modes have no file tools).

## 1. Reading — at the start of every task

- Scan the "Index" at the bottom. If a line is even plausibly relevant to the task,
  open that file and read it in full BEFORE acting.
- Memory is a snapshot from the moment it was written. If an entry names a file,
  function, flag, branch, server, or a state ("not committed", "not deployed"),
  verify it is still true before relying on it. If it is stale, fix or delete the entry.
- If an entry contradicts what the user says now, the user is right. Update the entry.

## 2. What to save

One test: **it cannot be recovered from the code or git history, and in a future
chat it will save time or prevent a mistake.**

Four types:

| type | What it is | Example |
|---|---|---|
| `user` | Who the user is: role, expertise, how they like to work | "Senior backend dev, PHP/Symfony; explain frontend in detail, keep backend brief" |
| `feedback` | A correction or a confirmed approach: "do it this way / don't do that" | "Commit messages in English, even though the repo history is in Russian" |
| `project` | State of work, decisions and their reasons, gotchas, constraints | "July 2026 migrations were removed on purpose; don't restore them — deploy fails with 'already exists'" |
| `reference` | Where things live outside the repo: servers, dashboards, tickets, docs | "Prod API is 10.0.0.5 behind Traefik, logs in /var/log/app" |

Especially valuable:
- **Traps already stepped on** — anything that already led to a wrong conclusion
  or a lost hour. Record the symptom, the cause, and how to recognize it.
- **A decision plus its reason.** A rule without a reason gets broken with the best
  intentions.
- **Unfinished work:** not committed, not deployed, waiting on something — with a date.
- **User corrections** — immediately, with the reason, so you apply them to similar
  cases, not just the literal one.

## 3. What NOT to save

- Code structure, architecture, APIs — these can be read from the repository.
- Change history and "what we fixed today" — that is in git.
- Details that only matter in the current chat.
- Anything that can be checked with a single command.
- **Secrets: passwords, tokens, keys, private customer data — never.**
  You may record WHERE a secret lives ("token in 1Password, item X"), never the secret itself.

If the user says "remember X" and X is already evident from the code, ask what was
non-obvious about it and save that instead.

## 4. When to save

Nothing external will remind you. So:

- Immediately, without waiting for the task to finish:
  - the user corrected you or confirmed a non-obvious approach → `feedback`;
  - the user said "remember …" / "forget …".
- **Before your final answer** on any task longer than a couple of steps, run the
  checklist: was there a correction? a trap that cost time? a decision with a reason?
  anything left uncommitted / undeployed? did you learn something about the user?
- If you saved something, add one line at the end of your answer: `Remembered: <what>`.
- Don't save for the sake of saving. A pass with nothing to record is normal.

## 5. Entry format

File `.copilot-memory/<type>_<slug>.md`, one fact per file:

```markdown
---
name: <kebab-case-slug>
description: <one line — when this entry is needed; used to decide whether to open the file>
type: user | feedback | project | reference
---

<the fact — short and concrete: commands, paths, symptoms>

**Why:** <the reason / what happened>
**How to apply:** <what to do next time>
```

- **Write everything in memory strictly in English** — entries, descriptions, and
  index lines — regardless of the language the user writes in. Translate as you save.
  Keep only literal values in their original form: code, commands, paths, error
  messages, UI labels, and proper names.
- `Why` and `How to apply` are required for `feedback` and `project`.
- Absolute dates only: not "yesterday" but "2026-10-12".
- Refer to related entries as `[[slug]]`. A link to an entry that doesn't exist yet
  is fine — it marks something worth writing later.

## 6. Index and hygiene

- After creating, changing, or deleting an entry, update the "Index" below, between
  the markers. One line per entry, no longer than ~150 characters:
  `- [Title](.copilot-memory/<file>.md) — hook`
- The index holds pointers only, never content.
- Before creating an entry, check whether a file on that topic already exists. If it
  does, update it instead of creating a second one next to it.
- If an entry turns out to be wrong, delete the file and its index line. Don't write
  a new "SUPERSEDES the previous one" entry alongside — both will mislead.
- When working with memory, touch nothing outside `.copilot-memory/` and the "Index"
  block of `.github/copilot-instructions.md` (between the `memory-index` markers).
  Never edit the rest of that file as part of memory work.

## Index

<!-- memory-index:start -->
_(empty for now)_
<!-- memory-index:end -->
