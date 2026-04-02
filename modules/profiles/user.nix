{
  lib,
  config,
  pkgs,
  ...
}:

let
  # Path to encrypted secrets file
  sopsFile = ./secrets/secrets.yaml.age;
in
{
  options.profiles.user = {
    enable = lib.mkEnableOption "user profile with personal settings";

    email = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Primary email address for git and other configs";
      example = "user@example.com";
    };

    gpgKeyId = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "GPG key ID for git signing";
      example = "ABC123DEF456";
    };

    githubUsername = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "GitHub username";
      example = "username";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Full name for git commits";
      example = "John Doe";
    };

    workEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Work email address";
      example = "user@company.com";
    };

    workGcpProject = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Google Cloud project ID";
      example = "my-project";
    };
  };

  # Note: sops.secrets are declared in home.nix
  # This module only declares the user profile options
}
