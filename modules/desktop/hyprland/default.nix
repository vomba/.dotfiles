# Hyprland configuration
#
# Prerequisites:
# 1. Install Nix package manager on Ubuntu
# 2. Install nixGL: nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl && nix-channel --update
# 3. Install nixGL.auto: nix-env -iA nixgl.auto -f '<nixpkgs>'
# 4. Install swaylock via apt (NOT nix - PAM issues): sudo apt install swaylock
# 5. For portals to work on Ubuntu, create ~/.config/xdg-desktop-portal/portals.conf:
#    [preferred]
#    default=wlr;gtk
#    org.freedesktop.impl.portal.FileChooser=gtk
#
# Note: This config disables systemd integration since we're on Ubuntu, not NixOS
# Applications like waybar need to be started manually in exec-once
#
# IMPORTANT: This config uses xdg-desktop-portal-wlr (not hyprland portal) and
# requires swaylock to be installed via apt at /usr/bin/swaylock
#
# UBUNTU-SPECIFIC SETUP:
#   # Required apt packages:
#   sudo apt install swaylock xdg-desktop-portal-wlr
#
#   # Portal configuration:
#   Create ~/.config/xdg-desktop-portal/portals.conf:
#   [preferred]
#   default=wlr;gtk
#   org.freedesktop.impl.portal.FileChooser=gtk
#
#   # Launch Hyprland:
#   alias hyprland-nix='nixGLIntel hyprland'
#

{
  imports = [
    ./environment.nix
    ./core.nix
    ./waybar.nix
    ./applications.nix
  ];
}
