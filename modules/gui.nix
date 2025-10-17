{
  pkgs, config, ...
}: {

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    package = (config.lib.nixGL.wrap pkgs.kitty);
  };

  programs.chromium = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.chromium;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
    ];
  };

  # programs.obs-studio = {
  #   enable = true;
  #   package = config.lib.nixGL.wrap pkgs.obs-studio;
  # };

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.slack
    pkgs.tabiew
    pkgs.nautilus
    pkgs.grim
    pkgs.slurp
    pkgs.swaybg
    pkgs.wdisplays
    pkgs.hyprland-qtutils
    pkgs.hyprutils
  ];

  home.file.".config/fontconfig/conf.d/10-nix-fonts.conf".source = ../10-nix-fonts.conf;
}
