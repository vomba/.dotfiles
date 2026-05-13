{
  pkgs,
  config,
  lib,
  ...
}:
let
  modifier = "Super";
  terminal = "kitty";
  menu = "fuzzel";
  file_explorer = "nautilus";
  lock_screen = "hyprlock";
  screenshot_dir = "$HOME/Pictures/Screenshots";
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.dotfiles.desktop.hyprland.enable {
    binds = {
      allow_workspace_cycles = true;
    };

    bind = [
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
  };
}
