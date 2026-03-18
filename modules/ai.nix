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

  # Override model names and resolve paths in the plugin's configuration
  processConfig =
    value:
    if lib.isAttrs value then
      lib.mapAttrs (
        name: val:
        if name == "model" || name == "small_model" then
          "opencode-go/kimi-k2.5"
        else if lib.isString val then
          lib.replaceStrings [ "{file:" ] [ "{file:${configDir}/" ] val
        else
          processConfig val
      ) value
    else if lib.isList value then
      map (v: processConfig v) value
    else
      value;

  mergedAgents = processConfig (eccConfig.agent or { });
  mergedCommands = processConfig (eccConfig.command or { });
  mergedInstructions = map (path: "${configDir}/${path}") (eccConfig.instructions or [ ]);

in
{
  programs.opencode = {
    enable = true;
    settings = {
      model = "opencode-go/kimi-k2.5";
      small_model = "opencode-go/kimi-k2.5";
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
