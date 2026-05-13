{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [ ./keybindings.nix ];

  wayland.windowManager.hyprland.settings = lib.mkIf config.dotfiles.desktop.hyprland.enable {

    env = [
      "GDK_BACKEND,wayland,x11,*"
      "QT_QPA_PLATFORM,wayland;xcb"
      "SDL_VIDEODRIVER,wayland"
      "CLUTTER_BACKEND,wayland"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "QT_QPA_PLATFORMTHEME,gtk2"
      "_JAVA_AWT_WM_NONREPARENTING,1"
      "MOZ_ENABLE_WAYLAND,1"
      "MOZ_ACCELERATED,1"
      "MOZ_WEBRENDER,1"
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
      "NIXOS_OZONE_WL,1"
    ];

    exec-once = [
      "waybar"
      "nm-applet --indicator"
      "blueman-applet"
      "dbus-update-activation-environment --all"
      "gnome-keyring-daemon --start --components=secrets"
      "kanshi"
    ];

    exec = [
      "${pkgs.swaybg}/bin/swaybg --image ${config.home.homeDirectory}/Pictures/background.png"
    ];

    monitor = [
      ",preferred,auto,1"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 3;
      layout = "dwindle";
      "col.active_border" = "rgb(5e81ac)";
      "col.inactive_border" = "rgb(2e3440)";
      resize_on_border = true;
      hover_icon_on_border = true;
      allow_tearing = false;
      gaps_workspaces = 0;
      no_focus_fallback = false;
      snap = {
        enabled = false;
        window_gap = 10;
        monitor_gap = 10;
      };
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    misc = {
      disable_splash_rendering = true;
      force_default_wallpaper = 1;
      mouse_move_enables_dpms = true;
      key_press_enables_dpms = true;
    };

    decoration = {
      rounding = 1;
      rounding_power = 2.0;
      blur = {
        enabled = false;
        size = 0;
        passes = 0;
      };
      shadow = {
        range = 12;
        render_power = 2;
        color = "rgb(101010)";
      };
      dim_inactive = false;
    };

    input = {
      kb_layout = "us,se";
      kb_variant = ",";
      kb_model = "";
      kb_options = "grp:win_space_toggle";
      kb_rules = "";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = true;
        disable_while_typing = true;
        drag_lock = 1;
        tap-to-click = true;
      };
      sensitivity = 0;
      float_switch_override_focus = 2;
    };

    windowrule = [
      "float on, match:class pavucontrol"
      "float on, match:class nm-connection-editor"
      "float on, match:class blueman-manager"
      "float on, match:class imv"
      "float on, match:class mpv"
      "size 800 600, match:class pavucontrol"
      "size 800 600, match:class nm-connection-editor"
      "float on, match:title Picture-in-Picture"
      "pin on, match:title Picture-in-Picture"
      "float on, match:class steam, match:title Steam - News"
      "idle_inhibit focus, match:class mpv"
      "idle_inhibit focus, match:class firefox, match:title .*YouTube.*"
    ];
  };
}
