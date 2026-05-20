import { execSync } from "child_process";
import * as path from "path";
import * as fs from "fs";
import * as os from "os";

const observePlugin = async ({ worktree }) => {
  const log = (level, message) =>
    console.log(`[observe] ${level}: ${message}`);

  const xdgConfig = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config");
  const configDir = path.join(xdgConfig, "opencode");

  const callObserve = async (hookPhase, tool, args) => {
    const script = path.join(
      configDir,
      "skills/continuous-learning-v2/hooks/observe.sh"
    );
    if (!fs.existsSync(script)) return;

    const projectRoot = worktree || configDir;
    const sessionId = process.env.OPENCODE_SESSION_ID || "opencode";

    const input = JSON.stringify({
      tool_name: tool,
      tool_input: args || {},
      cwd: projectRoot,
      session_id: sessionId,
    });

    try {
      execSync(`bash "${script}" "${hookPhase}"`, {
        input,
        env: {
          ...process.env,
          CLAUDE_CODE_ENTRYPOINT: "cli",
          CLV2_CONFIG: path.join(configDir, "homunculus/observer-config.json"),
          PROJECT_ROOT: projectRoot,
        },
        timeout: 5000,
        stdio: ["pipe", "ignore", "ignore"],
      });
    } catch (e) {
      log("debug", `observe.sh skipped: ${e.message}`);
    }
  };

  return {
    "tool.execute.before": async (input) => {
      await callObserve("pre", input.tool, input.args);
    },

    "tool.execute.after": async (input) => {
      await callObserve("post", input.tool, input.args);
    },

    "session.created": async () => {
      await callObserve("post", "session.created", {});
    },

    "session.deleted": async () => {
      await callObserve("post", "session.deleted", {});
    },
  };
};

export default observePlugin;
