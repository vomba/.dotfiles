{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.dotfiles.apps.zed;
  opencodeKeyPath = config.sops.secrets.opencode_api_key.path;
in
{
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = if pkgs.stdenv.isLinux then pkgs.zed-editor-fhs else pkgs.zed-editor;

      enableMcpIntegration = true;

      extensions = [
        "nix"
        "go"
        "docker"
        "docker-compose"
        "terraform"
        "helm"
        "toml"
        "yaml"
        "json"
        "markdown-preview"
        "catppuccin"
      ];

      userSettings = {
        theme = "Catppuccin Mocha";
        ui_font_size = 14;
        buffer_font_size = 14;
        buffer_font_family = "JetBrains Mono";
        relative_line_numbers = true;
        cursor_blink = true;
        tab_size = 2;
        soft_wrap = "editor_width";
        format_on_save = "on";
        vim_mode = false;
        git = {
          builtin = false;
        };
        features = {
          copilot = false;
          inline_completion_provider = "none";
        };
        telemetry = {
          metrics = false;
        };
        agent = {
          tool_permissions = {
            default = "confirm";
            tools = {
              terminal = {
                default = "confirm";
                always_allow = [
                  { pattern = "^git\\s+(status|log|diff|add)"; }
                  { pattern = "^nix\\s+run"; }
                  { pattern = "^nixfmt"; }
                  { pattern = "^cargo\\s+(build|test|check)"; }
                ];
              };
            };
          };
        };
        agent_servers = {
          OpenCode = {
            inheritCommand = false;
            command = "opencode";
            args = [ "acp" ];
          };
        };
      };

      extraPackages = with pkgs; [
        nixd
        gopls
        marksman
        yaml-language-server
        vscode-json-languageserver
        terraform-ls
        helm-ls
        bash-language-server
        openssh
      ];

      defaultEditor = false;
    };

    home.activation.injectOpenCodeKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p "${config.xdg.configHome}/environment.d"
            if [ -f "${opencodeKeyPath}" ]; then
              key=$(cat "${opencodeKeyPath}")
              cat > "${config.xdg.configHome}/environment.d/opencode.conf" << EOF
      OPENCODE_API_KEY=$key
      EOF
            fi
    '';
  };
}
