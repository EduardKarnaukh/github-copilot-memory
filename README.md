# Claude Code-style memory for the GitHub Copilot app

Global, per-project, file-based memory that works like Claude Code's auto memory.

## How it maps to Claude Code

| | Claude Code | GitHub Copilot app (this kit) |
|---|---|---|
| Storage | `~/.claude/projects/<project>/memory/` | `~/.copilot-memory/projects/<project-key>/` (`%USERPROFILE%` on Windows) |
| Project key | project path, `/` → `-` | main repo root, every non-alphanumeric char → `-`; worktrees share their repo's memory |
| Index | `MEMORY.md`, injected into every session by the harness | `MEMORY.md`, read by the agent at session start (the app has no auto-injection) |
| Rules | memory section of the system prompt | `app-instructions.md` → app Settings → Sessions → **App instructions** (global, all sessions) |
| Entries | one fact per file, frontmatter, `user`/`feedback`/`project`/`reference` | identical |
| Cleanup | `/consolidate-memory` skill | `consolidate-memory` skill |

Additions on top of Claude Code's rules: memory is written strictly in English, and
secrets are never stored.

## Install (Windows)

```powershell
git clone git@github.com:EduardKarnaukh/github-copilot-memory.git
cd github-copilot-memory
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The script:
1. creates `%USERPROFILE%\.copilot-memory\projects\`;
2. installs the `remember` and `consolidate-memory` skills into `%USERPROFILE%\.copilot\skills\`;
3. copies `app-instructions.md` to the clipboard.

Then, in the GitHub Copilot app: **Settings → Sessions → Instructions → App
instructions**, paste, save. If the field already has text, append below it.

Manual install: create the folder, copy `skills\*` into `%USERPROFILE%\.copilot\skills\`,
paste `app-instructions.md` into App instructions.

## Use

- Just work. The agent reads the project's `MEMORY.md` at session start and saves
  memories on its own when something qualifies.
- "remember …" / "forget …", or the `remember` skill to capture a session.
- `consolidate-memory` skill to merge duplicates, fix stale facts, prune the index.

## Verify

1. In a project session: `remember that we deploy only on Tuesdays`. A file should
   appear under `%USERPROFILE%\.copilot-memory\projects\<project-key>\` plus a line in
   its `MEMORY.md`.
2. New session, same project: `when do we deploy?` — it should answer from memory.
3. New session, another project: it should not know.

## Differences from Claude Code that remain

- **No auto-injection.** Claude Code's harness puts `MEMORY.md` into context before
  the model sees anything. Here the agent reads it itself because the instructions
  tell it to; a model can occasionally skip that. Saying "check memory" fixes it.
- **File access outside the project.** Memory lives in your home folder, so the app
  may ask for permission the first time the agent reads or writes there. Allow it.
- **Unverified paths.** The personal skills folder `~/.copilot/skills` and the
  PowerShell snippet were not tested inside the app. If the skills don't show up,
  add them through the app's skills settings instead.
