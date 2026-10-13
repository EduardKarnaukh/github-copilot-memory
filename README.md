# Memory for GitHub Copilot

A port of Claude Code's memory scheme to Copilot: one file per entry, plus an index
that is injected into every request.

## How it works

Claude Code's memory rests on three things. In Copilot each is replaced:

| What's needed | Claude Code | Copilot (this kit) |
|---|---|---|
| Rules + index in every session | the harness injects them | written directly into `.github/copilot-instructions.md`, which Copilot attaches to every request on its own — no model action involved |
| Entries | files in `~/.claude/projects/…/memory/` | files in `.copilot-memory/` |
| A way to write | Write/Edit tools | **Agent** mode can create and edit files in the workspace |

Only the text *inside* `copilot-instructions.md` is guaranteed to be loaded. Files
it merely points to are read only if the model decides to, which is why the protocol
and the index live there rather than in a separate file.

GitHub also has its own "Copilot Memory", but on corporate accounts it is usually
turned off by organization policy. This kit doesn't depend on policies: it's just files.

## Install

```bash
./install.sh /path/to/work/repo
```

- No `.github/copilot-instructions.md` yet → it is created and kept out of git.
- The file already exists (e.g. team rules) → the memory block is appended between
  `<!-- copilot-memory:start/end -->` markers; the rest of the file is untouched.
  If the file is tracked by git, the installer prints a `git update-index --skip-worktree`
  command that keeps your memory block out of commits.
- Re-running upgrades the protocol text and keeps the accumulated index.
- `--commit` makes memory shared with the team (secrets are then even more off-limits).

Files:
- `memory-protocol.md` — the protocol template that goes into `copilot-instructions.md`.
- `.github/prompts/` — the `/remember` and `/memory-review` commands.

## Usage

- Chat in **Agent** mode. In Ask/Edit the agent cannot write files.
- `/remember` — save what's worth keeping from the chat. `/remember <text>` — save something specific.
- `/memory-review` — merge duplicates, check for stale facts, tighten the index.
  It shows proposed deletions first and waits for confirmation.
- Plain words work too: "remember that…", "forget about…".
- Memory is always written in English, whatever language you chat in. Code, paths,
  error messages, and UI labels are kept verbatim.

## Verify (2 minutes)

1. In an Agent chat: `remember that we deploy only on Tuesdays`. A file should appear
   in `.copilot-memory/` and a line in the index block.
2. In a **new** chat: `when do we deploy?` — it should answer without hints, and the
   answer's **References** should list `copilot-instructions.md`.

If `copilot-instructions.md` is not in References, check that the VS Code setting
`github.copilot.chat.codeGeneration.useInstructionFiles` is on (it is by default).

## Where it works

`.github/copilot-instructions.md` is read by every Copilot client: VS Code, Copilot
CLI, JetBrains, Visual Studio. Prompt files (`/remember`) are a VS Code feature; in
other clients just say "remember …".

## Limitations

- **It saves on its own less often than Claude Code.** Copilot's own system prompt
  comes first and pulls toward short answers; the "before your final answer"
  checklist compensates. Calling `/remember` at the end of a long task is the most
  reliable approach.
- Memory writes may show up in VS Code's pending-edits review alongside code changes.
- Memory is per repository. Global memory across projects would need the entries
  folder outside the workspace, and then every write needs an access confirmation.
