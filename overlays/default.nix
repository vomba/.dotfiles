{ inputs }:
self: super:
{
  cidr = super.callPackage ./cidr.nix { };

  # Pin Swift to 5.8 from stable
  swift = inputs.nixpkgs-stable.legacyPackages.${self.system}.swift;
  swiftPackages = inputs.nixpkgs-stable.legacyPackages.${self.system}.swiftPackages;
  swift_5_10 = inputs.nixpkgs-stable.legacyPackages.${self.system}.swift;

  # Pin Dotnet to stable versions
  dotnet-sdk = inputs.nixpkgs-stable.legacyPackages.${self.system}.dotnet-sdk;
  
  # Patch dotnetCorePackages to include missing attributes from unstable
  dotnetCorePackages = inputs.nixpkgs-stable.legacyPackages.${self.system}.dotnetCorePackages // {
    sdk_9_0_1xx-bin = inputs.nixpkgs-stable.legacyPackages.${self.system}.dotnet-sdk;
  };

  dotnet-sdk_8 = inputs.nixpkgs-stable.legacyPackages.${self.system}.dotnet-sdk_8;

  # Pin Marksman to stable to avoid unstable dotnet dependency issues
  marksman = inputs.nixpkgs-stable.legacyPackages.${self.system}.marksman;
}