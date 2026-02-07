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

  # Clone repo to agent user's home (with .git intact for updates)
  REPO_URL="https://github.com/PatrickRogg/personal-agent.git"
  DEST="/home/$AGENT_USER/personal-agent"

  if [ ! -d "$DEST" ]; then
    su - "$AGENT_USER" -c "git clone $REPO_URL $DEST"
  else
    chown -R "$AGENT_USER:$AGENT_USER" "$DEST"
  fi

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

# update alias
if ! grep -q 'alias update=' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Pull latest repo changes and sync workspace' >> ~/.bashrc
  echo "alias update=\"bash $REPO_DIR/update.sh\"" >> ~/.bashrc
  echo "Added update alias to ~/.bashrc"
fi

# Auto-navigate to agent workspace on login
if ! grep -q 'cd.*personal-agent/agent' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# Auto-navigate to agent workspace' >> ~/.bashrc
  echo "cd $AGENT_DIR 2>/dev/null" >> ~/.bashrc
  echo "Added auto-cd to ~/.bashrc"
fi

# Run update.sh to set up workspace (dirs, seed files, etc.)
bash "$REPO_DIR/update.sh"

# Create local my-agent branch for agent content (first-run only)
cd "$REPO_DIR"
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "Creating my-agent branch..."
  git checkout -b my-agent

  # Force-add agent content (overrides .gitignore for this branch)
  cd "$AGENT_DIR"
  git add -f memory/ knowledge/ scripts/ output/ drop/ 2>/dev/null || true
  cd "$REPO_DIR"
  git commit -m "Initial agent workspace state" || true
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
echo "  5. To pull updates: update"
echo ""
