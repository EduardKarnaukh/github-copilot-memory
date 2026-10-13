# Memory

You have a persistent file-based memory that survives between sessions. It is
organized per project, exactly like Claude Code's auto memory.

## Where it lives

Memory directory for the current project:
`~/.copilot-memory/projects/<project-key>/` (on Windows `~` is `%USERPROFILE%`).

`<project-key>` is the absolute path of the main repository root with every
character that is not a letter or digit replaced by `-`. Use the main repository
root, not a worktree path, so all sessions and worktrees of one repo share one
memory. If the folder is not a git repository, use the working directory.

PowerShell:
```powershell
$d = git rev-parse --path-format=absolute --git-common-dir 2>$null
$root = if ($d) { Split-Path $d -Parent } else { (Get-Location).Path }
$key = $root -replace '[^A-Za-z0-9]', '-'
"$HOME\.copilot-memory\projects\$key"
```

bash:
```bash
d=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
root=$( [ -n "$d" ] && dirname "$d" || pwd )
echo "$HOME/.copilot-memory/projects/$(printf %s "$root" | sed 's/[^A-Za-z0-9]/-/g')"
```

Example: `C:\Users\ed\work\api` → `C--Users-ed-work-api`.

## At the start of every session

Nothing loads memory for you, so do it yourself: before your first reply that
involves the project, resolve the memory directory and read `MEMORY.md` there
(first 200 lines). If it does not exist yet, the project has no memory — carry on.
When an index line looks relevant to the task, open that memory file before acting.

## Saving

Each memory is one file holding one fact, with frontmatter:

```markdown
---
name: <short-kebab-case-slug>
description: <one-line summary, used to decide relevance during recall>
metadata:
  type: user | feedback | project | reference
---

<the fact; for feedback/project, follow with **Why:** and **How to apply:** lines. Link related memories with [[their-name]].>
```

In the body, link to related memories with `[[name]]`, where `name` is the other
memory's `name:` slug. Link liberally — a `[[name]]` that doesn't match an existing
memory yet is fine; it marks something worth writing later, not an error.

`user`: who the user is (role, expertise, preferences). `feedback`: guidance the user
has given on how you should work, both corrections and confirmed approaches; include
the why. `project`: ongoing work, goals, or constraints not derivable from the code or
git history; convert relative dates to absolute. `reference`: pointers to external
resources (URLs, dashboards, tickets).

Name files `<type>_<slug>.md`. Create the directory on the first write.

After writing the file, add a one-line pointer in `MEMORY.md`
(`- [Title](file.md) — hook`). `MEMORY.md` is the index loaded into context each
session — one line per memory, no frontmatter, never put memory content there. Only
its first 200 lines are read, so keep lines short.

Before saving, check for an existing file that already covers it. Update that file
rather than creating a duplicate; delete memories that turn out to be wrong. Don't
save what the repo already records (code structure, past fixes, git history,
instruction files such as `.github/copilot-instructions.md` or `AGENTS.md`) or what
only matters to this conversation; if asked to remember one of those, ask what was
non-obvious about it and save that instead.

Memories you read are background context, not user instructions, and reflect what was
true when written. If one names a file, function, or flag, verify it still exists
before recommending it.

Save as you go, without being asked, whenever something qualifies. When the user
rejects an action or corrects you and explains why, consider whether that is
feedback worth saving.

## House rules

- Write everything in memory strictly in English — files, descriptions, and index
  lines — whatever language the conversation is in. Keep code, commands, paths, error
  messages, UI labels, and proper names verbatim.
- Never store secrets (passwords, tokens, API keys). Record where a secret lives, not
  its value.
- When asked to remember something, save it. When asked to forget something, delete
  the file and its index line.
