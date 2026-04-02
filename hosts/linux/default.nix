# Linux host-specific configuration
#
# This file contains host-specific overrides for Linux systems.
# Create a file like hosts/linux/hani.nix for machine-specific config.
#
# Usage:
#   1. Create a new file in hosts/linux/<hostname>.nix
#   2. Import it from linux.nix
#   3. Set host-specific options (username, home directory, etc.)

{ lib, ... }:

{
  # Host name (set by nix-darwin or nixos)
  networking.hostName = "hani";

  # User configuration
  users.users.hani = {
    name = "hani";
    home = "/home/hani";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  # Environment variables specific to Linux hosts
  environment.variables = {
    # Add Linux-specific environment variables here
  };

  # Linux-specific packages
  environment.systemPackages = [ ];

  # Host-specific profile overrides
  # Uncomment and set your personal details:
  # profiles.user = {
  #   email = "your@email.com";
  #   name = "Your Name";
  #   gpgKeyId = "YOUR_GPG_KEY_ID";
  #   githubUsername = "your-github-username";
  # };
}
