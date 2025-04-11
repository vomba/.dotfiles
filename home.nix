{
  pkgs,
  nixGL,
  config,
  lib,
  inputs,
  ...
}:
{
  fonts.fontconfig.enable = true;

  nixGL = {
    packages = nixGL.packages;
    defaultWrapper = "mesa";
  };

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    oh-my-zsh.enable = true;
  };

  programs.fzf.enable = true;
  programs.bat.enable = true;

  programs.helix = {
    enable = true;
    languages = {
      language = [
        {
          name = "nix";
          file-types = [ "nix" ];
          formatter = {
            command = "nixfmt";
          };
        }
      ];
    };
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    package = (config.lib.nixGL.wrap pkgs.kitty);
  };

  home.packages = [
    pkgs.direnv
    pkgs.zoxide
    pkgs.git
    pkgs.nixfmt-rfc-style
    pkgs.nil
    pkgs.pre-commit
    pkgs.kubie
    pkgs.kind
    pkgs.gh
    pkgs.sops
    pkgs.starship
    pkgs.go
    pkgs.yq-go
    pkgs.jq
    pkgs.bitwarden-cli
    pkgs.bash-language-server
    pkgs.clusterctl
    pkgs.openstackclient-full
    pkgs.kubernetes-helm
    pkgs.helmfile
    pkgs.rbw
    pkgs.kubecolor
    pkgs.kubectl
    pkgs.kubelogin-oidc
    pkgs.eza
    pkgs.awscli2
    pkgs.azure-cli
    pkgs.azure-storage-azcopy
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.sonobuoy
    pkgs.yaml-language-server
    pkgs.helm-ls
    pkgs.velero
    pkgs.marksman
    pkgs.glow
    pkgs.jq-lsp
  ];

  home.file.".gitconfig".source = ./.gitconfig;
  home.file.".kube/kubie.yaml".source = ./kubie.yaml;
  home.file.".config/starship.toml".source = ./starship.toml;
  home.file.".config/rbw/config.json".source = ./rbw-config.json;
  home.file.".config/ck8s-devbox/credentials-helper.bash".source = ./credentials-helper.bash;
  home.file.".config/zsh/.zshrc".source = ./.zshrc;
  home.file.".config/zsh/.zshrc.d".source = ./.zshrc.d;
  home.file.".config/fontconfig/conf.d/10-nix-fonts.conf".source = ./10-nix-fonts.conf;
}
