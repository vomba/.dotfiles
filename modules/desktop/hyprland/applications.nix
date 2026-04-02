# Hyprland applications: swaylock, hypridle, fuzzel

{ pkgs, config, ... }:
{
  # Swaylock configuration
  # NOTE: swaylock must be installed via apt: sudo apt install swaylock
  # The Nix version has PAM authentication issues on Ubuntu.
  xdg.configFile."swaylock/config".text = ''
    ignore-empty-password
    show-failed-attempts
    image=${config.home.homeDirectory}/Pictures/welkin.png
    show-keyboard-layout
    indicator-caps-lock
    bs-hl-color=b48eadff
    caps-lock-bs-hl-color=d08770ff
    caps-lock-key-hl-color=ebcb8bff
    font-size=40
    indicator-radius=100
    indicator-thickness=10
    inside-color=2e3440ff
    inside-clear-color=81a1c1ff
    inside-ver-color=5e81acff
    inside-wrong-color=bf616aff
    key-hl-color=a3be8cff
    layout-bg-color=2e3440ff
    line-uses-ring
    ring-color=3b4252ff
    ring-clear-color=88c0d0ff
    ring-ver-color=81a1c1ff
    ring-wrong-color=d08770ff
    separator-color=3b4252ff
    text-color=eceff4ff
    text-clear-color=3b4252ff
    text-ver-color=3b4252ff
    text-wrong-color=3b4252ff
  '';

  # Hypridle - idle management daemon
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "/usr/bin/swaylock";
        unlock_cmd = "";
        before_sleep_cmd = "/usr/bin/swaylock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "/usr/bin/swaylock";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Fuzzel - application launcher
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        width = 30;
        font = "JetBrains Mono Nerd Font:weight=bold:size=10";
        inner-pad = 10;
        lines = 15;
        horizontal-pad = 20;
        vertical-pad = 20;
      };
      colors = {
        background = "2e3440ff";
        text = "d8dee9ff";
        match = "88c0d0ff";
        selection = "4c566aff";
        selection-text = "eceff4ff";
        border = "5e81acff";
      };
      border = {
        width = 2;
        radius = 6;
      };
    };
  };
}
