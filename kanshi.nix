{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
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
          "hyprctl dispatch moveworkspacetomonitor 2 'desc:AOC G2490W1G4 QSHNCHA000279'"
          "hyprctl dispatch moveworkspacetomonitor 3 'desc:GIGA-BYTE TECHNOLOGY CO. LTD. M27Q 0x01010101'"
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
            criteria = "Dell Inc. DELL P2723QE 9FLG904";
            position = "5760,0";
          }
          {
            criteria = "Dell Inc. DELL P2721Q HQ53HF3";
            position = "1920,0";
          }
        ];
        profile.exec = [
          "hyprctl dispatch moveworkspacetomonitor 2 'desc:Dell Inc. DELL P2721Q HQ53HF3'"
          "hyprctl dispatch moveworkspacetomonitor 3 'desc:Dell Inc. DELL P2723QE 9FLG904'"

        ];
      }
    ];
  };
}
