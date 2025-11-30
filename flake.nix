{
  description = "Home Manager and Nix-Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-25.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nur, ... }@inputs:
    let
      sharedOverlays = [ (import ./overlays/default.nix) nur.overlays.default ];
      pkgsConfig = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };

      # Linux configuration
      linux-system = "x86_64-linux";
      linux-pkgs = import nixpkgs {
        system = linux-system;
        config = pkgsConfig;
        overlays = sharedOverlays;
      };
      linux-pkgs-stable = import inputs.nixpkgs-stable {
        system = linux-system;
        config = pkgsConfig;
        overlays = sharedOverlays;
      };
      linux-pkgs-25 = import inputs.nixpkgs-25 {
        system = linux-system;
        config = pkgsConfig;
        overlays = sharedOverlays;
      };

      # macOS configuration
      darwin-system = "aarch64-darwin";

    in
    {
      homeConfigurations."hani" = home-manager.lib.homeManagerConfiguration {
        pkgs = linux-pkgs;
        extraSpecialArgs = {
          pkgs-stable = linux-pkgs-stable;
          pkgs-25 = linux-pkgs-25;
          nur = nur;
          nixGL = inputs.nixGL;
        };
        modules = [
          inputs.nix-index-database.homeModules.nix-index
          ./home.nix
          ./linux.nix
        ];
      };

      darwinConfigurations."Mac" = nix-darwin.lib.darwinSystem {
        system = darwin-system;
        specialArgs = {
          pkgs-stable = import inputs.nixpkgs-stable { system = darwin-system; config = pkgsConfig; overlays = sharedOverlays; };
          pkgs-25 = import inputs.nixpkgs-25 { system = darwin-system; config = pkgsConfig; overlays = sharedOverlays; };
          nur = nur;
        };
        modules = [ ./darwin.nix ];
      };
    };
}
