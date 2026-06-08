{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      gcp_project = { };
      context7_api_key = { };
      git_crypt_key = { };
      opencode_api_key = { };
    };
  };

}
