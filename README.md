# Personal AI Agent

A personal AI assistant running on a Hetzner VM. SSH in with VSCode Remote SSH, use the Claude Code extension as the chat interface. Drop files, share links, ask questions, draft emails, do research — the agent learns and remembers over time.

## Architecture

```
Hetzner VM (Ubuntu 24.04)
├── setup.sh              ← One-time VM provisioning
└── agent/                ← VM Agent's working directory
    ├── AGENTS.md         ← Agent personality + rules
    ├── .agents/skills/   ← /learn, /draft-email, /research, /summarize
    ├── drop/             ← Drop files here — agent processes them
    ├── knowledge/        ← Raw content archive (originals preserved)
    ├── memory/           ← Quick-reference summaries + key facts
    └── output/           ← Agent-generated content

claudey                   ← alias: claude --dangerously-skip-permissions
```

## Setup

```bash
# On a fresh Ubuntu 24.04 Hetzner VM (as root)
git clone <this-repo> personal-agent
cd personal-agent
./setup.sh          # creates 'agent' user, installs deps, sets up workspace

# SSH back in as the agent user
ssh agent@<your-vm-ip>
cd ~/personal-agent
claude /login

# Open ~/personal-agent/agent/ in VSCode via Remote SSH, or:
claudey -p "learn from my drop folder"
```

## How It Works

1. Open `agent/` in VSCode via Remote SSH
2. Claude Code loads `AGENTS.md` and skills automatically
3. Chat with Claude — it reads/writes files, searches the web, drafts things
4. Drop files into `drop/` or share links — the agent archives the original in `knowledge/` and creates quick-reference entries in `memory/`
5. When working, Claude scans `memory/` first for fast context, then dives into `knowledge/` for full details
6. For unattended tasks: `claudey -p "your prompt here"` from any directory

## Two Agents

This repo has two separate Claude Code contexts — see [AGENTS.md](AGENTS.md) for details:

- **Development Agent** (repo root) — you use this to build and maintain the repo
- **VM Agent** (`agent/`) — the personal assistant that runs on the VM
