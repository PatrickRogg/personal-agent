# AGENTS.md

This repository involves two separate Claude Code agents with distinct roles and contexts.

## 1. Development Agent (repo root)

**Where:** Your local machine or cloud IDE, working directory = repo root
**AGENTS.md:** `./AGENTS.md`
**Purpose:** Build, maintain, and improve this repository — edit skills, refine the VM Agent's instructions, update setup scripts, etc.
**Tools:** Full development toolset (git, file editing, web search, etc.)

This is the agent you interact with when developing the project.

## 2. VM Agent (`agent/`)

**Where:** Hetzner VM via VSCode Remote SSH, working directory = `agent/`
**AGENTS.md:** `agent/AGENTS.md`
**Purpose:** Personal AI assistant — draft emails, do research, manage memory, process inbox files
**Tools:** Filesystem (scoped to `agent/`), WebSearch, WebFetch
**Skills:** `/draft-email`, `/research`, `/remember`, `/summarize`
**Alias:** `claudey` (runs with `--dangerously-skip-permissions` for unattended use)

This is the agent that runs on the VM as your day-to-day assistant.

## Why the Separation

The two agents have completely different contexts and concerns:

| | Development Agent | VM Agent |
|---|---|---|
| Working directory | Repo root | `agent/` |
| Sees | Full repo, git history, CI | Only `agent/` subtree |
| AGENTS.md | Development instructions | Personal assistant personality |
| Goal | Improve the codebase | Help the user with tasks |
| Runs on | Your dev machine | Hetzner VM |

The VM Agent never sees the repo root, `AGENTS.md`, or the development instructions. It only knows about its own `agent/AGENTS.md`, skills, and workspace. This keeps the assistant focused and prevents it from accidentally modifying development files.

## Setup Flow

1. Clone this repo on the Hetzner VM
2. Run `agent/setup.sh` to install dependencies
3. Open `agent/` (not the repo root) in VSCode Remote SSH
4. Claude Code loads `agent/AGENTS.md` and the skills automatically
