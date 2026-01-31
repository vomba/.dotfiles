{
  pkgs,
  config,
  ...
}:
{
  programs.go = {
    enable = true;
    telemetry.mode = "off";
    env = {
      GOPATH = "${config.home.homeDirectory}/.go";
      GOPRIVATE = [
        "github.com/elastisys"
      ];
    };
  };

  home.packages = [
    pkgs.pre-commit
  ];
}
