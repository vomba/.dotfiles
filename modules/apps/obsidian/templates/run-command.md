<%*
const command = await tp.system.prompt("Enter CLI Command (e.g., ls, git status)");
if (command) {
  const output = await tp.system.execute(command);
  tR += "### Output of `" + command + "`\n" + "```bash\n" + output + "\n```";
}
%>
