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
  homunculusDir = "${homeDir}/.dotfiles/apps/opencode/homunculus";

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
    "helmfile-contribution"

    # Optimization (v2.0.0-rc.1)
    "parallel-execution-optimizer"
    "benchmark-optimization-loop"
    "data-throughput-accelerator"
    "latency-critical-systems"
    "recursive-decision-ledger"

    # Research / ops
    "deep-research"
    "workspace-surface-audit"
    "knowledge-ops"
    "continuous-agent-loop"
    "github-ops"
    "research-ops"

    # Crossplane
    "crossplane-e2e"
  ];

  # Instructions with absolute paths (opencode resolves these)
  mergedInstructions = [
    "${configDir}/AGENTS.md"
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

    # User-contributed (derived from git history analysis)
    "${configDir}/skills/helmfile-contribution/SKILL.md"

    # Optimization (v2.0.0-rc.1)
    "${configDir}/skills/parallel-execution-optimizer/SKILL.md"
    "${configDir}/skills/benchmark-optimization-loop/SKILL.md"
    "${configDir}/skills/data-throughput-accelerator/SKILL.md"
    "${configDir}/skills/latency-critical-systems/SKILL.md"
    "${configDir}/skills/recursive-decision-ledger/SKILL.md"

    # Research / ops
    "${configDir}/skills/deep-research/SKILL.md"
    "${configDir}/skills/workspace-surface-audit/SKILL.md"
    "${configDir}/skills/knowledge-ops/SKILL.md"
    "${configDir}/skills/continuous-agent-loop/SKILL.md"
    "${configDir}/skills/github-ops/SKILL.md"
    "${configDir}/skills/research-ops/SKILL.md"

    # Crossplane
    "${configDir}/skills/crossplane-e2e/SKILL.md"
  ];

  # Commands with namespaced agent frontmatter stripped.
  # Upstream ECC command .md files declare agent: "everything-claude-code:<name>"
  # in YAML frontmatter. If loaded, this overrides the non-namespaced agent
  # reference in the main opencode.json command section. Stripping the agent
  # line ensures commands resolve to the agents defined in opencode.json.
  # If upstream changes the frontmatter format, this sed may need updating.
  eccCommands = pkgs.runCommand "ecc-commands" { } ''
    mkdir -p $out
    for f in ${eccPkg}/.opencode/commands/*.md; do
      base=$(basename "$f")
      sed '/^---$/,/^---$/ { /^agent:/d; }' "$f" > "$out/$base"
    done
    # Include obsidian-second-brain commands (explicit vault ops only, not research)
    for f in ${inputs.obsidian-second-brain}/commands/obsidian-*.md ${inputs.obsidian-second-brain}/commands/create-command.md; do
      base=$(basename "$f")
      cp "$f" "$out/$base"
    done
  '';

  # Build the complete home.file attrset — all entries merged together
  homeFiles = {
    ".config/opencode/commands" = {
      source = eccCommands;
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
    # ECC plugin (compiled hooks) — the .opencode/opencode.json is NOT loaded.
    # Only the compiled JS plugin is used, which provides tool.execute.before/after
    # hooks for prettier, typecheck, console.log audit, etc.
    ".config/opencode/plugins/ecc" = {
      source = eccPlugin;
      force = true;
    };
    # Observation plugin — captures tool events for continuous-learning-v2 instincts
    ".config/opencode/plugins/observe" = {
      source = ../../apps/opencode/plugins/observe;
      force = true;
    };
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
    # Writable observer config override — enables continuous-learning observer
    # (the default config.json in the nix store has enabled: false)
    ".config/opencode/homunculus/observer-config.json" = {
      text = builtins.toJSON {
        version = "2.1";
        observer = {
          enabled = config.dotfiles.dev.ai.observer.enable;
          run_interval_minutes = config.dotfiles.dev.ai.observer.runIntervalMinutes;
          min_observations_to_analyze = config.dotfiles.dev.ai.observer.minObservations;
        };
      };
      force = true;
    };
  }
  //
    lib.genAttrs
      (map (s: ".config/opencode/skills/${s}") (
        lib.filter (
          s: s != "helmfile-contribution" && s != "continuous-learning-v2" && s != "crossplane-e2e"
        ) neededSkills
      ))
      (path: {
        source = "${eccPkg}/skills/${lib.last (lib.splitString "/" path)}";
        force = true;
      })
  // {
    # Local (non-ECC) skills — must be filtered from genAttrs above.
    # To add a new local skill:
    #   1. Create ~/.dotfiles/apps/opencode/skills/<name>/SKILL.md
    #   2. Add "<name>" to neededSkills
    #   3. Filter it in the genAttrs above (add && s != "<name>")
    #   4. Add home.file entry below
    #   5. Add "${configDir}/skills/<name>/SKILL.md" to mergedInstructions
    # obsidian-second-brain — on-demand skill (not in mergedInstructions).
    # The agent loads it via skill({ name: "obsidian-second-brain" }) when
    # the user mentions vault/note operations.
    ".config/opencode/skills/obsidian-second-brain" = {
      source = inputs.obsidian-second-brain;
      force = true;
    };
    ".config/opencode/skills/helmfile-contribution" = {
      source = ../../apps/opencode/skills/helmfile-contribution;
      force = true;
    };
    ".config/opencode/skills/crossplane-e2e" = {
      source = ../../apps/opencode/skills/crossplane-e2e;
      force = true;
    };
    # Patched continuous-learning-v2 — observer-loop.sh uses absolute paths
    # so opencode run resolves them correctly from PROJECT_DIR
    ".config/opencode/skills/continuous-learning-v2" = {
      source = patchedClv2Skill;
      force = true;
    };
  };

  # Patched ECC plugin — removes the changed-files tool import that fails
  # because @opencode-ai/plugin/tool can't be resolved from the Nix store path.
  eccPlugin = pkgs.runCommand "ecc-plugin" { buildInputs = [ pkgs.gnused ]; } ''
    mkdir -p $out
    cp -r ${eccPkg}/.opencode/dist/plugins/* $out/
    sed -i 's|import changedFilesTool from "../tools/changed-files.js";||' $out/ecc-hooks.js
    sed -i '/"changed-files": changedFilesTool/d' $out/ecc-hooks.js
  '';

  # Patched observer-loop.sh — upstream uses relative paths (.observer-tmp/filename)
  # for Windows compat, but opencode run resolves relative paths from PROJECT_ROOT
  # (git root) instead of PROJECT_DIR (homunculus project dir). Patching to absolute
  # paths fixes this for Linux.
  patchedClv2Skill = pkgs.runCommand "clv2-patched" { buildInputs = [ pkgs.gnused ]; } ''
    cp -r ${eccPkg}/skills/continuous-learning-v2 $out
    chmod -R +w $out
    substituteInPlace $out/agents/observer-loop.sh \
      --replace-fail '.observer-tmp/$(basename "$analysis_file")' '$analysis_file'
  '';

  instinctWrapper = pkgs.writeShellScriptBin "instinct" ''
    exec python3 "${configDir}/skills/continuous-learning-v2/scripts/instinct-cli.py" "$@"
  '';

  # claude → opencode wrapper for the continuous-learning-v2 observer agent.
  # The upstream observer-loop.sh calls `claude --model haiku --max-turns N --print --allowedTools "..." -p "prompt"`
  # to analyze observations into instincts. We don't have claude CLI — translate the essential args
  # to `opencode run` so the observer actually analyzes observations instead of silently skipping.
  # Uses the cheap/flash model (matching upstream's haiku choice) since the observer runs
  # in the background and only needs basic pattern detection.
  claudeWrapper = pkgs.writeShellScriptBin "claude" ''
    PROMPT=""
    while [ $# -gt 0 ]; do
      case "$1" in
        -p) PROMPT="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    # --dangerously-skip-permissions: the observer needs to read temp analysis
    # files and write instinct files to homunculus. Auto-rejecting these would
    # silently prevent instinct creation.
    exec opencode run -m "${codeModel}" --pure --dangerously-skip-permissions "$PROMPT"
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
        # ECC plugin provides tool hooks (prettier, typecheck, console.log audit).
        # The observe plugin captures tool events for continuous-learning instinct extraction.
        # The compiled JS plugin (dist/plugins/) is loaded, not .opencode/opencode.json —
        # so there's no namespace conflict with agents defined in this config.
        plugin = [
          "${configDir}/plugins/ecc"
          "${configDir}/plugins/observe"
        ];
        agent = mergedAgents;
        command = mergedCommands;
        permission = {
          "mcp_*" = "ask";
          # CodeGraph tools are read-only — safe to auto-allow
          "mcp__codegraph__codegraph_search" = "allow";
          "mcp__codegraph__codegraph_context" = "allow";
          "mcp__codegraph__codegraph_callers" = "allow";
          "mcp__codegraph__codegraph_callees" = "allow";
          "mcp__codegraph__codegraph_impact" = "allow";
          "mcp__codegraph__codegraph_node" = "allow";
          "mcp__codegraph__codegraph_status" = "allow";
          "mcp__codegraph__codegraph_files" = "allow";
          # GitHub MCP — read-only tools auto-allowed, write tools default to "ask"
          "mcp__github__search_repositories" = "allow";
          "mcp__github__search_code" = "allow";
          "mcp__github__search_issues" = "allow";
          "mcp__github__search_users" = "allow";
          "mcp__github__get_file_contents" = "allow";
          "mcp__github__list_commits" = "allow";
          "mcp__github__list_issues" = "allow";
          "mcp__github__get_issue" = "allow";
          "mcp__github__get_pull_request" = "allow";
          "mcp__github__list_pull_requests" = "allow";
          "mcp__github__get_pull_request_files" = "allow";
          "mcp__github__get_pull_request_status" = "allow";
          "mcp__github__get_pull_request_comments" = "allow";
          "mcp__github__get_pull_request_reviews" = "allow";
        };
        mcp = {
          context7 = {
            type = "local";
            command = [ "context7-mcp" ];
          };
          codegraph = {
            type = "local";
            command = [ "codegraph-mcp" ];
          };
          obsidian = {
            type = "local";
            command = [ "obsidian-mcp" ];
          };
          github = {
            type = "local";
            command = [ "github-mcp" ];
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
      CLV2_CONFIG = "${configDir}/homunculus/observer-config.json";
      # File watcher native binding needs libstdc++.so.6 from the Nix GCC build closure
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    };

    # ── Homunculus: instinct store lives in the dotfiles repo ──────
    # so instincts are automatically synced to macOS (and other machines)
    # via git. Symlinked from ~/.claude/homunculus (where the instinct
    # CLI and observer scripts expect to find it).
    home.activation.setupHomunculus = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      NEW_HOME="${homunculusDir}"
      OLD_HOME="$HOME/.claude/homunculus"
      LEGACY_CONFIG="${configDir}/homunculus"

      mkdir -p "$NEW_HOME"/{instincts/{personal,inherited},evolved/{skills,commands,agents},projects}

      # Migrate from ~/.claude/homunculus (pre-symlink era)
      if [ -d "$OLD_HOME" ] && [ ! -L "$OLD_HOME" ]; then
        echo "[setupHomunculus] Migrating $OLD_HOME → $NEW_HOME"
        cp -r "$OLD_HOME"/. "$NEW_HOME"/ 2>/dev/null || true
        rm -rf "$OLD_HOME"
      fi

      # Migrate instinct/evolved data from previous configDir location
      if [ -d "$LEGACY_CONFIG" ] && [ ! -L "$LEGACY_CONFIG" ] && [ "$LEGACY_CONFIG" != "$NEW_HOME" ]; then
        for item in instincts evolved projects.json identity.json; do
          src="$LEGACY_CONFIG/$item"
          [ -e "$src" ] && cp -r "$src" "$NEW_HOME/" 2>/dev/null || true
        done
      fi

      # Always ensure symlink → dotfiles repo (target changed from configDir)
      ln -sfn "$NEW_HOME" "$OLD_HOME"
    '';

    # ── Packages ─────────────────────────────────────────────────────
    home.packages = [
      instinctWrapper
      claudeWrapper
    ];
  };
}
