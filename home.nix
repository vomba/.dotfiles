{ pkgs, ... }:
{
  programs.home-manager.enable = true;
  # programs.git.enable = true;
  # programs.git.includes = [
  #   { path = ".gitconfig"; }
  # ];

  home.packages = with pkgs; [
    pkgs.direnv
    pkgs.zoxide
    pkgs.git
    pkgs.nixfmt-tree
    pkgs.nil
  ];

  home.file.".gitconfig".source = ./.gitconfig;
}
