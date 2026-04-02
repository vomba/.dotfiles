# Common library functions for dotfiles
#
# This module provides shared utility functions used across modules.

{ lib }:

{
  # Create an optional package that's only added if the condition is true
  # Usage: optionalPackage pkgs.stdenv.isLinux somePackage
  optionalPackage = condition: package: lib.optionalDerivation (lib.mkIf condition package);

  # Enable a module conditionally based on a profile option
  # Usage: mkProfileEnable config.profiles.development
  mkProfileEnable = profile: lib.mkIf profile.enable;

  # Convert a list of strings to a space-separated string
  # Usage: toSpaces [ "one" "two" "three" ] -> "one two three"
  toSpaces = lib.concatStringsSep " ";

  # Check if we're on a specific operating system
  isLinux = pkgs: pkgs.stdenv.isLinux;
  isDarwin = pkgs: pkgs.stdenv.isDarwin;
}
