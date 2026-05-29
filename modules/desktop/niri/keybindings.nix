{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.niri.enable {
    programs.niri.settings = {
      binds = {
        # Show hotkey overlay
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

        # Terminals & Apps
        "Mod+Return".action.spawn = "kitty";
        "Mod+D".action.spawn = "fuzzel";
        "Mod+E".action.spawn = "nautilus";
        "Mod+L".action.spawn = "hyprlock";

        # Layout adjustments
        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Shift+Ctrl+R".action.reset-window-height = [ ];
        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];
        "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
        "Mod+C".action.center-column = [ ];
        "Mod+Shift+C".action.center-visible-columns = [ ];
        "Mod+Z".action.toggle-window-floating = [ ];
        "Mod+Shift+Z".action.switch-focus-between-floating-and-tiling = [ ];
        "Mod+W".action.toggle-column-tabbed-display = [ ];
        "Mod+Minus".action.set-column-width = [ "-10%" ];
        "Mod+Equal".action.set-column-width = [ "+10%" ];
        "Mod+Shift+Minus".action.set-window-height = [ "-10%" ];
        "Mod+Shift+Equal".action.set-window-height = [ "+10%" ];

        # Screenshots
        "Print".action.screenshot = [ ];
        "Mod+Print".action.screenshot-screen = [ ];
        "Mod+Shift+Print".action.screenshot-window = [ ];

        # Keyboard layout
        "Alt+Space".action.switch-layout = "next";

        # Media keys
        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn = "playerctl play-pause";
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action.spawn = "playerctl stop";
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn = "playerctl previous";
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn = "playerctl next";
        };

        # Window Management
        "Mod+O".action.toggle-overview = [ ];
        "Mod+Shift+Q".action.close-window = [ ];
        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];
        "Mod+Ctrl+Left".action.focus-monitor-left = [ ];
        "Mod+Ctrl+Right".action.focus-monitor-right = [ ];
        "Mod+Ctrl+Down".action.focus-monitor-down = [ ];
        "Mod+Ctrl+Up".action.focus-monitor-up = [ ];
        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Page_Up".action.focus-workspace-up = [ ];

        # Move windows
        "Mod+Shift+Left".action.move-column-left = [ ];
        "Mod+Shift+Right".action.move-column-right = [ ];
        "Mod+Shift+Down".action.move-window-down = [ ];
        "Mod+Shift+Up".action.move-window-up = [ ];
        "Mod+Shift+Home".action.move-column-to-first = [ ];
        "Mod+Shift+End".action.move-column-to-last = [ ];
        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
        "Mod+Shift+Page_Down".action.move-column-to-workspace-down = [ ];
        "Mod+Shift+Page_Up".action.move-column-to-workspace-up = [ ];
        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

        # Workspaces
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+0".action.focus-workspace = 10;

        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
        "Mod+Shift+0".action.move-column-to-workspace = 10;

        # System
        "Ctrl+Alt+Delete".action.quit = [ ];
        "Mod+Escape".action.toggle-keyboard-shortcuts-inhibit = [ ];
      };
    };
  };
}
