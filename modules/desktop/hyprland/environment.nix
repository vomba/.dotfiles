# Hyprland environment configuration: theme, GTK, cursor, portals

{ pkgs, config, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 24;
  };
  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    iconTheme = {
      name = "Nordic-blueish";
      package = pkgs.nordic;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    configPackages = [ pkgs.xdg-desktop-portal-wlr ];
  };

  home.packages = with pkgs; [
    xdg-desktop-portal-wlr
    hypridle
  ];
}
