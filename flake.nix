{
  description = "My Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:bb010g/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      nixGL,
      ...
    }:
    {
      homeConfigurations = {
        "hani" = inputs.home-manager.lib.homeManagerConfiguration {
          # pkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config = {
              allowUnfree = true;
              allowUnfreePredictate = _: true;
            };
          };
          extraSpecialArgs = {
            inherit nixGL;
            pkgs-stable = import nixpkgs-stable {
              system = "x86_64-linux";
              config = {
                allowUnfree = true;
                allowUnfreePredictate = _: true;
              };
            };
          };
          modules = [
            ./home.nix
            {
              home = {
                username = "hani";
                homeDirectory = "/home/hani";
                stateVersion = "25.05";
              };
            }
          ];
        };
      };
      hani = self.homeConfigurations.hani.activationPackage;
      defaultPackage.x86_64-linux = self.hani;
    };
}
