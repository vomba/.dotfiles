---
name: obsidian-brain
description: Use this skill when interacting with the Obsidian vault. Enables creating, reading, updating, and organizing notes. LLM operations use opencode CLI — no other AI tools needed.
origin: local
---

# Obsidian Brain — Vault Interaction Skill

This skill enables opencode to interact with the Obsidian vault via the Local REST API plugin for file operations, and uses opencode itself for all LLM-powered note organization and summarization.

## When to Activate

- User asks to create, update, or organize notes
- User wants to search the vault
- User wants to add tasks, resources, or snippets
- User wants to summarize or reorganize vault content
- User wants AI-powered note processing (always via opencode)

## Architecture

### File Operations: Local REST API
The Obsidian Local REST API plugin exposes the vault at:
- **Base URL:** `http://localhost:27124`
- **Auth:** Bearer token via `Authorization` header
- **API Key:** `obsidian-local-rest-api-key`

### LLM Operations: OpenCode
All AI/LLM operations use opencode directly — no Copilot, no Smart Connections, no external AI plugins inside Obsidian. OpenCode provides CLI interaction that can be triggered from within Obsidian via shell commands or the Local REST API.

## API Endpoints

### Read Notes
```bash
# Get note content
curl -s -H "Authorization: Bearer obsidian-local-rest-api-key" \
  "http://localhost:27124/vault/note?path=00%20-%20Daily/2025-04-20%20Sunday.md"

# Search vault
curl -s -H "Authorization: Bearer obsidian-local-rest-api-key" \
  "http://localhost:27124/vault/search?q=task&contextLength=200"

# List files in a folder
curl -s -H "Authorization: Bearer obsidian-local-rest-api-key" \
  "http://localhost:27124/vault/list?path=03%20-%20Resources"
```

### Create/Update Notes
```bash
# Create or update a note
curl -s -X PUT \
  -H "Authorization: Bearer obsidian-local-rest-api-key" \
  -H "Content-Type: text/markdown" \
  -d "# My Note\n\nContent here" \
  "http://localhost:27124/vault/note?path=05%20-%20Wiki/My%20Note.md"

# Append to a note
curl -s -X PATCH \
  -H "Authorization: Bearer obsidian-local-rest-api-key" \
  -H "Content-Type: text/markdown" \
  -d "\n\n## New section\nAppended content" \
  "http://localhost:27124/vault/note?path=00%20-%20Daily/2025-04-20%20Sunday.md"
```

### Dataview Queries
```bash
# Execute a dataview query
curl -s -X POST \
  -H "Authorization: Bearer obsidian-local-rest-api-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "TABLE file.ctime FROM #resource"}' \
  "http://localhost:27124/plugins/dataview/query"
```

## LLM Integration via OpenCode

### From Inside Obsidian
Use the **Templater** or **QuickAdd** plugins to call opencode from within notes:

```bash
# Summarize current note via opencode
opencode --prompt "Summarize this note: $(cat '{{title}}.md')"

# Extract action items from a note
opencode --prompt "Extract all action items and tasks from: $(cat '{{title}}.md')"

# Suggest tags for current note
opencode --prompt "Suggest relevant tags for this note content: $(cat '{{title}}.md')"
```

### From Terminal
```bash
# Ask opencode to create a daily note
opencode --prompt "Create today's daily note with tasks from yesterday"

# Ask opencode to organize untagged notes
opencode --prompt "Review notes in ~/.vault/03-Resources and suggest tags"

# Ask opencode to generate a weekly summary
opencode --prompt "Summarize this week's daily notes into a weekly review"
```

### OpenCode Skill Integration
When opencode is asked to work with the vault, it automatically loads this skill and:
1. Uses the Local REST API to read/write notes
2. Uses its own LLM capabilities for summarization, tagging, and organization
3. Formats notes according to vault conventions

## Vault Structure

```
~/.vault/
├── 00 - Daily/           # Daily notes (YYYY-MM-DD dddd.md)
├── 01 - Weekly/          # Weekly reviews (Week NN YYYY Review.md)
├── 02 - Projects/        # Active project notes
├── 03 - Resources/       # Saved articles, links, references
├── 04 - Snippets/        # Code snippets
├── 05 - Wiki/            # Personal wiki / MOCs
├── 06 - Archive/         # Completed/inactive notes
└── Templates/            # Note templates
```

## Note Formatting Conventions

### Daily Notes
- **Filename:** `YYYY-MM-DD dddd.md` (e.g., `2025-04-20 Sunday.md`)
- **Frontmatter:** `created`, `tags: [daily]`, `aliases`
- **Sections:** Tasks (overdue, due today, due this week), Today's Tasks, Notes, Resources Captured, End of Day Review

### Resources
- **Filename:** Descriptive title.md
- **Frontmatter:** `tags: [resource]`, `url`, `source`, `type`, `status`
- **Sections:** Summary, Key Takeaways, Highlights, Related Notes

### Snippets
- **Filename:** Descriptive title.md
- **Frontmatter:** `tags: [snippet]`, `language`, `source`
- **Sections:** Description, Code block, Usage Notes

### Wiki Pages
- **Filename:** Topic name.md
- **Frontmatter:** `tags: [wiki]`, `aliases`, `related`
- **Sections:** Overview, Details, Related Notes, References

## Common Workflows

### Add a Resource
1. Create note in `03 - Resources/` using the Resource template
2. Include URL, summary, and key takeaways
3. Tag appropriately

### Add a Task to Today's Daily Note
1. Determine today's filename: `YYYY-MM-DD dddd.md`
2. Append `- [ ] Task description` under "## Today's Tasks"

### Create a Wiki Entry
1. Create note in `05 - Wiki/` using the Wiki Page template
2. Include aliases for discoverability
3. Link to related notes with `[[wikilinks]]`
### Summarize Recent Notes (via OpenCode)
1. List recent files in `00 - Daily/`
2. Read content and extract key points
3. Create summary note in `01 - Weekly/`

### Task-as-a-Note Workflow (2026)
For complex tasks that require more than a single line:
1. Create a note in `00 - Daily/tasks/` or tag it `#task`.
2. Use properties like `status`, `priority`, and `due`.
3. Link the task note in your Daily Note under "Today's Tasks".

### Canvas Strategic Mapping
When planning projects:
1. Create a `.canvas` file in `02 - Projects/`.
2. Use the "Add Card" feature via REST API to have opencode map out dependencies.
3. Link related research notes from `03 - Resources/` directly on the board.

## Error Handling
### Auto-Tag Notes (via OpenCode)
1. Find notes missing tags
2. Read content and suggest relevant tags
3. Update frontmatter with suggested tags

## Error Handling

If the REST API is unreachable:
1. Verify Obsidian is running
2. Verify the Local REST API plugin is enabled
3. Verify the API key matches: `obsidian-local-rest-api-key`
4. Fall back to direct file system operations on `~/.vault/`

## Security Notes

- API key is stored in plugin config, not in environment variables
- API only binds to localhost
- API is only active when Obsidian is running
- Do not expose the API key in logs or error messages
- All LLM operations go through opencode — no external AI services configured in Obsidian
