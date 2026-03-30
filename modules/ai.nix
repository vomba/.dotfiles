{
  pkgs,
  pkgs-stable,
  inputs,
  lib,
  config,
  ...
}:
let
  eccRepo = inputs.everything-claude-code;
  eccConfig = builtins.fromJSON (builtins.readFile "${eccRepo}/.opencode/opencode.json");
  homeDir = config.home.homeDirectory;
  configDir = "${homeDir}/.config/opencode";

  reasoningModel = "opencode-go/glm-5";
  codeModel = "opencode-go/minimax-2.7";

  reasoningAgents = [
    "architect"
    "planner"
    "code-reviewer"
    "security-reviewer"
    "database-reviewer"
    "go-reviewer"
    "tdd-guide"
  ];

  codeAgents = [
    "build"
    "build-error-resolver"
    "refactor-cleaner"
    "e2e-runner"
    "doc-updater"
    "go-build-resolver"
  ];

  getModelForAgent = agentName:
    if lib.elem agentName reasoningAgents then reasoningModel
    else if lib.elem agentName codeAgents then codeModel
    else reasoningModel;

  processConfig =
    agentName: value:
    if lib.isAttrs value then
      lib.mapAttrs (
        name: val:
        if name == "model" || name == "small_model" then
          getModelForAgent agentName
        else if lib.isString val then
          lib.replaceStrings [ "{file:" ] [ "{file:${configDir}/" ] val
        else
          processConfig agentName val
      ) value
    else if lib.isList value then
      map (v: processConfig agentName v) value
    else
      value;

  mergedAgents = lib.mapAttrs (name: config: processConfig name config) (eccConfig.agent or { });
  mergedCommands = processConfig "command" (eccConfig.command or { });
  mergedInstructions = map (path: "${configDir}/${path}") (eccConfig.instructions or [ ]);

in
{
  programs.opencode = {
    enable = true;
    settings = {
      model = codeModel;
      small_model = reasoningModel;
      default_agent = eccConfig.default_agent or "build";
      instructions = mergedInstructions;
      plugin = [ "${configDir}/.opencode/plugins" ];
      agent = mergedAgents;
      command = mergedCommands;
    };
  };
  

  # Everything Claude Code (ECC) plugin configuration
  home.file.".config/opencode/.opencode" = {
    source = "${eccRepo}/.opencode";
    force = true;
  };
  # Symlink context and scripts too as they might be needed by instructions or hooks
  home.file.".config/opencode/scripts" = {
    source = "${eccRepo}/scripts";
    force = true;
  };
  home.file.".config/opencode/skills" = {
    source = "${eccRepo}/skills";
    force = true;
  };
  home.file.".config/opencode/rules" = {
    source = "${eccRepo}/rules";
    force = true;
  };
  home.file.".config/opencode/contexts" = {
    source = "${eccRepo}/contexts";
    force = true;
  };
  home.file.".config/opencode/prompts/agents" = {
    source = "${eccRepo}/.opencode/prompts/agents";
    force = true;
  };
    home.file.".config/opencode/commands" = {
    source = "${eccRepo}/.opencode/commands";
    force = true;
  };
  home.file.".config/opencode/AGENTS.md" = {
    source = "${eccRepo}/AGENTS.md";
    force = true;
  };
  home.file.".config/opencode/CONTRIBUTING.md" = {
    source = "${eccRepo}/CONTRIBUTING.md";
    force = true;
  };

  home.file.".claude/rules" = {
    source = "${eccRepo}/rules";
    force = true;
  };

  home.packages = [ ];
}
