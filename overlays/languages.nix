{ inputs }:
self: super: {
  swift = inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.swift;
  swiftPackages =
    inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.swiftPackages;
  swift_5_10 = inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.swift;

  dotnet-sdk = inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.dotnet-sdk;
  dotnetCorePackages =
    inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.dotnetCorePackages
    // {
      sdk_9_0_1xx-bin =
        inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.dotnet-sdk;
    };
  dotnet-sdk_8 = inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.dotnet-sdk_8;

  marksman = inputs.nixpkgs-stable.legacyPackages.${self.stdenv.hostPlatform.system}.marksman;
}
