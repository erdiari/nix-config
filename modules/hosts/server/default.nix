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

    time.timeZone = "Europe/Istanbul";

    nix = {
      settings.experimental-features = [ "nix-command" "flakes" ];
      gc = {
        automatic = true;
        dates = "Sun 03:15";
        options = "--delete-older-than 30d";
      };
    };

    services.logrotate = {
      enable = true;
      settings.header = {
        frequency = "daily";
        rotate = 14;
        compress = true;
        delaycompress = true;
        maxsize = "100M";
      };
    };
    # NixOS sends authentication/service logs to journald, not auth.log.
    services.journald.settings.Journal = {
      Storage = "persistent";
      SystemMaxUse = "512M";
      SystemKeepFree = "2G";
      RuntimeMaxUse = "128M";
      MaxRetentionSec = "30day";
    };

    system.autoUpgrade = {
      enable = true;
      flake = "github:erdiari/nix-config/main#server";
      upgrade = false; # Flake inputs are refreshed explicitly below, not via channels.
      flags = [
        "--accept-flake-config"
        "--override-input" "nixpkgs" "github:nixos/nixpkgs/nixos-unstable"
        "--no-write-lock-file"
      ];
      dates = "04:40";
      persistent = false; # Do not catch up on missed upgrades during daytime use.
      allowReboot = true;
      rebootWindow = {
        lower = "04:30";
        upper = "06:00";
      };
    };

    # Keep this headless server available even when no users are logged in.
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
      suspend-then-hibernate.enable = false;
    };

    networking.hostName = "home-boy";
    networking.networkmanager.enable = true;
    networking.interfaces.enp30s0.wakeOnLan.enable = true;


    services.tailscale.extraUpFlags = [ "--ssh" "--hostname=home-boy" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.enable = false;

    hardware.graphics.enable = true;
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
