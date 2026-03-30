{ self, inputs, ... }: {
  flake.nixosConfigurations.hp = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      unstable-pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };
    modules = [
      { nixpkgs.config.allowUnfree = true; }
      self.nixosModules.nixosDefaults
      self.nixosModules.stylix
      self.nixosModules.noctalia
      self.nixosModules.hyperland
      self.nixosModules.hpConfiguration
    ];
  };

  flake.nixosModules.hpConfiguration = { ... }: {
    imports = [ ./hardware-configuration.nix ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "elitebook";

    system.stateVersion = "23.05";
  };
}
