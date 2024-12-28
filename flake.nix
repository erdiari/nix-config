{
  description = "Global Flake File";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Stylix
    stylix.url = "github:danth/stylix/release-24.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # NvChad -> Neovim config
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    stylix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    unstable-pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
    commonModules = [
      ./nixos/instances/defaults.nix
      stylix.nixosModules.stylix
      ./nixos/modules/stylix.nix
    ];
  in {
    nixConfig = {
      extra-substituters = [
        "https://nix-community.cachix.org" "https://hyprland.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    nixosConfigurations = {
      excalibur = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = commonModules ++ [./nixos/instances/excalibur];
      };
      thinkpad-t430 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = commonModules ++ [./nixos/instances/thinkpad-t430];
      };
      desktop = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = commonModules ++ [./nixos/instances/desktop];
      };
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      erd = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs unstable-pkgs;};
        modules = [ stylix.homeManagerModules.stylix ./home-manager/home.nix];
      };
    };
  };
}
