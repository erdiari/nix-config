{ config, pkgs, lib, ... }: {
  imports = [
    ../defaults.nix
    ../../modules/hyperland.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "excalibur";

  # Blueman -> Bluetooth manager
  services.blueman.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allows the usage of nvidia gpus in docker
  hardware.nvidia-container-toolkit.enable = true;

  # Above will be deprecated later. Switch to option below
  # virtualisation.containers.cdi.dynamic.nvidia.enable

  # Enable OpenGL
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
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

  # Built also with sync setting for gaming-time
  # Source: https://youtu.be/qlfm3MEbqYA
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
