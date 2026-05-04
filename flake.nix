{
  description = "Home Manager and Nix-Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/25.11";
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
    everything-claude-code = {
      url = "github:affaan-m/everything-claude-code/v1.10.0";
      flake = false;
    };
    obsidian-plugins = {
      url = "github:vomba/obsidian-plugins-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      nix-darwin,
      nur,
      ...
    }@inputs:
    let
      sharedOverlays = [
        (import ./overlays/default.nix { inherit inputs; })
        nur.overlays.default
        inputs.obsidian-plugins.overlays.default
      ];
      pkgsConfig = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };

      # Helper to instantiate nixpkgs with our config and overlays
      mkPkgs =
        system: pkgSource:
        import pkgSource {
          inherit system;
          config = pkgsConfig;
          overlays = sharedOverlays;
        };

      # Linux configuration
      linux-system = "x86_64-linux";
      linux-pkgs = mkPkgs linux-system nixpkgs;
      linux-pkgs-stable = mkPkgs linux-system inputs.nixpkgs-stable;

      # macOS configuration
      darwin-system = "aarch64-darwin";
      darwin-pkgs = mkPkgs darwin-system nixpkgs;
      darwin-pkgs-stable = mkPkgs darwin-system inputs.nixpkgs-stable;

    in
    {
      formatter = {
        ${linux-system} = nixpkgs.legacyPackages.${linux-system}.nixfmt;
        ${darwin-system} = nixpkgs.legacyPackages.${darwin-system}.nixfmt;
      };

      homeConfigurations."hani" = home-manager.lib.homeManagerConfiguration {
        pkgs = linux-pkgs;
        extraSpecialArgs = {
          pkgs-stable = linux-pkgs-stable;
          nur = nur;
          nixGL = inputs.nixGL;
          obsidian-plugins = inputs.obsidian-plugins;
          inherit inputs;
        };
        modules = [
          inputs.nix-index-database.homeModules.nix-index
          ./home.nix
          ./linux.nix
        ];
      };

      darwinConfigurations."Mac" = nix-darwin.lib.darwinSystem {

        pkgs = darwin-pkgs;
        specialArgs = {
          pkgs-stable = darwin-pkgs-stable;
          nur = nur;
          inherit inputs;
        };
        modules = [
          { nixpkgs.hostPlatform = darwin-system; }
          ./darwin.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
