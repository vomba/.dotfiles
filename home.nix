{
  pkgs,
  pkgs-stable,
  pkgs-25,
  config,
  lib,
  inputs,
  nur,
  ...
}:
{

  home.username = if pkgs.stdenv.isLinux then "hani" else "vomba";
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/hani" else "/Users/vomba";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  imports = [
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/firefox.nix
    ./modules/editors.nix
    ./modules/shell.nix
    ./modules/dev.nix
    ./modules/kubernetes.nix
    ./modules/gui.nix
    ./modules/yazi.nix
    ./modules/gpg.nix
    ./modules/packages.nix
    ./modules/cloud.nix
    ./modules/lsp.nix
    ./modules/ai.nix
  ];

  programs.gemini-cli = {
    enable = true;
    # settings = {
    #   tools = {
    #     sandbox = "docker";
    #   };
    # };
  };

  # home.file.".gitconfig".source = ./.gitconfig;

}
