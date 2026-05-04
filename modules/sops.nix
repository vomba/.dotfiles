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
    };
  };

}
