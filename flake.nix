{
  description = "My Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    {
      homeConfigurations = {
        "hani" = inputs.home-manager.lib.homeManagerConfiguration {
          # pkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgs = import nixpkgs {
            system = "x86_64-linux";
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
