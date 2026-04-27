<%*
const prompt = await tp.system.prompt("What should the AI do with this note? (e.g., summarize, suggest tags)");
const title = tp.file.title;
const content = tp.file.content;

if (prompt) {
  const agentPrompt = `I am currently in my Obsidian note titled "${title}". ${prompt}. Here is the content of the note:\n\n${content}`;
  // We use the opencode CLI via Templater's system execute
  const response = await tp.system.execute(`opencode --prompt "${agentPrompt}"`);
  tR += "\n\n### 🤖 Agent Response\n" + response;
}
%>
