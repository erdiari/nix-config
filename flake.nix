{
  description = "Global Flake File";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # zen-browser = {
    #   url = "github:0xc000022070/zen-browser-flake";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    # zen-browser = {
    #   url = "github:NikSneMC/zen-browser-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, ... }@inputs:
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
            pkgs = pkgsFor system;
            unstable-pkgs = unstablePkgsFor system;
          };
          modules = commonModules ++ [ ./nixos/instances/${hostname} ]
            ++ extraModules;
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

      # Home-manager configuration that uses the same pkgs as NixOS
      homeConfigurations = {
        erd = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "x86_64-linux";
          extraSpecialArgs = {
            inherit inputs outputs;
            unstable-pkgs = unstablePkgsFor "x86_64-linux";
          };
          modules =
            [ stylix.homeManagerModules.stylix ./home-manager/home.nix ];
        };
      };
    };
}
