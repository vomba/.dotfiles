{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
            }
          ];
        }
        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,240";
            }
            {
              criteria = "AOC G2490W1G4 QSHNCHA000279";
              position = "1920,360";
            }
            {
              criteria = "*";
              position = "3840,0";
            }
          ];
          profile.exec = [
            "niri msg action focus-workspace 2; niri msg action move-workspace-to-monitor 'AOC G2490W1G4 QSHNCHA000279'"
            "niri msg action focus-workspace 3; niri msg action move-workspace-to-monitor 'GIGA-BYTE TECHNOLOGY CO. LTD. M27Q'"
          ];
        }
        {
          profile.name = "work";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,960";
            }
            {
              criteria = "Dell Inc. DELL P2721Q HQ53HF3";
              position = "1536,480";
            }
            {
              criteria = "Dell Inc. DELL P2723QE 9FLG904";
              position = "4096,480";
            }
          ];
          profile.exec = [
            "niri msg action focus-workspace 2; niri msg action move-workspace-to-monitor 'Dell Inc. DELL P2721Q HQ53HF3'"
            "niri msg action focus-workspace 3; niri msg action move-workspace-to-monitor 'Dell Inc. DELL P2723QE 9FLG904'"
          ];
        }
      ];
    };
  };
}
