#!/usr/bin/env bash
set -euo pipefail

AGENT_USER="agent"

# =============================================================================
# Phase 1: Root — install system deps, create user, hand off
# =============================================================================
if [ "$(id -u)" -eq 0 ]; then
  echo "=== Personal Agent VM Setup (root) ==="

  # System deps
  apt-get update
  apt-get install -y curl git build-essential unzip

  # Node.js 22
  if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
  fi
  echo "Node.js: $(node --version)"

  # Claude Code
  if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
  fi

  if ! command -v claude &> /dev/null; then
    echo "ERROR: Claude Code failed to install. Check npm output above."
    exit 1
  fi
  echo "Claude Code: $(claude --version)"

  # Create agent user
  if ! id "$AGENT_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$AGENT_USER"
    echo "Created user: $AGENT_USER"
  fi

  # Copy root SSH keys so the same key works for the agent user
  AGENT_SSH_DIR="/home/$AGENT_USER/.ssh"
  mkdir -p "$AGENT_SSH_DIR"
  if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys "$AGENT_SSH_DIR/authorized_keys"
    chmod 700 "$AGENT_SSH_DIR"
    chmod 600 "$AGENT_SSH_DIR/authorized_keys"
    chown -R "$AGENT_USER:$AGENT_USER" "$AGENT_SSH_DIR"
    echo "Copied SSH keys for $AGENT_USER"
  fi

  # Copy repo to agent user's home
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  DEST="/home/$AGENT_USER/personal-agent"

  if [ ! -d "$DEST" ]; then
    cp -r "$REPO_DIR" "$DEST"
  else
    # Update existing copy
    rsync -a --exclude='.git' "$REPO_DIR/" "$DEST/"
  fi
  chown -R "$AGENT_USER:$AGENT_USER" "$DEST"

  echo ""
  echo "=== Switching to $AGENT_USER user ==="
  echo ""

  # Re-run as agent user for Phase 2
  su - "$AGENT_USER" -c "cd $DEST && bash setup.sh"
  exit 0
fi

# =============================================================================
# Phase 2: Non-root (agent user) — workspace setup
# =============================================================================
echo "=== Personal Agent Setup (user: $(whoami)) ==="

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$REPO_DIR/agent"

# claudey alias
if ! grep -q 'alias claudey' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Claude Code — always runs from agent/ directory' >> ~/.bashrc
  echo "alias claudey=\"cd $AGENT_DIR && claude --dangerously-skip-permissions\"" >> ~/.bashrc
  echo "Added claudey alias to ~/.bashrc"
fi

# Auto-navigate to agent workspace on login
if ! grep -q 'cd.*personal-agent/agent' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Auto-navigate to agent workspace' >> ~/.bashrc
  echo "cd $AGENT_DIR 2>/dev/null" >> ~/.bashrc
  echo "Added auto-cd to ~/.bashrc"
fi

# Agent directories
mkdir -p "$AGENT_DIR/drop"
mkdir -p "$AGENT_DIR/knowledge"
mkdir -p "$AGENT_DIR/memory"
mkdir -p "$AGENT_DIR/output"
mkdir -p "$AGENT_DIR/scripts"

# .gitkeep files
touch "$AGENT_DIR/drop/.gitkeep"
touch "$AGENT_DIR/knowledge/.gitkeep"
touch "$AGENT_DIR/memory/.gitkeep"
touch "$AGENT_DIR/output/.gitkeep"
touch "$AGENT_DIR/scripts/.gitkeep"

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

# VM-specific .gitignore (track content dirs, unlike dev repo)
cat > "$AGENT_DIR/.gitignore" << 'VMGITIGNORE'
# Ephemeral input
drop/*
!drop/.gitkeep

# Tool artifacts
.claude/settings.local.json
node_modules/
.env
VMGITIGNORE

# Local git repo for tracking agent changes
if [ ! -d "$AGENT_DIR/.git" ]; then
  # Remove the parent dev repo's .git so agent/ is standalone
  [ -d "$REPO_DIR/.git" ] && rm -rf "$REPO_DIR/.git"

  cd "$AGENT_DIR"
  git config user.name "Agent"
  git config user.email "agent@local"
  git init
  git add -A
  git commit -m "Initial workspace state"
  echo "Initialized local git repo in $AGENT_DIR"
fi

# Convenience symlink for shorter path
ln -sfn "$AGENT_DIR" "/home/$(whoami)/workspace"

# API key check
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo ""
  echo "WARNING: ANTHROPIC_API_KEY is not set."
  echo "  Set it in your shell:  export ANTHROPIC_API_KEY=sk-..."
  echo "  Or add it to ~/.bashrc for persistence."
  echo ""
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. SSH in as '$AGENT_USER':  ssh $AGENT_USER@<your-vm-ip>"
echo "  2. Run: claude /login"
echo "  3. Open ~/workspace in VSCode via Remote SSH"
echo "  4. Or from terminal: claudey -p 'your prompt here'"
echo ""
