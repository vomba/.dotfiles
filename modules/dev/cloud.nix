{ pkgs, pkgs-stable, ... }:
{
  home.packages = [
    # AWS
    pkgs-stable.awscli2

    # Azure
    pkgs-stable.azure-cli
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
}
