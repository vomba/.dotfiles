{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.niri.enable {
    programs.niri.settings = {

      environment = {
        GDK_BACKEND = "wayland,x11,*";
        QT_QPA_PLATFORM = "wayland;xcb";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "niri";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_QPA_PLATFORMTHEME = "gtk2";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_ACCELERATED = "1";
        MOZ_WEBRENDER = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1";
        DMS_DISABLE_POLKIT = "1";
        DMS_DISABLE_MATUGEN = "1";
      };

      input = {
        keyboard = {
          xkb = {
            layout = "us,se";
            options = "grp:win_space_toggle";
          };
        };
        touchpad = {
          tap = true;
          dwt = true;
          natural-scroll = true;
          drag-lock = true;
        };
      };

      layout = {
        gaps = 5;

        focus-ring = {
          enable = true;
          width = 3;
          active.color = "#5e81ac";
          inactive.color = "#2e3440";
        };

        border = {
          enable = true;
          width = 3;
          active.color = "#5e81ac";
          inactive.color = "#2e3440";
        };

        shadow = {
          enable = true;
          softness = 12;
          spread = 2;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#10101080";
        };

        tab-indicator = {
          enable = true;
          position = "top";
          place-within-column = true;
          width = 8;
          gap = 8;
          gaps-between-tabs = 6;
          corner-radius = 12;
          length = {
            total-proportion = 1.0;
          };
          hide-when-single-tab = true;
          active.color = "#88c0d0";
          inactive.color = "#3b4252";
        };

        default-column-width = {
          proportion = 0.5;
        };

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        preset-window-heights = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
      };

      spawn-at-startup = [
        {
          command = [
            "${pkgs.swaybg}/bin/swaybg"
            "--image"
            "${config.home.homeDirectory}/Pictures/background.png"
          ];
        }
        {
          command = [
            "nm-applet"
            "--indicator"
          ];
        }
        { command = [ "blueman-applet" ]; }
        {
          command = [
            "dbus-update-activation-environment"
            "--systemd"
            "--all"
          ];
        }
        { command = [ "kanshi" ]; }
      ];

      prefer-no-csd = true;

      layer-rules = [
        {
          matches = [ { namespace = "^wallpaper$"; } ];
          place-within-backdrop = true;
        }
      ];

      window-rules = [
        {
          geometry-corner-radius = {
            top-left = 12.;
            top-right = 12.;
            bottom-left = 12.;
            bottom-right = 12.;
          };
          clip-to-geometry = true;
        }
        {
          matches = [ { app-id = "pavucontrol"; } ];
          open-floating = true;
          default-column-width = {
            fixed = 800;
          };
          default-window-height = {
            fixed = 600;
          };
        }
        {
          matches = [ { app-id = "nm-connection-editor"; } ];
          open-floating = true;
          default-column-width = {
            fixed = 800;
          };
          default-window-height = {
            fixed = 600;
          };
        }
        {
          matches = [ { app-id = "blueman-manager"; } ];
          open-floating = true;
        }
        {
          matches = [ { app-id = "imv"; } ];
          open-floating = true;
        }
        {
          matches = [ { app-id = "mpv"; } ];
          open-floating = true;
        }
        {
          matches = [
            {
              app-id = "firefox";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
          default-column-width = {
            fixed = 400;
          };
          default-window-height = {
            fixed = 225;
          };
        }
        {
          matches = [
            {
              app-id = "steam";
              title = "^Steam - News$";
            }
          ];
          open-floating = true;
        }
        {
          matches = [ { app-id = "org.kde.polkit-kde-authentication-agent-1"; } ];
          open-floating = true;
        }
        {
          matches = [ { is-window-cast-target = true; } ];
          focus-ring = {
            active.color = "#bf616a";
            inactive.color = "#bb4551";
          };
          tab-indicator = {
            active.color = "#bf616a";
            inactive.color = "#bb4551";
          };
        }
      ];

      hotkey-overlay = {
        skip-at-startup = true;
      };
    };
  };
}
