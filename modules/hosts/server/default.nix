{ self, inputs, ... }:
{
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = [
      self.nixosModules.headlessServer
      self.nixosModules.serverConfiguration
    ];
  };

  flake.nixosModules.serverConfiguration = { ... }: {
    imports = [ ./_hardware-configuration.nix ];

    networking.hostName = "server";

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
    };

    users.users.erd = {
      isNormalUser = true;
      description = "erd";
      extraGroups = [ "wheel" ];
    };

    system.stateVersion = "24.11";
  };
}
