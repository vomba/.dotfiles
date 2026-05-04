{ pkgs, ... }:
{

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
  ];
}
