{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf optionalAttrs;
  cfg = config.profiles.user;
in
{
  config = mkIf cfg.enable {
    home.sessionVariables = {
      GOPATH = "${config.home.homeDirectory}/.go";
      KREW_ROOT = "${config.home.homeDirectory}/.krew";
    }
    // optionalAttrs (config.sops.secrets ? gcp-project) {
      GOOGLE_CLOUD_PROJECT = config.sops.secrets.gcp-project.raw or "elastisys-vertex-poc";
    };

    home.sessionPath = [
      "${config.home.homeDirectory}/.go/bin"
      "${config.home.homeDirectory}/.krew/bin"
    ];

    programs.zsh = {
      enable = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      shellAliases = {
        cat = "bat";
        yq4 = "yq";
      };
      initContent = ''
        compdef kubecolor=kubectl
      '';
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        custom = "${config.home.homeDirectory}/.dotfiles/oh-my-zsh";
        plugins = [
          "git"
          "fzf"
          "gh"
          "helm"
          "zsh-kubecolor"
          "golang"
          "terraform"
          "aws"
          "pip"
          "python"
          "docker"
          "zoxide"
          "eza"
          "azure"
        ];
      };
    };
  };
}
