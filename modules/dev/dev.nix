{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.dev.enable {
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
      pkgs.skopeo
      pkgs.parallel-full
    ];
  };
}
