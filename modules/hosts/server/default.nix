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

  flake.nixosModules.serverConfiguration = { config, pkgs, ... }: {
    imports = [
      ./_hardware-configuration.nix
      ./_immich.nix
      ./_media-stack.nix
    ];

    nixpkgs.config.allowUnfree = true;

    networking.hostName = "home-boy";
    networking.networkmanager.enable = true;
    networking.interfaces.enp30s0.wakeOnLan.enable = true;


    services.tailscale.extraUpFlags = [ "--ssh" "--hostname=home-boy" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.enable = false;

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      modesetting.enable = true;
    };

    users.users.erd = {
      isNormalUser = true;
      description = "erd";
      extraGroups = [ "networkmanager" "wheel" "media" ];
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "erd";
    };

    environment.systemPackages = with pkgs; [
      curl
      ethtool
      git
      htop
      nzbget
      tmux
      vim
      wget
    ];

    services.nfs.server = {
      enable = true;
      exports = ''
        /home/erd/share 100.120.62.91(rw,sync,no_subtree_check,root_squash)
      '';
    };

    systemd.tmpfiles.settings.homeBoyShare."/home/erd/share"."d" = {
      mode = "2775";
      user = "erd";
      group = "users";
    };

    system.stateVersion = "26.05";
  };
}
