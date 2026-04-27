---
tags:
  - wiki
  - meta
  - guide
aliases:
  - Obsidian Setup Guide
  - How to use this vault
---

# 🧠 Obsidian Setup Guide (2026 Edition)

This vault is configured as a **Smart Environment**, integrating Nix-managed stability with AI-powered agility via the **Gemini CLI (opencode)**.

## 📅 Daily Workflow

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

## 🤖 AI & Agent Prompts

You are using a **Local REST API** which allows `opencode` (the Gemini CLI) to interact with your vault directly.

### CLI Commands (Run from Terminal)
| Goal | Command |
| :--- | :--- |
| **Brainstorm** | `opencode --prompt "Brainstorm 5 ideas for [Topic] and save them to 05 - Wiki/[Topic].md"` |
| **Summarize** | `opencode --prompt "Read 03 - Resources/[File].md and summarize it into my Daily Note"` |
| **Organize** | `opencode --prompt "Review all untagged notes in Resources and suggest tags"` |
| **Plan** | `opencode --prompt "Create a strategic roadmap for [Project] in 02 - Projects/[Project].canvas"` |

### Internal AI Prompts (Coming from Obsidian)
- Use **Templater** (`Alt + E`) to run dynamic scripts that call the AI.
- Use **Smart Connections** to chat with your vault in the sidebar. It uses your local notes as "Context Packs" for more accurate answers.

---

## 🛠️ Advanced 2026 Features

### Task-as-a-Note
For big tasks, don't just use a checkbox. Create a note:
1. Create `My Big Project Task.md` in `00 - Daily/`.
2. Tag it `#task`.
3. Add properties: `due: 2026-04-23`, `status: active`.
4. It will automatically appear in your Daily Note's **Rich Tasks** section.

### Omnisearch (Semantic Search)
Press `Ctrl + S` (standard) or your Omnisearch hotkey to search by **intent**. Instead of searching for "Nix," you can search for "How do I configure my shell?" and it will find relevant notes even if the exact word isn't there.

### Canvas Mapping
For complex projects, open a **Canvas** (`02 - Projects/`). You can ask me (`opencode`) to "Populate this canvas with research from my resources," and I will place cards and arrows representing the relationships between your notes.

---

## 🔧 Maintenance
- **Weekly Review**: Every Sunday, create a Weekly Review note. It will automatically aggregate your "Wins," "Challenges," and "Lessons Learned" from the past 7 days.
- **Nix Updates**: To add new plugins, update `modules/obsidian.nix` and run `home-manager switch`.

---
*Note: This guide is maintained by your AI Agent. If you change your workflow, ask me to update this manual!*
