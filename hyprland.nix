{
  pkgs,
  config,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.hyprland;
    systemd = {
      variables = [ "--all" ];
      enable = true;
    };
    settings = {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 20;
      };
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
        # Java application fixes
        "_JAVA_AWT_WM_NONREPARENTING,1"
        # Hardware rendering
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_ACCELERATED,1"
        "MOZ_WEBRENDER,1"
        # Chrome based apps
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      exec-once = [
        "waybar" # Start waybar when Hyprland starts
        "nm-applet --indicator" # Network Manager applet
        "blueman-applet" # Bluetooth applet
        # Compatibility with Gnome applications
        "dbus-update-activation-environment --systemd --all"
        "gnome-keyring-daemon --start --components=secrets"
      ];

      monitor = [
        ",preferred,auto,1"
        # "DP-3, 2560x1440@59.95, 1120x0, 1, transform, 1"
        # "DP-4, 2560x1440@59.95, 2560x865, 1"
        # "DP-5, 2560x1440@59.95, 5120x0, 1, transform, 3"
        ];

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
          drag_lock = true;
        };
        sensitivity = 0;
        float_switch_override_focus = 2;
      };

      bind =
        let
          modifier = "Super";
          terminal = "kitty";
        in
        [
          "${modifier}, Tab, cyclenext"
          "${modifier}, Return, exec, ${terminal}"
        ];
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
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

}
