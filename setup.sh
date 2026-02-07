#!/usr/bin/env bash
set -euo pipefail

echo "=== Personal Agent VM Setup ==="

# System deps
sudo apt-get update
sudo apt-get install -y curl git build-essential unzip

# Node.js 22
if ! command -v node &> /dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
echo "Node.js: $(node --version)"

# Claude Code
if ! command -v claude &> /dev/null; then
  sudo npm install -g @anthropic-ai/claude-code
fi

if ! command -v claude &> /dev/null; then
  echo "ERROR: Claude Code failed to install. Check npm output above."
  exit 1
fi
echo "Claude Code: $(claude --version)"

# API key check
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo ""
  echo "WARNING: ANTHROPIC_API_KEY is not set."
  echo "  Set it in your shell:  export ANTHROPIC_API_KEY=sk-..."
  echo "  Or add it to ~/.bashrc for persistence."
  echo ""
fi

# claudey alias (always runs from agent/ directory)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$REPO_DIR/agent"
if ! grep -q 'alias claudey' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Claude Code yolo mode — always runs from agent/ directory' >> ~/.bashrc
  echo "alias claudey=\"cd $AGENT_DIR && claude --dangerously-skip-permissions\"" >> ~/.bashrc
  echo "Added claudey alias to ~/.bashrc (working dir: $AGENT_DIR)"
fi

# Agent directories
mkdir -p "$AGENT_DIR/drop"
mkdir -p "$AGENT_DIR/knowledge"
mkdir -p "$AGENT_DIR/memory"
mkdir -p "$AGENT_DIR/output"

# .gitkeep files
touch "$AGENT_DIR/drop/.gitkeep"
touch "$AGENT_DIR/knowledge/.gitkeep"
touch "$AGENT_DIR/memory/.gitkeep"
touch "$AGENT_DIR/output/.gitkeep"

# Seed memory files (only if they don't exist)
if [ ! -f "$AGENT_DIR/memory/_index.md" ]; then
  cat > "$AGENT_DIR/memory/_index.md" << 'SEED'
# Memory Index

Agent-maintained catalog. One line per entry.

- [me.md](me.md) — Core info about the user
SEED
fi

if [ ! -f "$AGENT_DIR/memory/me.md" ]; then
  cat > "$AGENT_DIR/memory/me.md" << 'SEED'
# Me

<!-- The agent builds this file over time as it learns about you. -->
SEED
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Run: claude /login"
echo "  2. Open the agent/ folder in VSCode via Remote SSH"
echo "  3. Use Claude Code extension to chat"
echo "  4. Or from terminal: claudey -p 'your prompt here'"
echo ""
