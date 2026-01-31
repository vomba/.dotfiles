{ pkgs, pkgs-stable, ... }:
{
  home.packages = [
    # Utilities
    pkgs.direnv
    pkgs.gh
    pkgs-stable.yq-go
    pkgs-stable.jq
    pkgs.glow
    pkgs.act
    pkgs.hugo
    pkgs.superhtml
    pkgs.socat
    
    # Secrets / Security
    pkgs.sops
    pkgs.bitwarden-cli
    pkgs.rbw
    pkgs.yubikey-manager

    # Runtimes
    pkgs.nodejs_24
  ]
  ++ (
    if pkgs.stdenv.isLinux then
      [
        pkgs.powershell
      ]
    else
      [ ]
  );

  # Configuration for RBW (Bitwarden)
  home.file.".config/rbw/config.json".source = ../rbw-config.json;
  home.file.".config/ck8s-devbox/credentials-helper.bash".source = ../credentials-helper.bash;
}
