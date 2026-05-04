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

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  imports = [
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
    ./modules/dev/ai.nix
    ./modules/apps/obsidian/default.nix
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
