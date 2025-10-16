
self: super:
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in
{
  cidr = pkgs.callPackage ./cidr.nix { };
}
