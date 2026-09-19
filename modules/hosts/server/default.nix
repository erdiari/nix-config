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

  flake.nixosModules.serverConfiguration = { pkgs, ... }: {
    imports = [ ./_hardware-configuration.nix ];

    networking.hostName = "home-boy";
    networking.networkmanager.enable = true;

    services.tailscale.extraUpFlags = [ "--ssh" "--hostname=home-boy" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.enable = false;

    users.users.erd = {
      isNormalUser = true;
      description = "erd";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    environment.systemPackages = with pkgs; [
      curl
      git
      htop
      tmux
      vim
      wget
    ];

    system.stateVersion = "26.05";
  };
}
