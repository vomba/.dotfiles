# Hyprland waybar configuration

{ pkgs, config, ... }:
{
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
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "temperature" = {
          critical-threshold = 80;
          tooltip = true;
          format = "{icon} {temperatureC}°C";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
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
