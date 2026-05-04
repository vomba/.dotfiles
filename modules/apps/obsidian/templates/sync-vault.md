<%*
const date = tp.date.now("YYYY-MM-DD HH:mm");
const message = await tp.system.prompt("Commit message (optional)", `vault sync: ${date}`);
const finalMessage = message || `vault sync: ${date}`;

new Notice("Syncing vault...");

try {
  // 1. Add changes
  await tp.system.execute("cd ~/.vault && git add -A");

  // 2. Commit (allow empty if no changes)
  const commitOutput = await tp.system.execute(`cd ~/.vault && git commit -m "${finalMessage}" --allow-empty`);

  // 3. Push if remote exists
  const hasRemote = await tp.system.execute("cd ~/.vault && git remote");
  if (hasRemote) {
    const pushOutput = await tp.system.execute("cd ~/.vault && git push");
    new Notice("Vault synced and pushed!");
    tR += "### Sync Success\n" + "```bash\n" + commitOutput + "\n" + pushOutput + "\n```";
  } else {
    new Notice("Vault committed locally (no remote).");
    tR += "### Sync Success (Local Only)\n" + "```bash\n" + commitOutput + "\n```";
  }
} catch (e) {
  new Notice("Sync failed! Check terminal.");
  tR += "### ❌ Sync Failed\n" + e;
}
%>
