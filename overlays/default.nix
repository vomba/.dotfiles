{ inputs }:
let
  languages = import ./languages.nix { inherit inputs; };
in
self: super:
languages self super
// {
  cidr = super.callPackage ./cidr.nix { };
  openstack-tui = super.callPackage ./openstack-tui.nix { };
  kubernetes-helm = import ./helm.nix { inherit super; };
  helmfile = import ./helmfile.nix { inherit super; };
  sops = import ./sops.nix { inherit super; };
}
