{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  eccRepo = inputs.everything-claude-code;
  homeDir = config.home.homeDirectory;
  configDir = "${homeDir}/.config/opencode";
  eccOpencode = "${eccRepo}/.opencode";

  # Model assignments — mirrors upstream's intentional routing
  # Upstream uses opus for reviewers, sonnet for builders
  reasoningModel = "opencode-go/glm-5.1";
  codeModel = "opencode-go/qwen3.6-plus";

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
  upstreamConfig = builtins.fromJSON (builtins.readFile "${eccOpencode}/opencode.json");

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
  ];

  # Instructions with absolute paths (opencode resolves these)
  mergedInstructions = [
    "${configDir}/AGENTS.md"
    "${configDir}/CONTRIBUTING.md"
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
  ];

  # Build the complete home.file attrset — all entries merged together
  homeFiles = {
    ".config/opencode/.opencode" = {
      source = "${eccOpencode}";
      force = true;
    };
    ".config/opencode/commands" = {
      source = "${eccOpencode}/commands";
      force = true;
    };
    ".config/opencode/prompts" = {
      source = "${eccOpencode}/prompts";
      force = true;
    };
    ".config/opencode/AGENTS.md" = {
      source = "${eccRepo}/AGENTS.md";
      force = true;
    };
    ".config/opencode/CONTRIBUTING.md" = {
      source = "${eccRepo}/CONTRIBUTING.md";
      force = true;
    };
    ".config/opencode/rules" = {
      source = "${eccRepo}/rules";
      force = true;
    };
    ".claude/rules" = {
      source = "${eccRepo}/rules";
      force = true;
    };
  }
  //
    lib.genAttrs
      (map (s: ".config/opencode/skills/${s}") (lib.filter (s: s != "obsidian-brain") neededSkills))
      (path: {
        source = "${eccRepo}/skills/${lib.last (lib.splitString "/" path)}";
        force = true;
      })
  // {
    ".config/opencode/skills/obsidian-brain" = {
      source = ./obsidian/skills/obsidian-brain;
      force = true;
    };
  };

in
{
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
    };
  };

  # ── File symlinks (skills, plugin, docs, rules) ──────────────────
  home.file = homeFiles;

  # ── Packages ─────────────────────────────────────────────────────
  home.packages = [
    pkgs.nodejs_25
  ];
}
