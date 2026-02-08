{ pkgs, pkgs-stable, pkgs-25, ... }:
{
  home.packages = [
    # AWS
    pkgs-25.awscli2

    # Azure
    pkgs-25.azure-cli
    pkgs.azure-storage-azcopy

    # OpenStack / UpCloud
    pkgs-25.openstackclient-full
    pkgs.openstack-tui
    pkgs.upcloud-cli

    # Terraform / OpenTofu
    pkgs.tenv # Version manager for Terraform/OpenTofu/Terragrunt

    # Networking
    pkgs.cidr
  ];
}
