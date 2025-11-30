self: super:
{
  cidr = super.callPackage ./cidr.nix { };
}
