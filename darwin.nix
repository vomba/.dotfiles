{
  pkgs,
  pkgs-stable,
  lib,
  inputs,
  ...
}:
{
  # Common configuration for all Mac systems
  #
  # To make this file specific to a certain machine, you can use
  # `if pkgs.stdenv.hostPlatform.name == "aarch64-darwin" && config.networking.hostName == "MyMac" then { ... }`
  # or create a new file in `hosts/MyMac.nix` and import it here.

  # List packages installed system-wide.
  environment.systemPackages = with pkgs; [ ];

  # Set environment variables.
  environment.variables = {
    EDITOR = "hx";
  };

  nixpkgs.pkgs = pkgs;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  ids.gids.nixbld = 350;

  # The platform comes with a lot of packages pre-installed, so we don't need to install them again.
  # See https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/system/darwin-init.nix
  #system.activationScripts.postActivation.text = ''
  #  # deactivate system-provided binaries
  #  for bin in "vim" "emacs" "nano" "pico"; do
  #    if [ -f "/usr/bin/$bin" ]; then
  #      sudo mv "/usr/bin/$bin" "/usr/bin/.$bin"
  #    fi
  #  done
  #'';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.bash.enable = true;

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;

  # https://github.com/LnL7/nix-darwin/issues/294
  # If you additionally want to install packages from other flakes, or from a
  # local flake, you can add them to the inputs of your flake and add them to
  # the nix.registry input.
  # nix.registry = {
  #   mr.flake = inputs.mission-control;
  #   public-nix.flake = inputs.public-nix;
  # };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 4;
    min-free = "2G";
    max-free = "10G";
    auto-optimise-store = true;
    substituters = [
      "https://vomba.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "vomba.cachix.org-1:Me8oTzj1jpd5kcE0Yz2pKzX2C9SGnT951OXSwsfv19I="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Setup home-manager
  # Users can be defined either directly in this file, or in a separate file and
  # imported here.
  users.users.vomba = {
    name = "vomba";
    home = "/Users/vomba";
    shell = pkgs.zsh;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      # You can pass any extra arguments to your home-manager modules
      inherit pkgs-stable;
      inherit inputs;
      obsidian-plugins = inputs.obsidian-plugins;
    };
    users.vomba = import ./home.nix;
  };
}
