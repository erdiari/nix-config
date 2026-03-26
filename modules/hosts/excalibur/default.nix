{ self, inputs, ... }: {
  flake.nixosConfigurations.excalibur = inputs.nixpkgs.lib.nixosSystem {
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
      self.nixosModules.excaliburConfiguration
    ];
  };

  flake.nixosModules.excaliburConfiguration = { config, pkgs, lib, ... }: {
    imports = [ ./hardware-configuration.nix ];

    networking.hostName = "excalibur";

    services.blueman.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    hardware.nvidia-container-toolkit.enable = true;
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    specialisation = {
      gaming-time.configuration = {
        hardware.nvidia = {
          powerManagement.finegrained = lib.mkForce false;
          prime.sync.enable = lib.mkForce true;
          prime.offload = {
            enable = lib.mkForce false;
            enableOffloadCmd = lib.mkForce false;
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [ cudaPackages.cudatoolkit ];

    system.stateVersion = "23.05";
  };
}
