{
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.apps.enable {
    home.packages = [
      # Utilities
      pkgs.gh
      pkgs-stable.yq-go
      pkgs-stable.jq
      pkgs.jless
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
      pkgs.nodejs_26 # bleeding-edge (not LTS); switch to nodejs_24 for LTS
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
    home.file.".config/rbw/config.json".source = ../../rbw-config.json;
    home.file.".config/ck8s-devbox/credentials-helper.bash".source = ../../credentials-helper.bash;
  };
}
