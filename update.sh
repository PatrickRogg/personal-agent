#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$REPO_DIR/agent"

echo "=== Updating Personal Agent ==="

cd "$REPO_DIR"

# Only pull if this is a git repo with a remote (skip on fresh clone during setup)
if git remote get-url origin &>/dev/null; then
  # Safety: stash any local changes to tracked files
  if ! git diff --quiet HEAD 2>/dev/null; then
    git stash push -m "auto-stash before update $(date +%Y-%m-%d-%H%M%S)"
    echo "Stashed local changes (see: git stash list)"
  fi

  # Pull latest
  BEFORE=$(git rev-parse HEAD)
  git pull --ff-only origin main
  AFTER=$(git rev-parse HEAD)

  if [ "$BEFORE" = "$AFTER" ]; then
    echo "Already up to date."
  else
    echo ""
    echo "Updated: $(git log --oneline "$BEFORE..$AFTER" | wc -l) new commit(s)"
    git log --oneline "$BEFORE..$AFTER"
    echo ""
  fi
else
  echo "No git remote found, skipping pull."
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
