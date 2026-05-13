{
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
{
  imports = [
    ./settings.nix
    ./waybar.nix
  ];

  config = lib.mkIf config.dotfiles.desktop.hyprland.enable {

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
      (pkgs.writeShellScriptBin "hyprlock" ''
        unset __EGL_VENDOR_LIBRARY_FILENAMES
        unset LIBGL_DRIVERS_PATH
        unset GBM_BACKENDS_PATH
        unset LD_LIBRARY_PATH
        export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu"
        exec /usr/bin/hyprlock "$@"
      '')
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.hyprland;
      systemd = {
        enable = true;
        variables = [ "--all" ];
      };
    };

    xdg.configFile."hypr/hyprlock.conf".text = ''
      background {
        monitor =
        path = screenshot
        blur_passes = 3
        blur_size = 7
        noise = 0.01
        contrast = 0.8
        brightness = 0.5
      }

      input-field {
        monitor =
        size = 300, 60
        outline_thickness = 3
        rounding = 10
        placeholder_text = <i>Password...</i>
        hide_input = false
        inner_color = rgb(2e3440)
        outer_color = rgb(5e81ac)
        font_color = rgb(eceff4)
        check_color = rgb(a3be8c)
        fail_color = rgb(bf616a)
        fail_text = <i>$FAIL</i>
        capslock_color = rgb(d08770)
        fade_on_empty = true
        dots_spacing = 0.3
        dots_size = 0.2
        position = 0, -20
        halign = center
        valign = center
      }
    '';

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprlock";
          unlock_cmd = "";
          before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
        };
        listener = [
          {
            timeout = 180;
            on-timeout = "hyprlock";
          }
          {
            timeout = 180;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
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
  };
}
