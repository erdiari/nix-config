{ self, inputs, ... }: {
  flake.nixosConfigurations.thinkpad-t430 = inputs.nixpkgs.lib.nixosSystem {
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
      self.nixosModules.thinkpadT430Configuration
    ];
  };

  flake.nixosModules.thinkpadT430Configuration = { ... }: {
    imports = [ ./_hardware-configuration.nix ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;

    services.thermald.enable = true;

    networking.hostName = "thinkpad-t430";

    system.stateVersion = "23.05";
  };
}
