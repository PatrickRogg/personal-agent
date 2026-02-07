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

# Install missing dependencies (requires sudo, skips if not available)
install_deps() {
  local NEEDED_PKGS=()
  local APT_PKGS=(poppler-utils tesseract-ocr tesseract-ocr-eng pandoc catdoc jq p7zip-full imagemagick python3-pip python3-venv libxml2-utils)

  for pkg in "${APT_PKGS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      NEEDED_PKGS+=("$pkg")
    fi
  done

  if [ ${#NEEDED_PKGS[@]} -gt 0 ]; then
    echo "Installing missing packages: ${NEEDED_PKGS[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${NEEDED_PKGS[@]}"
  fi

  # Python venv for file-processing scripts
  AGENT_VENV="/opt/agent-venv"
  if [ ! -d "$AGENT_VENV" ]; then
    echo "Creating Python venv for file-processing tools..."
    sudo python3 -m venv "$AGENT_VENV"
    sudo chmod -R a+rX "$AGENT_VENV"
  fi

  # Install/update Python packages
  local PIP_PKGS=(python-docx python-pptx openpyxl xlsx2csv pdfplumber Pillow pytesseract)
  local MISSING_PIP=false
  for pkg in "${PIP_PKGS[@]}"; do
    if ! "$AGENT_VENV/bin/pip" show "$pkg" &>/dev/null; then
      MISSING_PIP=true
      break
    fi
  done

  if [ "$MISSING_PIP" = true ]; then
    echo "Installing missing Python packages..."
    sudo "$AGENT_VENV/bin/pip" install --upgrade pip -q
    sudo "$AGENT_VENV/bin/pip" install "${PIP_PKGS[@]}" -q
    sudo chmod -R a+rX "$AGENT_VENV"
  fi
}

if command -v sudo &>/dev/null; then
  install_deps || echo "Note: Some dependencies could not be installed (may need root). Run setup.sh as root to install all dependencies."
fi

# Ensure workspace directories exist (idempotent)
for dir in drop knowledge memory output scripts scripts/defaults; do
  mkdir -p "$AGENT_DIR/$dir"
done

# Make default scripts executable
chmod +x "$AGENT_DIR/scripts/defaults/"*.sh 2>/dev/null || true

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
