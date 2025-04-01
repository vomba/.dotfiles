{ pkgs, ... }:
{
  programs.home-manager.enable = true;

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
  ];

  home.file.".gitconfig".source = ./.gitconfig;
  home.file.".kube/kubie.yaml".source = ./kubie.yaml;
  home.file.".config/starship.toml".source = ./starship.toml;
  home.file.".config/rbw/config.json".source=./rbw-config.json;
  home.file.".config/ck8s-devbox/credentials-helper.bash".source=./credentials-helper.bash;
}
