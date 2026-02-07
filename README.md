# Personal AI Agent

A personal AI assistant running on a Hetzner VM. SSH in with VSCode Remote SSH, use the Claude Code extension as the chat interface. Drop files, ask questions, draft emails, do research, keep memories.

## Architecture

```
Hetzner VM (Ubuntu 24.04)
├── setup.sh              ← One-time VM provisioning
└── agent/                ← VM Agent's working directory
    ├── AGENTS.md         ← Agent personality + rules
    ├── .agents/skills/   ← /draft-email, /research, /remember, /summarize
    └── workspace/
        ├── memory/       ← Persistent agent memory
        ├── templates/    ← Email templates, style references
        ├── inbox/        ← Drop files here for processing
        └── output/       ← Agent-generated content

claudey                   ← alias: claude --dangerously-skip-permissions
```

## Setup

```bash
# On a fresh Ubuntu 24.04 Hetzner VM
git clone <this-repo> personal-agent
cd personal-agent
./setup.sh

# Log in to Claude
claude /login

# Open agent/ in VSCode via Remote SSH, or:
claudey -p "summarize my inbox"
```

## How It Works

1. Open `agent/` in VSCode via Remote SSH
2. Claude Code loads `AGENTS.md` and skills automatically
3. Chat with Claude — it reads/writes workspace files, searches the web, drafts things
4. Drop files into `workspace/inbox/`, ask Claude to process them
5. Claude maintains memory in `workspace/memory/`
6. For unattended tasks: `claudey -p "your prompt here"` from any directory

## Two Agents

This repo has two separate Claude Code contexts — see [AGENTS.md](AGENTS.md) for details:

- **Development Agent** (repo root) — you use this to build and maintain the repo
- **VM Agent** (`agent/`) — the personal assistant that runs on the VM
