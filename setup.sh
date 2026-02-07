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
echo "Claude Code: $(claude --version)"

# claudey alias (always runs from agent/ directory)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$REPO_DIR/agent"
if ! grep -q 'alias claudey' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Claude Code yolo mode — always runs from agent/ directory' >> ~/.bashrc
  echo "alias claudey=\"cd $AGENT_DIR && claude --dangerously-skip-permissions\"" >> ~/.bashrc
  echo "Added claudey alias to ~/.bashrc (working dir: $AGENT_DIR)"
fi

# Workspace dirs
mkdir -p "$AGENT_DIR/workspace/memory"
mkdir -p "$AGENT_DIR/workspace/templates"
mkdir -p "$AGENT_DIR/workspace/inbox"
mkdir -p "$AGENT_DIR/workspace/output"

# Seed memory files (only if they don't exist)
if [ ! -f "$AGENT_DIR/workspace/memory/about-me.md" ]; then
  cat > "$AGENT_DIR/workspace/memory/about-me.md" << 'SEED'
# About Me

<!-- Fill this in so the agent knows who you are -->

- Name:
- Role:
- Company:
- Key interests:
SEED
fi

if [ ! -f "$AGENT_DIR/workspace/memory/contacts.md" ]; then
  cat > "$AGENT_DIR/workspace/memory/contacts.md" << 'SEED'
# Contacts

<!-- The agent will add people here as it learns about them -->
SEED
fi

if [ ! -f "$AGENT_DIR/workspace/memory/projects.md" ]; then
  cat > "$AGENT_DIR/workspace/memory/projects.md" << 'SEED'
# Active Projects

<!-- The agent will track your projects here -->
SEED
fi

if [ ! -f "$AGENT_DIR/workspace/memory/preferences.md" ]; then
  cat > "$AGENT_DIR/workspace/memory/preferences.md" << 'SEED'
# Preferences

<!-- Writing tone, email style, formatting preferences, etc. -->
SEED
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Run: claude /login"
echo "  2. Open the agent/ folder in VSCode via Remote SSH"
echo "  3. Use Claude Code extension to chat"
echo "  4. Or from terminal: claudey -p 'your prompt here' (auto-cds to agent/)"
echo ""
