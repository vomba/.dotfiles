{ ... }:
{

  programs.git = {
    enable = true;
    userEmail = "hani.harzallah@elastisys.com";
    userName = "vomba";
    signing = {
      key = "8D0433B853DB281D";
      signByDefault = true;
      format = "openpgp";
    };
    extraConfig = {
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
      diff = {
        "sopsdiffer" = {
          textconv = "sopd -d";
        };
      };
    };
  };
}
