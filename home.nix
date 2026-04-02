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

let
  # Home directory path
  homeDir = if pkgs.stdenv.isLinux then "/home/hani" else "/Users/vomba";
in
{

  home.username = if pkgs.stdenv.isLinux then "hani" else "vomba";
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  imports = [
    inputs.sops-nix.homeManagerModules.default
    ./modules/profiles/user.nix
    ./modules/core
    ./modules/dev
    ./modules/cloud
    ./modules/security
    ./modules/ai
    ./modules/cli
  ];

  # SOPS secrets configuration
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml.age;
    gnupg = {
      home = "${homeDir}/.gnupg";
    };
  };

  # User profile configuration
  profiles.user = {
    enable = true;
  };

  programs.gemini-cli = {
    enable = true;
  };

}
