{
  pkgs,
  pkgs-stable,
  pkgs-25,
  nixGL,
  config,
  lib,
  inputs,
  nur,
  ...
}:
{

  home.username = "hani";
  home.homeDirectory = "/home/hani";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;

  xdg.configFile."environment.d/envvars.conf".text = ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';

  nixGL = {
    packages = nixGL.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = false;
  };

  nixpkgs = {
    overlays = [
      nur.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  imports = [
    ./modules/hyprland.nix
    ./modules/kanshi.nix
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/firefox.nix
    ./modules/editors.nix
    ./modules/shell.nix
    ./modules/dev.nix
    ./modules/kubernetes.nix
    ./modules/gui.nix
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
