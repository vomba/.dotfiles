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
    pkgs.socat

    # Secrets / Security
    pkgs.sops
    pkgs.bitwarden-cli
    pkgs.rbw
    pkgs.yubikey-manager

    # Runtimes
    pkgs.nodejs_24
    pkgs.ruby
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
  # Note: Create rbw config locally from template (rbw-config.json.example)
  home.file.".config/ck8s-devbox/credentials-helper.bash".source =
    ../../scripts/credentials-helper.bash;
}
