{
  pkgs,
  pkgs-stable,
  config,
  lib,
  inputs,
  nur,
  obsidian-plugins,
  ...
}:
{

  home.username = if pkgs.stdenv.isLinux then "hani" else "vomba";
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/hani" else "/Users/vomba";
  home.stateVersion = "26.05";

  # Silence evaluation warnings for default changes in newer stateVersions
  gtk.gtk4.theme = config.gtk.theme;
  programs.firefox.configPath = ".mozilla/firefox";
  programs.yazi.shellWrapperName = "yy";

  nix.package = lib.mkIf pkgs.stdenv.isLinux pkgs.nix;
  nix.settings = {
    max-jobs = 4;
    min-free = "2G";
    max-free = "10G";
    auto-optimise-store = true;
    substituters = [
      "https://vomba.cachix.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "vomba.cachix.org-1:Me8oTzj1jpd5kcE0Yz2pKzX2C9SGnT951OXSwsfv19I="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  imports = [
    ./modules/options.nix
    ./modules/shell/zsh.nix
    ./modules/shell/git.nix
    ./modules/apps/firefox.nix
    ./modules/apps/editors.nix
    ./modules/shell/shell.nix
    ./modules/dev/dev.nix
    ./modules/dev/kubernetes.nix
    ./modules/desktop/gui.nix
    ./modules/apps/yazi.nix
    ./modules/shell/gpg.nix
    ./modules/apps/packages.nix
    ./modules/dev/cloud.nix
    ./modules/dev/lsp.nix
    ./modules/dev/mcp.nix
    ./modules/dev/ai.nix
    ./modules/apps/obsidian/default.nix
    ./modules/apps/zed.nix
    ./modules/sops.nix
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
