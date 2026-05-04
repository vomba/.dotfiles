{ inputs }:
let
  languages = import ./languages.nix { inherit inputs; };
  python = import ./python.nix { };
in
self: super:
languages self super
// python self super
// {
  cidr = super.callPackage ./cidr.nix { };
  openstack-tui = super.callPackage ./openstack-tui.nix { };
  kubernetes-helm = import ./helm.nix { inherit super; };
  helmfile = import ./helmfile.nix { inherit super; };
}
