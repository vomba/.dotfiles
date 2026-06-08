{ lib, ... }:
{
  options.dotfiles = {
    desktop = {
      enable = lib.mkEnableOption "desktop environment (niri, kanshi, GUI apps)" // {
        default = true;
      };
      hyprland = {
        enable = lib.mkEnableOption "Hyprland WM" // {
          default = false;
        };
      };
      niri = {
        enable = lib.mkEnableOption "niri WM" // {
          default = true;
        };
      };
    };
    dev = {
      enable = lib.mkEnableOption "development tools (Go, misc)" // {
        default = true;
      };
      kubernetes = {
        enable = lib.mkEnableOption "Kubernetes tooling" // {
          default = true;
        };
      };
      cloud = {
        enable = lib.mkEnableOption "Cloud CLI tools (AWS, Azure, Terraform)" // {
          default = true;
        };
      };
      lsp = {
        enable = lib.mkEnableOption "LSP servers" // {
          default = true;
        };
      };
      ai = {
        enable = lib.mkEnableOption "AI/LLM tools (OpenCode, ECC)" // {
          default = true;
        };
        observer = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable the continuous-learning-v2 background observer agent";
          };
          runIntervalMinutes = lib.mkOption {
            type = lib.types.int;
            default = 5;
            description = "How often the observer runs analysis (minutes)";
          };
          minObservations = lib.mkOption {
            type = lib.types.int;
            default = 20;
            description = "Minimum observations before observer runs analysis";
          };
        };
      };
    };
    shell = {
      enable = lib.mkEnableOption "shell environment (fzf, bat, zoxide, eza, starship)" // {
        default = true;
      };
      zsh = {
        enable = lib.mkEnableOption "Zsh configuration" // {
          default = true;
        };
      };
      git = {
        enable = lib.mkEnableOption "Git configuration" // {
          default = true;
        };
      };
      gpg = {
        enable = lib.mkEnableOption "GPG agent configuration" // {
          default = true;
        };
      };
    };
    apps = {
      enable = lib.mkEnableOption "misc packages" // {
        default = true;
      };
      firefox = {
        enable = lib.mkEnableOption "Firefox browser" // {
          default = true;
        };
      };
      editors = {
        enable = lib.mkEnableOption "Code editors (Helix)" // {
          default = true;
        };
      };
      zed = {
        enable = lib.mkEnableOption "Zed editor" // {
          default = true;
        };
      };
      yazi = {
        enable = lib.mkEnableOption "Yazi file manager" // {
          default = true;
        };
      };
      obsidian = {
        enable = lib.mkEnableOption "Obsidian note-taking" // {
          default = true;
        };
      };
    };
  };
}
