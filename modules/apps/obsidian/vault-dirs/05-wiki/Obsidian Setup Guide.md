---
tags:
  - wiki
  - meta
  - guide
aliases:
  - Obsidian Setup Guide
  - How to use this vault
---

# Obsidian Setup Guide (2026 Edition)

This vault is configured as a **Smart Environment**, integrating Nix-managed stability with AI-powered agility via **opencode**.

## Daily Workflow

### 1. The Daily Note (`Alt + D`)
Your Daily Note is the "Command Center." It automatically pulls in:
- **Overdue & Today's Tasks**: Standard checkbox tasks.
- **Rich Tasks**: Complex tasks tracked as individual notes (tagged `#task`).
- **Semantic Discoveries**: "On this day" reflections from previous years.
- **End of Day Review**: An automated summary of what you actually finished.

### 2. Capturing Data (`QuickAdd`)
Use the **QuickAdd** hotkeys to capture information without losing focus:
- **Quick Task**: Adds a task directly to your daily note.
- **Quick Resource**: Files a link or article into `03 - Resources`.
- **Quick Snippet**: Saves code blocks to `04 - Snippets`.

---

## AI & Agent Integration

The vault is accessible to opencode via the **Obsidian Local REST API** plugin using `obsidian-mcp-server`. This enables AI read/write/search operations directly on the vault.

### Slash Commands (in opencode)

26 vault operations are available as `/obsidian-*` commands:

| Command | Purpose |
| :--- | :--- |
| `obsidian-read` | Read a vault note |
| `obsidian-write` | Create or overwrite a note |
| `obsidian-append` | Append content to a note |
| `obsidian-patch` | Edit a heading/block/frontmatter section |
| `obsidian-search` | Search the vault |
| `obsidian-daily` | Open/create the daily note |
| `obsidian-weekly` | Weekly note and review operations |
| ... | 26 commands total |

### AI Workflows

| Goal | How |
| :--- | :--- |
| **Brainstorm** | Ask opencode to save ideas to a note |
| **Summarize** | Ask opencode to read and summarize vault content |
| **Organize** | Ask opencode to review and tag untagged notes |
| **Research** | Ask opencode to save research findings to vault notes |

---

## Advanced Features

### Task-as-a-Note
For big tasks, don't just use a checkbox. Create a note:
1. Create `My Big Project Task.md` in `00 - Daily/`.
2. Tag it `#task`.
3. Add properties: `due: YYYY-MM-DD`, `status: active`.
4. It will automatically appear in your Daily Note's **Rich Tasks** section.

### Obsidian MCP Access
The vault is served via `obsidian-mcp-server` (HTTPS-based, self-signed cert):
- **MCP tools**: 14 tools for read, write, search, list, and manage notes
- **URL**: `https://localhost:27124`
- **Auth**: Bearer token via `OBSIDIAN_API_KEY` (baked into the MCP wrapper)

### Canvas Mapping
For complex projects, open a **Canvas** (`02 - Projects/`). Ask opencode to populate it with research from your resources.

---

## Maintenance
- **Weekly Review**: Every Sunday, the Weekly Review aggregates "Wins," "Challenges," and "Lessons Learned" from the past 7 days.
- **Nix Updates**: Edit `modules/apps/obsidian/default.nix` and run `home-manager switch`.
- **Automation**: obsidian-second-brain commands handle vault ops — no manual scripts needed.

---

*Note: This guide is maintained by opencode. If you change your workflow, ask it to update this guide.*
