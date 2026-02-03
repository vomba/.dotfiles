{
  description = "Home Manager and Nix-Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/24.11";
    nixpkgs-25.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-25,
      home-manager,
      nix-darwin,
      nur,
      ...
    }@inputs:
    let
      sharedOverlays = [
        (import ./overlays/default.nix { inherit inputs; })
        nur.overlays.default
      ];
      pkgsConfig = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };

      # Helper to instantiate nixpkgs with our config and overlays
      mkPkgs = system: pkgSource: import pkgSource {
        inherit system;
        config = pkgsConfig;
        overlays = sharedOverlays;
      };

      # Linux configuration
      linux-system = "x86_64-linux";
      linux-pkgs        = mkPkgs linux-system nixpkgs;
      linux-pkgs-stable = mkPkgs linux-system inputs.nixpkgs-stable;
      linux-pkgs-25     = mkPkgs linux-system inputs.nixpkgs-25;

      # macOS configuration
      darwin-system = "aarch64-darwin";
      darwin-pkgs        = mkPkgs darwin-system nixpkgs;
      darwin-pkgs-stable = mkPkgs darwin-system inputs.nixpkgs-stable;
      darwin-pkgs-25     = mkPkgs darwin-system inputs.nixpkgs-25;

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
        pkgs = darwin-pkgs;
        specialArgs = {
          pkgs-stable = darwin-pkgs-stable;
          pkgs-25 = darwin-pkgs-25;
          nur = nur;
        };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
