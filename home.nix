{ pkgs, ... }:
{
  programs.home-manager.enable = true;
  # programs.git.enable = true;
  # programs.git.includes = [
  #   { path = ".gitconfig"; }
  # ];

  home.file.".\\gitconfig".source = ./gitconfig;

  home.packages = with pkgs; [
    pkgs.cowsay
    pkgs.direnv
    pkgs.zoxide
    pkgs.git
    pkgs.nixfmt-tree
    pkgs.nil
  ];

}
