{
  description = "Global Flake File";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixpkgs-unstable, home-manager, nix-darwin, stylix, ... }@inputs:
    let
      inherit (self) outputs;

      # Create a consistent pkgs for each system
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      unstablePkgsFor = system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      # Shared modules for all NixOS configurations
      commonModules = [
        ./nixos/instances/defaults.nix
        stylix.nixosModules.stylix
        ./nixos/modules/stylix.nix
      ];

      # Function to create a NixOS configuration
      mkNixosConfig = { system ? "x86_64-linux", hostname, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
            unstable-pkgs = unstablePkgsFor system;
          };
          modules = commonModules ++ [ ./nixos/instances/${hostname} ]
            ++ extraModules ++ [{ nixpkgs.pkgs = pkgsFor system; }];
        };

      # Function to create a Darwin configuration
      mkDarwinConfig = { system ? "aarch64-darwin", hostname, extraModules ? [ ] }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
            unstable-pkgs = unstablePkgsFor system;
          };
          modules = [ 
            ./darwin/instances/${hostname}/default.nix
          ] ++ extraModules ++ [
            {
              nixpkgs.pkgs = pkgsFor system;
            }
          ];
        };
    in {
      nixConfig = {
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://devenv.cachix.org"
          "https://cuda-maintainers.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        ];
      };

      nixosConfigurations = {
        thinkpad-t430 = mkNixosConfig { hostname = "thinkpad-t430"; };
        hp = mkNixosConfig { hostname = "hp"; };
        desktop = mkNixosConfig { hostname = "desktop"; };
      };

      darwinConfigurations = {
        mac-m1 = mkDarwinConfig { hostname = "mac-m1"; system = "aarch64-darwin"; };
        mac-intel = mkDarwinConfig { hostname = "mac-m1"; system = "x86_64-darwin"; };
      };

      # Home-manager configuration that uses the same pkgs as NixOS
      homeConfigurations = {
        erd = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          extraSpecialArgs = {
            inherit inputs outputs;
            unstable-pkgs = unstablePkgsFor "x86_64-linux";
          };
          modules =
            [ stylix.homeModules.stylix ./home-manager/linux.nix ];
        };
        
        # macOS configuration
        mac-m1 = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "aarch64-darwin";
          extraSpecialArgs = {
            inherit inputs outputs;
            unstable-pkgs = unstablePkgsFor "aarch64-darwin";
          };
          modules = [
            stylix.homeModules.stylix 
            ./home-manager/darwin.nix
          ];
        };
        mac-intel = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-darwin";
          extraSpecialArgs = {
            inherit inputs outputs;
            unstable-pkgs = unstablePkgsFor "x86_64-darwin";
          };
          modules = [
            stylix.homeModules.stylix 
            ./home-manager/darwin.nix
          ];
        };
      };
    };
}
