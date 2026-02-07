#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$REPO_DIR/agent"

echo "=== Updating Personal Agent ==="
cd "$REPO_DIR"

# Auto-commit any uncommitted agent changes before merging
if ! git diff --quiet 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard agent/ 2>/dev/null)" ]; then
  echo "Saving agent changes..."
  cd "$AGENT_DIR"
  git add -f memory/ knowledge/ scripts/ output/ drop/ 2>/dev/null || true
  cd "$REPO_DIR"
  git add -A
  git commit -m "Auto-save agent state $(date +%Y-%m-%d-%H%M%S)" || true
fi

# Fetch and merge upstream
if git remote get-url origin &>/dev/null; then
  git fetch origin

  BEFORE=$(git rev-parse HEAD)
  git merge origin/main -m "Merge upstream updates $(date +%Y-%m-%d)" --no-edit || {
    echo ""
    echo "ERROR: Merge conflict. Resolve manually, then run: git merge --continue"
    exit 1
  }
  AFTER=$(git rev-parse HEAD)

  if [ "$BEFORE" = "$AFTER" ]; then
    echo "Already up to date."
  else
    echo ""
    echo "Merged $(git log --oneline "$BEFORE..$AFTER" | wc -l) new upstream commit(s)"
    git log --oneline "$BEFORE..$AFTER"
    echo ""
  fi
else
  echo "No git remote found, skipping fetch."
fi

# Ensure workspace directories exist (idempotent)
for dir in drop knowledge memory output scripts scripts/defaults; do
  mkdir -p "$AGENT_DIR/$dir"
done

# Seed memory files (only if missing)
if [ ! -f "$AGENT_DIR/memory/_index.md" ]; then
  cat > "$AGENT_DIR/memory/_index.md" << 'SEED'
# Memory Index

Agent-maintained catalog. One line per entry.

- [me.md](me.md) — Core info about the user
SEED
  echo "Seeded memory/_index.md"
fi

if [ ! -f "$AGENT_DIR/memory/me.md" ]; then
  cat > "$AGENT_DIR/memory/me.md" << 'SEED'
# Me

<!-- The agent builds this file over time as it learns about you. -->
SEED
  echo "Seeded memory/me.md"
fi

echo "=== Update Complete ==="
