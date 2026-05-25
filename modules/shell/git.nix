{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.shell.git.enable {

    programs.git = {
      enable = true;
      signing = {
        key = "8D0433B853DB281D";
        signByDefault = true;
        format = "openpgp";
      };
      settings = {
        user = {
          name = "vomba";
          email = "hani.harzallah@elastisys.com";
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
      pkgs.git-crypt
    ];

    home.activation.unlockGitCrypt = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "${config.sops.secrets.git_crypt_key.path}" ]; then
        tmpKey="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.coreutils}/bin/base64 -d "${config.sops.secrets.git_crypt_key.path}" > "$tmpKey"
        ${pkgs.git-crypt}/bin/git-crypt unlock "$tmpKey" 2>/dev/null || true
        rm -f "$tmpKey"
      fi
    '';
  };
}
