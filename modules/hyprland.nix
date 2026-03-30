# Hyprland configuration for Nix on Ubuntu (nixGL)
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

{
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
{

  # Theme fixes https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#fixing-problems-with-themes
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

  # Portal configuration for Ubuntu
  # Note: Using xdg-desktop-portal-wlr (available on Ubuntu) instead of
  # xdg-desktop-portal-hyprland which may not be available on older Ubuntu versions
  # For portals to work, create ~/.config/xdg-desktop-portal/portals.conf:
  #   [preferred]
  #   default=wlr;gtk
  #   org.freedesktop.impl.portal.FileChooser=gtk
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    configPackages = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Additional packages for Ubuntu compatibility
  # Note: swaylock is installed via apt (apt install swaylock) because the Nix version
  # has issues with PAM authentication on Ubuntu. See hypridle config below which
  # uses /usr/bin/swaylock path.
  # Note: hyprland is already installed by wayland.windowManager.hyprland module
  home.packages = with pkgs; [
    xdg-desktop-portal-wlr # Using wlr instead of hyprland portal for Ubuntu compatibility
    hypridle
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.hyprland;

    # Disable systemd integration on Ubuntu (not NixOS)
    # Ubuntu manages sessions differently
    systemd = {
      enable = false;
      variables = [ "--all" ];
    };
    settings = {

      env = [
        # Common Wayland fixes
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORMTHEME,gtk2"
        # Java application fixes
        "_JAVA_AWT_WM_NONREPARENTING,1"
        # Hardware rendering
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_ACCELERATED,1"
        "MOZ_WEBRENDER,1"
        # Chrome based apps
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        # Required for Ubuntu (non-NixOS) for Electron/Ozone apps
        "NIXOS_OZONE_WL,1"
        # Additional Ubuntu-specific fixes
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];

      exec-once = [
        # Start waybar manually since systemd integration is disabled
        "waybar"
        "nm-applet --indicator" # Network Manager applet
        "blueman-applet" # Bluetooth applet
        # Import environment for DBus and applications
        "dbus-update-activation-environment --all"
        "gnome-keyring-daemon --start --components=secrets"
        "kanshi"
      ];

      exec = [
        # Set wallpaper
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
        # New: Gaps between workspaces
        gaps_workspaces = 0;
        # New: Focus fallback behavior
        no_focus_fallback = false;

        # New: Snap feature for floating windows (optional)
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
        # New: Controls corner curve (1.0=triangle, 2.0=circle, 4.0=squircle)
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
          # drag_lock is now an int: 0=disabled, 1=enabled with timeout, 2=sticky
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
          lock_screen = "/usr/bin/swaylock"; # apt-installed swaylock
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

          # Second level bindings
          "${modifier} Shift, Q, killactive,"
          "${modifier} Shift, Space, togglefloating,"

          # Move focus with modifier + arrow keys
          "${modifier}, left, movefocus, l"
          "${modifier}, right, movefocus, r"
          "${modifier}, up, movefocus, u"
          "${modifier}, down, movefocus, d"

          # Move window with modifier + Shift + arrow keys
          "${modifier} Shift, left, movewindow, l"
          "${modifier} Shift, right, movewindow, r"
          "${modifier} Shift, up, movewindow, u"
          "${modifier} Shift, down, movewindow, d"

          # Switch workspaces with modifier + [0-9]
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

          # Move active window to a workspace with modifier + Shift + [0-9]
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

          # Navigate between workspaces with modifier + Alt + arrow keys
          "${modifier} Alt, left, workspace, e-1" # Go to workspace on the left
          "${modifier} Alt, right, workspace, e+1" # Go to workspace on the right

          # Rezie active window
          "${modifier}+Ctrl, left, resizeactive, -10 0"
          "${modifier}+Ctrl, right, resizeactive, 10 0"
          "${modifier}+Ctrl, up, resizeactive, 0 -10"
          "${modifier}+Ctrl, down, resizeactive, 0 10"
          # Screenshot bindings
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

      # Window rules - new syntax for latest Hyprland
      # Format: windowrule = effect value, match:criteria
      # Note: Regex anchors ^ and $ are not needed - matching is already regex-based
      windowrule = [
        # Float dialogs and popups
        "float on, match:class pavucontrol"
        "float on, match:class nm-connection-editor"
        "float on, match:class blueman-manager"
        "float on, match:class imv"
        "float on, match:class mpv"
        "size 800 600, match:class pavucontrol"
        "size 800 600, match:class nm-connection-editor"

        # Make Firefox PiP float and stay on top
        "float on, match:title Picture-in-Picture"
        "pin on, match:title Picture-in-Picture"

        # Steam fixes
        "float on, match:class steam, match:title Steam - News"

        # Ignore idle inhibit for certain windows
        "idle_inhibit focus, match:class mpv"
        "idle_inhibit focus, match:class firefox, match:title .*YouTube.*"
      ];
    };
  };

  # Swaylock configuration
  # NOTE: swaylock must be installed via apt: sudo apt install swaylock
  # The Nix version has PAM authentication issues on Ubuntu.
  # Config is applied to /usr/bin/swaylock (apt-installed version)
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
  # NOTE: Using /usr/bin/swaylock which must be installed via apt (sudo apt install swaylock)
  # The Nix version of swaylock has PAM authentication issues on Ubuntu.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "/usr/bin/swaylock"; # lock screen command (apt-installed)
        unlock_cmd = ""; # unlock command (optional)
        before_sleep_cmd = "/usr/bin/swaylock"; # lock before sleep
        after_sleep_cmd = "hyprctl dispatch dpms on"; # turn on screen after sleep
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };
      listener = [
        {
          timeout = 300; # 5 minutes
          on-timeout = "/usr/bin/swaylock"; # lock screen after timeout
        }
        {
          timeout = 600; # 10 minutes
          on-timeout = "hyprctl dispatch dpms off"; # turn off screen
          on-resume = "hyprctl dispatch dpms on"; # turn on screen on resume
        }
      ];
    };
  };

  # Waybar - disabled systemd since we're on Ubuntu
  # Waybar is started manually in Hyprland exec-once
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    style = ''
      * {
          font-family: JetBrains Mono Nerd Font;
          font-weight: bold;
          font-size: 14px;
          }

        window#waybar {
          color: #d8dee9;
          background-color: transparent;
        }

        window#waybar > box {
            margin: 0px 0px 5px 0px;
            background-color: #2e3440;
            box-shadow: 1 1 3 1px #151515;
        }

        #workspaces button {
          padding: 0 0.6em;
          color: #d8dee9;
          border-radius: 6px;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 2px;
          margin-bottom: 2px;
        }

        #workspaces button.active {
          color: #d8dee9;
          background: #434c5e;
        }

        #workspaces button.focused {
          color: #d8dee9;
          background: #434c5e;
        }

        #workspaces button.urgent {
          color: #bf616a;
          background: #d8dee9;
        }

        #workspaces button:hover {
          color: #d8dee9;
          background: #2e3440;
        }

        #date,
        #battery,
        #clock,
        #pulseaudio,
        #workspaces,
        #window,
        #language,
        #temperature,
        #text,

        #tray {
          background: #3b4252;
          padding: 0 0.6em;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          border-radius: 6px;
        }

        #tray {
          margin-right: 6px;
        }

        #pulseaudio {
          margin-right: 6px;
          color: #d8dee9;
        }

        #clock {
          color: #d8dee9;
          margin-right: 6px;
        }

        #battery {
          color: #d8dee9;
          margin-right: 6px;
        }

        #window {
          color: #d8dee9;
          background: #3b4252;
          padding: 0 0.6em;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          border-radius: 6px;
          background: #5e81ac;
        }

        #language {
          color: #d8dee9;
          background: #3b4252;
          padding: 0 0.6em;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          border-radius: 6px;
        }

        #temperature {
          color: #d8dee9;
          background: #3b4252;
          padding: 0 0.6em;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          border-radius: 6px;
        }

        #network {
          color: #d8dee9;
          background: #3b4252;
          padding: 0 0.6em;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          border-radius: 6px;
        }

        #backlight {
          color: #d8dee9;
          background: #3b4252;
          padding: 0 0.6em;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          border-radius: 6px;
        }

        #custom-launcher {
          color: #d8dee9;
          background: #3b4252;
          padding: 0 0.6em;
          margin-right: 4px;
          margin-left: 4px;
          margin-top: 4px;
          margin-bottom: 4px;
          border-radius: 6px;
        }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        # output = [
        #   "DP-4"
        # ];

        modules-left = [
          "custom/launcher"
          "hyprland/language"
          "hyprland/workspaces"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "network"
          "backlight"
          "battery"
          "pulseaudio"
          "tray"
          "clock#date"
          "clock#time"
        ];
        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };
        };

        "clock#time" = {
          interval = 1;
          format = "{:%H:%M:%S}";
          tooltip = false;
        };

        "clock#date" = {
          interval = 10;
          format = " {:%e %b}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " muted";
          scroll-step = 5;
          on-click = "pavucontrol";
          format-icons = {
            "headphone" = " ";
            "hands-free" = " ";
            "headset" = " ";
            "default" = [
              ""
              ""
            ];
          };
        };

        "backlight" = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "battery" = {
          tooltip = true;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [
            "" # Icon: battery-full
            "" # Icon: battery-three-quarters
            "" # Icon: battery-half
            "" # Icon: battery-quarter
            "" # Icon: battery-empty
          ];
        };

        "temperature" = {
          critical-threshold = 80;
          tooltip = true;
          format = "{icon} {temperatureC}°C";
          format-icons = [
            "" # Icon: temperature-empty
            "" # Icon: temperature-quarter
            "" # Icon: temperature-half
            "" # Icon: temperature-three-quarters
            "" # Icon: temperature-full
          ];
        };

        "network" = {
          interval = 5;
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰈀  {ifname}: {ipaddr}/{cidr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        "hyprland/window" = {
          format = " {} ";
          max-length = 50;
        };

        "hyprland/language" = {
          format = "  {}";
          interval = 1;
          format-en = "US";
          format-sv = "SE";
        };

        "custom/launcher" = {
          format = " ";
          on-click = "fuzzel";
        };
      };
    };
  };

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
        # Nord color palette
        background = "2e3440ff"; # Dark blue-grey background
        text = "d8dee9ff"; # Light blue-grey text
        match = "88c0d0ff"; # Light blue for matched text
        selection = "4c566aff"; # Lighter blue-grey for selected item
        selection-text = "eceff4ff"; # Almost white for text in selected item
        border = "5e81acff"; # Medium blue for border
      };
      border = {
        width = 2;
        radius = 6;
      };
    };
  };

  # ============================================================================
  # UBUNTU-SPECIFIC NOTES AND SETUP INSTRUCTIONS
  # ============================================================================
  #
  # To launch Hyprland on Ubuntu, use a wrapper script or add to ~/.bashrc/.zshrc:
  #
  #   alias hyprland-nix='nixGLIntel hyprland'
  #   # or for NVIDIA:
  #   # alias hyprland-nix='nixGLNvidia hyprland'
  #
  # If launching from a TTY (Ctrl+Alt+F3):
  #   nixGLIntel hyprland
  #
  # If launching from a display manager (GDM, SDDM, etc.), create:
  #   ~/.local/share/wayland-sessions/hyprland-nix.desktop
  #
  # With contents:
  #   [Desktop Entry]
  #   Name=Hyprland (Nix)
  #   Comment=Hyprland compositor (Nix package)
  #   Exec=/home/USERNAME/.nix-profile/bin/nixGLIntel /home/USERNAME/.nix-profile/bin/hyprland
  #   Type=Application
  #
  # IMPORTANT: Make sure to replace USERNAME with your actual username!
  #
  # REQUIRED UBUNTU PACKAGES (install via apt):
  #   sudo apt install swaylock xdg-desktop-portal-wlr
  #
  # PORTAL CONFIGURATION:
  #   Create ~/.config/xdg-desktop-portal/portals.conf:
  #   [preferred]
  #   default=wlr;gtk
  #   org.freedesktop.impl.portal.FileChooser=gtk
  #
  # NOTE: swaylock MUST be installed via apt (not nix) due to PAM authentication issues.
  # This config uses /usr/bin/swaylock for all lock commands.
  #
  # ============================================================================
}
