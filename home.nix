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

  home.username = "hani";
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/hani" else "/Users/hani";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';

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
