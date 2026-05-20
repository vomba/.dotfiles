{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  eccPkg = inputs.ecc-universal;
  homeDir = config.home.homeDirectory;
  configDir = "${homeDir}/.config/opencode";

  # Model assignments — mirrors upstream's intentional routing
  # Upstream uses opus for reviewers, sonnet for builders
  reasoningModel = "opencode-go/deepseek-v4-pro";
  codeModel = "opencode-go/deepseek-v4-flash";

  # Agent model map — reviewers use reasoning model, builders use code model
  agentModels = {
    # Reviewers (upstream: opus)
    "architect" = reasoningModel;
    "planner" = reasoningModel;
    "code-reviewer" = reasoningModel;
    "security-reviewer" = reasoningModel;
    "database-reviewer" = reasoningModel;
    "go-reviewer" = reasoningModel;
    "python-reviewer" = reasoningModel;
    "rust-reviewer" = reasoningModel;
    "cpp-reviewer" = reasoningModel;
    "java-reviewer" = reasoningModel;
    "kotlin-reviewer" = reasoningModel;
    "tdd-guide" = reasoningModel;

    # Builders/fixers (upstream: sonnet)
    "build" = codeModel;
    "build-error-resolver" = codeModel;
    "refactor-cleaner" = codeModel;
    "e2e-runner" = codeModel;
    "doc-updater" = codeModel;
    "go-build-resolver" = codeModel;
    "rust-build-resolver" = codeModel;
    "cpp-build-resolver" = codeModel;
    "java-build-resolver" = codeModel;
    "kotlin-build-resolver" = codeModel;

    # Ops agents
    "loop-operator" = reasoningModel;
    "harness-optimizer" = reasoningModel;
    "docs-lookup" = reasoningModel;
  };

  # Read upstream config once
  upstreamConfig = builtins.fromJSON (builtins.readFile "${eccPkg}/.opencode/opencode.json");

  # Rewrite {file: paths to point to our configDir
  rewritePaths =
    value:
    if lib.isString value then
      lib.replaceStrings [ "{file:" ] [ "{file:${configDir}/" ] value
    else if lib.isAttrs value then
      lib.mapAttrs (_: rewritePaths) value
    else if lib.isList value then
      map rewritePaths value
    else
      value;

  # Process agents: override model, rewrite paths
  processAgent =
    name: agentCfg:
    (rewritePaths agentCfg)
    // {
      model = agentModels.${name} or reasoningModel;
    };

  mergedAgents = lib.mapAttrs processAgent (upstreamConfig.agent or { });

  # Process commands: rewrite paths only
  mergedCommands = rewritePaths (upstreamConfig.command or { });

  # Skills actually referenced in instructions — only symlink these
  neededSkills = [
    "tdd-workflow"
    "security-review"
    "coding-standards"
    "frontend-patterns"
    "frontend-slides"
    "backend-patterns"
    "e2e-testing"
    "verification-loop"
    "api-design"
    "strategic-compact"
    "eval-harness"
    "obsidian-brain"
    "continuous-learning-v2"

    # Go
    "golang-patterns"
    "golang-testing"

    # Python
    "python-patterns"
    "python-testing"

    # Cross-platform mobile
    "dart-flutter-patterns"
    "compose-multiplatform-patterns"

    # Web / design
    "frontend-design"

    # DevOps / infra
    "docker-patterns"
    "deployment-patterns"
    "postgres-patterns"
    "database-migrations"
    "mcp-server-patterns"
    "autonomous-loops"
    "agent-harness-construction"
    "clickhouse-io"
    "terminal-ops"
    "search-first"
  ];

  # Instructions with absolute paths (opencode resolves these)
  mergedInstructions = [
    "${configDir}/AGENTS.md"
    # "${configDir}/CONTRIBUTING.md"  # not in npm package
    "${configDir}/nix-rules.md"
    "${configDir}/learnings.md"
    "${configDir}/instincts.md"
    "${configDir}/skills/tdd-workflow/SKILL.md"
    "${configDir}/skills/security-review/SKILL.md"
    "${configDir}/skills/coding-standards/SKILL.md"
    "${configDir}/skills/frontend-patterns/SKILL.md"
    "${configDir}/skills/frontend-slides/SKILL.md"
    "${configDir}/skills/backend-patterns/SKILL.md"
    "${configDir}/skills/e2e-testing/SKILL.md"
    "${configDir}/skills/verification-loop/SKILL.md"
    "${configDir}/skills/api-design/SKILL.md"
    "${configDir}/skills/strategic-compact/SKILL.md"
    "${configDir}/skills/eval-harness/SKILL.md"
    "${configDir}/skills/obsidian-brain/SKILL.md"
    "${configDir}/skills/continuous-learning-v2/SKILL.md"

    # Go
    "${configDir}/skills/golang-patterns/SKILL.md"
    "${configDir}/skills/golang-testing/SKILL.md"

    # Python
    "${configDir}/skills/python-patterns/SKILL.md"
    "${configDir}/skills/python-testing/SKILL.md"

    # Cross-platform mobile
    "${configDir}/skills/dart-flutter-patterns/SKILL.md"
    "${configDir}/skills/compose-multiplatform-patterns/SKILL.md"

    # Web / design
    "${configDir}/skills/frontend-design/SKILL.md"

    # DevOps / infra
    "${configDir}/skills/docker-patterns/SKILL.md"
    "${configDir}/skills/deployment-patterns/SKILL.md"
    "${configDir}/skills/postgres-patterns/SKILL.md"
    "${configDir}/skills/database-migrations/SKILL.md"
    "${configDir}/skills/mcp-server-patterns/SKILL.md"
    "${configDir}/skills/autonomous-loops/SKILL.md"
    "${configDir}/skills/agent-harness-construction/SKILL.md"
    "${configDir}/skills/clickhouse-io/SKILL.md"
    "${configDir}/skills/terminal-ops/SKILL.md"
    "${configDir}/skills/search-first/SKILL.md"
  ];

  # Path to the context7 API key from sops (known at build time)
  context7KeyPath = config.sops.secrets.context7_api_key.path;

  # Wrapper script for context7 MCP that reads the API key from sops
  context7Wrapper = pkgs.writeShellScriptBin "context7-mcp" ''
    CONTEXT7_API_KEY="$(cat ${context7KeyPath})" exec \
      npx -y "@upstash/context7-mcp@latest" "$@"
  '';

  # Build the complete home.file attrset — all entries merged together
  homeFiles = {
    ".config/opencode/.opencode" = {
      source = "${eccPkg}/.opencode";
      force = true;
    };
    ".config/opencode/commands" = {
      source = "${eccPkg}/.opencode/commands";
      force = true;
    };
    ".config/opencode/prompts" = {
      source = "${eccPkg}/.opencode/prompts";
      force = true;
    };
    ".config/opencode/AGENTS.md" = {
      source = "${eccPkg}/AGENTS.md";
      force = true;
    };
    # CONTRIBUTING.md not in npm package — omitted
    ".config/opencode/rules" = {
      source = "${eccPkg}/rules";
      force = true;
    };
    ".claude/rules" = {
      source = "${eccPkg}/rules";
      force = true;
    };
    ".config/opencode/nix-rules.md" = {
      text = builtins.readFile ../../rules/nix-configuration.md;
      force = true;
    };
    ".config/opencode/learnings.md" = {
      text = builtins.readFile ../../learnings/LEARNINGS.md;
      force = true;
    };
    ".config/opencode/instincts.md" = {
      text = builtins.readFile ../../learnings/INSTINCTS.md;
      force = true;
    };
  }
  //
    lib.genAttrs
      (map (s: ".config/opencode/skills/${s}") (lib.filter (s: s != "obsidian-brain") neededSkills))
      (path: {
        source = "${eccPkg}/skills/${lib.last (lib.splitString "/" path)}";
        force = true;
      })
  // {
    ".config/opencode/skills/obsidian-brain" = {
      source = ../apps/obsidian/skills/obsidian-brain;
      force = true;
    };
  };

  instinctWrapper = pkgs.writeShellScriptBin "instinct" ''
    exec python3 "${configDir}/skills/continuous-learning-v2/scripts/instinct-cli.py" "$@"
  '';

in
{
  config = lib.mkIf config.dotfiles.dev.ai.enable {
    # ── OpenCode declarative config ──────────────────────────────────
    programs.opencode = {
      enable = true;
      settings = {
        model = codeModel;
        small_model = reasoningModel;
        default_agent = "build";
        instructions = mergedInstructions;
        plugin = [ "${configDir}/.opencode/plugins" ];
        agent = mergedAgents;
        command = mergedCommands;
        permission = {
          "mcp_*" = "ask";
        };
        mcp = {
          context7 = {
            type = "local";
            command = [ "${context7Wrapper}/bin/context7-mcp" ];
          };
        };
        lsp = {
          marksman = {
            command = [ "marksman" ];
            extensions = [ ".md" ];
          };
          typos-lsp = {
            command = [ "typos-lsp" ];
            extensions = [
              ".nix"
              ".rs"
              ".py"
              ".go"
              ".ts"
              ".tsx"
              ".js"
              ".sh"
              ".md"
              ".toml"
              ".yaml"
              ".yml"
              ".json"
            ];
          };
          jq-lsp = {
            command = [ "jq-lsp" ];
            extensions = [ ".jq" ];
          };
          helm-ls = {
            command = [
              "helm_ls"
              "serve"
            ];
            extensions = [
              ".yaml"
              ".yml"
              ".tpl"
            ];
          };
          vscode-json = {
            command = [
              "vscode-json-languageserver"
              "--stdio"
            ];
            extensions = [ ".json" ];
          };
        };
      };
    };

    # ── File symlinks (skills, plugin, docs, rules) ──────────────────
    home.file = homeFiles;

    # ── Session environment ─────────────────────────────────────────
    home.sessionVariables = {
      CLAUDE_PLUGIN_ROOT = configDir;
    };

    # ── Homunculus: consolidate instinct store under opencode ───────
    home.activation.setupHomunculus = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      NEW_HOME="${configDir}/homunculus"
      OLD_HOME="$HOME/.claude/homunculus"
      mkdir -p "$NEW_HOME"/{instincts/{personal,inherited},evolved/{skills,commands,agents},projects}
      if [ -d "$OLD_HOME" ] && [ ! -L "$OLD_HOME" ]; then
        cp -r "$OLD_HOME"/. "$NEW_HOME"/ 2>/dev/null || true
        rm -rf "$OLD_HOME"
      fi
      if [ ! -L "$OLD_HOME" ]; then
        ln -sf "$NEW_HOME" "$OLD_HOME"
      fi
    '';

    # ── Packages ─────────────────────────────────────────────────────
    home.packages = [
      context7Wrapper
      instinctWrapper
    ];
  };
}
