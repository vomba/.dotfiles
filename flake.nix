{
  description = "Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-25.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
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
    nur.url = "github:nix-community/nur";
  };

  outputs =
    {

      home-manager,
      nix-index-database,
      nixGL,
      nixpkgs-stable,
      nixpkgs,
      nixpkgs-25,
      nur,
      ...
    }:
    let
      overlays = [
        (import ./overlays/default.nix)
        (import ./overlays/pinned.nix { inherit pkgs-stable pkgs-25; })
      ];
      system = "x86_64-linux";
      pkgsConfig = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        inherit overlays;
      };
      mkPkgs =
        nixpkgs:
        import nixpkgs {
          inherit system overlays;
          config = pkgsConfig;
        };
      pkgs = mkPkgs nixpkgs;
      pkgs-stable = mkPkgs nixpkgs-stable;
      pkgs-25 = mkPkgs nixpkgs-25;

    in
    {
      homeConfigurations."hani" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit
            nur
            ;
        };
        # Useful stuff for managing modules between hosts
        # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration
        modules = [
          nix-index-database.homeModules.nix-index
          ./home.nix
        ];
      };
    };
}
