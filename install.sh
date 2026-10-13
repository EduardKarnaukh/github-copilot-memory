#!/usr/bin/env bash
# Installs GitHub Copilot memory into a repository.
#   ./install.sh /path/to/repo            — personal memory (kept out of git)
#   ./install.sh /path/to/repo --commit   — shared team memory (committed)
#
# The memory protocol and index go straight into .github/copilot-instructions.md,
# which Copilot injects into every request. If the file already exists, the memory
# block is appended between markers; the rest of the file is left untouched.
# Re-running upgrades the protocol text and keeps the accumulated index.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?Pass the repository path: ./install.sh /path/to/repo [--commit]}"
MODE="${2:-}"
TARGET="$(cd "$TARGET" && pwd)"
CI="$TARGET/.github/copilot-instructions.md"
TMP="$(mktemp)"; trap 'rm -f "$TMP" "$TMP.new"' EXIT

echo "Installing into $TARGET"
mkdir -p "$TARGET/.github" "$TARGET/.copilot-memory"

# Memory block = protocol from the kit + index (existing one if present, else empty).
{
  echo "<!-- copilot-memory:start -->"
  awk '/<!-- memory-index:start -->/ {exit} {print}' "$KIT/memory-protocol.md"
  if [ -f "$CI" ] && grep -q '<!-- memory-index:start -->' "$CI"; then
    awk '/<!-- memory-index:start -->/ {on=1} on {print} /<!-- memory-index:end -->/ {exit}' "$CI"
  else
    awk '/<!-- memory-index:start -->/ {on=1} on {print}' "$KIT/memory-protocol.md"
  fi
  echo "<!-- copilot-memory:end -->"
} > "$TMP"

if [ -f "$CI" ] && grep -q '<!-- copilot-memory:start -->' "$CI"; then
  awk -v blk="$TMP" '
    /<!-- copilot-memory:start -->/ { while ((getline l < blk) > 0) print l; skip=1; next }
    /<!-- copilot-memory:end -->/   { skip=0; next }
    !skip { print }' "$CI" > "$TMP.new"
  mv "$TMP.new" "$CI"
  echo "  updated memory block in .github/copilot-instructions.md (index kept)"
elif [ -f "$CI" ]; then
  { echo; cat "$TMP"; } >> "$CI"
  echo "  appended memory block to existing .github/copilot-instructions.md"
else
  cp "$TMP" "$CI"
  echo "  created .github/copilot-instructions.md"
fi

for p in remember.prompt.md memory-review.prompt.md; do
  if [ -e "$TARGET/.github/prompts/$p" ]; then
    echo "  skipped (already exists): .github/prompts/$p"
  else
    mkdir -p "$TARGET/.github/prompts"
    cp "$KIT/.github/prompts/$p" "$TARGET/.github/prompts/$p"
    echo "  added: .github/prompts/$p"
  fi
done

if [ "$MODE" = "--commit" ]; then
  touch "$TARGET/.copilot-memory/.gitkeep"
  echo "  shared memory: commit .github/ and .copilot-memory/"
else
  GI="$TARGET/.gitignore"
  touch "$GI"
  ignore=(".copilot-memory/" ".github/prompts/remember.prompt.md" ".github/prompts/memory-review.prompt.md")
  tracked=0
  git -C "$TARGET" ls-files --error-unmatch .github/copilot-instructions.md >/dev/null 2>&1 && tracked=1
  [ "$tracked" = 0 ] && ignore+=(".github/copilot-instructions.md")
  for line in "${ignore[@]}"; do
    grep -qxF "$line" "$GI" || echo "$line" >> "$GI"
  done
  echo "  personal memory: paths added to .gitignore"
  if [ "$tracked" = 1 ]; then
    echo "  NOTE: .github/copilot-instructions.md is tracked by git, so the memory block shows"
    echo "        up as a local change. To keep it out of commits:"
    echo "        git -C \"$TARGET\" update-index --skip-worktree .github/copilot-instructions.md"
  fi
fi

echo "Done. Open the repo in VS Code, Copilot Chat -> Agent mode."
