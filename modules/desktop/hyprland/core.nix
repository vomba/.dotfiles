# Hyprland core configuration
# Contains keybinds, window rules, and general settings

{
  pkgs,
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.hyprland;

    systemd = {
      enable = false;
      variables = [ "--all" ];
    };
    settings = {

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
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
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

      render = {
        direct_scanout = false;
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

      binds = {
        allow_workspace_cycles = true;
      };

      bind =
        let
          modifier = "Super";
          terminal = "kitty";
          menu = "fuzzel";
          file_explorer = "nautilus";
          lock_screen = "/usr/bin/swaylock";
          screenshot_dir = "$HOME/Pictures/Screenshots";
        in
        [
          "${modifier}, Tab, cyclenext"
          "${modifier}, Return, exec, ${terminal}"
          "${modifier}, D, exec, ${menu}"
          "${modifier}, E, exec, ${file_explorer}"
          "${modifier}, L, exec, ${lock_screen}"
          "${modifier}, F, fullscreen"
          "${modifier}, W, togglegroup,"
          "${modifier}, P, pseudo,"
          "${modifier}, T, togglesplit,"
          "${modifier}, S, swapsplit,"

          "${modifier} Shift, Q, killactive,"
          "${modifier} Shift, Space, togglefloating,"

          "${modifier}, left, movefocus, l"
          "${modifier}, right, movefocus, r"
          "${modifier}, up, movefocus, u"
          "${modifier}, down, movefocus, d"

          "${modifier} Shift, left, movewindow, l"
          "${modifier} Shift, right, movewindow, r"
          "${modifier} Shift, up, movewindow, u"
          "${modifier} Shift, down, movewindow, d"

          "${modifier}, 1, workspace, 1"
          "${modifier}, 2, workspace, 2"
          "${modifier}, 3, workspace, 3"
          "${modifier}, 4, workspace, 4"
          "${modifier}, 5, workspace, 5"
          "${modifier}, 6, workspace, 6"
          "${modifier}, 7, workspace, 7"
          "${modifier}, 8, workspace, 8"
          "${modifier}, 9, workspace, 9"
          "${modifier}, 0, workspace, 10"

          "${modifier} Shift, 1, movetoworkspace, 1"
          "${modifier} Shift, 2, movetoworkspace, 2"
          "${modifier} Shift, 3, movetoworkspace, 3"
          "${modifier} Shift, 4, movetoworkspace, 4"
          "${modifier} Shift, 5, movetoworkspace, 5"
          "${modifier} Shift, 6, movetoworkspace, 6"
          "${modifier} Shift, 7, movetoworkspace, 7"
          "${modifier} Shift, 8, movetoworkspace, 8"
          "${modifier} Shift, 9, movetoworkspace, 9"
          "${modifier} Shift, 0, movetoworkspace, 10"

          "${modifier} Alt, left, workspace, e-1"
          "${modifier} Alt, right, workspace, e+1"

          "${modifier}+Ctrl, left, resizeactive, -10 0"
          "${modifier}+Ctrl, right, resizeactive, 10 0"
          "${modifier}+Ctrl, up, resizeactive, 0 -10"
          "${modifier}+Ctrl, down, resizeactive, 0 10"
          ", Print, exec, grim ${screenshot_dir}/$(date +'%Y-%m-%d_%H-%M-%S').png"
          "Shift, Print, exec, grim -g \"$(slurp)\" ${screenshot_dir}/$(date +'%Y-%m-%d_%H-%M-%S').png"
        ];

      bindm = [
        "SUPER, mouse:273, resizewindow"
        "SUPER, mouse:272, movewindow"
      ];

      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

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
  };
}
