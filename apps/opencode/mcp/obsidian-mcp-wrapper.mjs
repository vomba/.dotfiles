#!/usr/bin/env node
import { spawn } from "child_process";
import { createInterface } from "readline";

// Spawn obsidian-mcp-server with latest version
const server = spawn("npx", ["-y", "obsidian-mcp-server@latest"], {
  stdio: ["pipe", "pipe", "inherit"],
  env: {
    ...process.env,
    OBSIDIAN_API_KEY: "obsidian-local-rest-api-key",
    OBSIDIAN_BASE_URL: "https://127.0.0.1:27124",
    OBSIDIAN_VERIFY_SSL: "false",
  },
});

// Pipe stdin to server first — must be before the readline loop
// or stdin never connects (the for-await loop blocks forever).
process.stdin.pipe(server.stdin);

const rl = createInterface({ input: server.stdout });
for await (const line of rl) {
  try {
    const msg = JSON.parse(line);
    process.stdout.write(JSON.stringify(msg) + "\n");
  } catch {
    process.stdout.write(line + "\n");
  }
}
