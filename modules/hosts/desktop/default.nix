{ self, inputs, ... }: {
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
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
      self.nixosModules.desktopConfiguration
    ];
  };

  flake.nixosModules.desktopConfiguration = { config, pkgs, lib, ... }: {
    imports = [ ./_hardware-configuration.nix ];

    networking.hostName = "desktop";

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;

    hardware.nvidia-container-toolkit.enable = true;
    virtualisation.docker.daemon.settings.features.cdi = true;

    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    services.printing.enable = true;
    services.printing.drivers = with pkgs; [
      gutenprint
      gutenprintBin
      cnijfilter2
      cups-zj-58
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    environment.systemPackages = with pkgs; [ cudaPackages.cudatoolkit ];

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        "public" = {
          "path" = "/mnt/depo_1/public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "comment" = "Erd file share";
        };
      };
    };

    system.stateVersion = "24.11";
  };
}
