# macOS host-specific configuration
#
# This file contains host-specific overrides for macOS systems.
# Create a file like hosts/darwin/Mac.nix for machine-specific config.
#
# Usage:
#   1. Create a new file in hosts/darwin/<hostname>.nix
#   2. Import it from darwin.nix
#   3. Set host-specific options (username, home directory, etc.)

{ lib, ... }:

{
  # Host name (set by nix-darwin)
  networking.hostName = "Mac";

  # User configuration
  users.users.vomba = {
    name = "vomba";
    home = "/Users/vomba";
    shell = pkgs.zsh;
  };

  # Environment variables specific to macOS hosts
  environment.variables = {
    # Add macOS-specific environment variables here
  };

  # macOS-specific packages
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
