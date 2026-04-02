{
  pkgs, config, ...
}: {

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    package = if pkgs.stdenv.isLinux then (config.lib.nixGL.wrap pkgs.kitty) else pkgs.kitty;
  };

  programs.chromium = {
    enable = if pkgs.stdenv.isLinux then true else false;
    package = config.lib.nixGL.wrap pkgs.chromium;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
    ];
  };

  # programs.obs-studio = {
  #   enable = true;
  #   package = if pkgs.stdenv.isLinux then (config.lib.nixGL.wrap pkgs.obs-studio) else pkgs.obs-studio;
  # };

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.slack
    pkgs.tabiew
  ] ++ (if pkgs.stdenv.isLinux then [
    pkgs.nautilus
    pkgs.grim
    pkgs.slurp
    pkgs.swaybg
    pkgs.wdisplays
    pkgs.hyprland-qtutils
    pkgs.hyprutils
  ] else [
    pkgs.rectangle
  ]);

  home.file.".config/fontconfig/conf.d/10-nix-fonts.conf".source = ../10-nix-fonts.conf;
}
