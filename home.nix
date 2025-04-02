{ pkgs, ... }:
{
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
  };

  home.packages = with pkgs; [
    pkgs.direnv
    pkgs.zoxide
    pkgs.git
    pkgs.nixfmt-tree
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
    pkgs.zsh
    pkgs.kubecolor
    pkgs.kubectl
    pkgs.kubelogin-oidc
  ];

  home.file.".gitconfig".source = ./.gitconfig;
  home.file.".kube/kubie.yaml".source = ./kubie.yaml;
  home.file.".config/starship.toml".source = ./starship.toml;
  home.file.".config/rbw/config.json".source = ./rbw-config.json;
  home.file.".config/ck8s-devbox/credentials-helper.bash".source = ./credentials-helper.bash;
  home.file.".config/zsh/.zshrc".source = ./.zshrc;
  home.file.".config/zsh/.zshrc.d".source = ./.zshrc.d;
}
