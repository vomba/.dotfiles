{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.profiles.user;
in
{
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      signing = {
        # Use SOPS variable or fallback to GPG key ID from smartcard
        key = config.sops.secrets.git-gpg-key-id.raw or "8D0433B853DB281D";
        signByDefault = true;
        format = "openpgp";
      };
      settings = {
        user = {
          # Use SOPS variables, falling back to defaults if not set
          name = config.sops.secrets.git-name.raw or "vomba";
          email = config.sops.secrets.git-email.raw or "hani.harzallah@elastisys.com";
        };
        url = {
          "ssh://git@github.com/" = {
            insteadOf = "https://github.com/";
          };
        };
        diff = {
          "sopsdiffer" = {
            textconv = "sops -d";
          };
        };
      };
    };

    home.packages = [
      pkgs.lazygit
    ];
  };
}
