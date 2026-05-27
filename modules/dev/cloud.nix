{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.dev.cloud.enable {
    home.packages = [
      # AWS
      pkgs.awscli2

      # Azure
      pkgs.azure-cli
      pkgs.azure-storage-azcopy

      # OpenStack / UpCloud
      pkgs.openstackclient-full
      pkgs.openstack-tui
      pkgs.upcloud-cli

      # Terraform / OpenTofu
      pkgs.tenv # Version manager for Terraform/OpenTofu/Terragrunt

      # Networking
      pkgs.cidr
    ];
  };
}
