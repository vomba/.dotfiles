{ pkgs, pkgs-stable, ... }:
{
  programs.opencode = {
    enable = if pkgs.stdenv.isLinux then false else true;
    settings = {
      provider = {
      };
    };
  };

  home.packages =
    [ ]
    ++ (
      if pkgs.stdenv.isDarwin then
        [
          # pkgs-stable.lmstudio
        ]
      else
        [ ]
    );

}
