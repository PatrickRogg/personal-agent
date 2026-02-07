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

# Check and install missing dependencies
echo ""
echo "--- Checking dependencies ---"

APT_PKGS=(poppler-utils tesseract-ocr tesseract-ocr-eng pandoc catdoc jq p7zip-full imagemagick python3-pip python3-venv libxml2-utils)
AGENT_VENV="/opt/agent-venv"
PIP_PKGS=(python-docx python-pptx openpyxl xlsx2csv pdfplumber Pillow pytesseract)

# Check which apt packages are missing
MISSING_APT=()
for pkg in "${APT_PKGS[@]}"; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    MISSING_APT+=("$pkg")
  fi
done

# Check Python venv and packages
VENV_EXISTS=false
MISSING_PIP=()
if [ -d "$AGENT_VENV" ]; then
  VENV_EXISTS=true
  for pkg in "${PIP_PKGS[@]}"; do
    if ! "$AGENT_VENV/bin/pip" show "$pkg" &>/dev/null 2>&1; then
      MISSING_PIP+=("$pkg")
    fi
  done
fi

# Report status
if [ ${#MISSING_APT[@]} -eq 0 ] && [ "$VENV_EXISTS" = true ] && [ ${#MISSING_PIP[@]} -eq 0 ]; then
  echo "All dependencies installed."
else
  # Something is missing — report what
  [ ${#MISSING_APT[@]} -gt 0 ] && echo "Missing apt packages: ${MISSING_APT[*]}"
  [ "$VENV_EXISTS" = false ] && echo "Missing Python venv at $AGENT_VENV"
  [ ${#MISSING_PIP[@]} -gt 0 ] && echo "Missing Python packages: ${MISSING_PIP[*]}"

  # Determine if we can install (root or passwordless sudo)
  # Note: stdin from /dev/null prevents any interactive password prompt
  SUDO=""
  CAN_INSTALL=false
  if [ "$(id -u)" -eq 0 ]; then
    CAN_INSTALL=true
  elif command -v sudo &>/dev/null && sudo -n true </dev/null 2>/dev/null; then
    SUDO="sudo"
    CAN_INSTALL=true
  else
    echo ""
    echo "WARNING: Cannot install automatically (no passwordless sudo)."
    echo "  Run as root:  sudo bash $REPO_DIR/setup.sh"
    echo ""
  fi

  if [ "$CAN_INSTALL" = true ]; then
    echo "Installing missing dependencies..."

    if [ ${#MISSING_APT[@]} -gt 0 ]; then
      $SUDO apt-get update -qq
      $SUDO apt-get install -y "${MISSING_APT[@]}"
    fi

    if [ "$VENV_EXISTS" = false ]; then
      $SUDO python3 -m venv "$AGENT_VENV"
      $SUDO chmod -R a+rX "$AGENT_VENV"
      # Fresh venv — install all pip packages
      MISSING_PIP=("${PIP_PKGS[@]}")
    fi

    if [ ${#MISSING_PIP[@]} -gt 0 ]; then
      $SUDO "$AGENT_VENV/bin/pip" install --upgrade pip -q
      $SUDO "$AGENT_VENV/bin/pip" install "${MISSING_PIP[@]}" -q
      $SUDO chmod -R a+rX "$AGENT_VENV"
    fi

    echo "Dependencies installed."
  fi
fi

# Ensure workspace directories exist (idempotent)
for dir in drop knowledge memory output scripts scripts/defaults; do
  mkdir -p "$AGENT_DIR/$dir"
done

# Make default scripts executable
chmod +x "$AGENT_DIR/scripts/defaults/"*.sh 2>/dev/null || true

# Seed Claude Code settings (bypass permissions for unattended use)
SETTINGS_FILE="$AGENT_DIR/.claude/settings.local.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p "$AGENT_DIR/.claude"
  cat > "$SETTINGS_FILE" << 'SEED'
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
SEED
  echo "Seeded .claude/settings.local.json"
fi

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
