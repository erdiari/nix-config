{ inputs, lib, config, pkgs, ... }: {
  imports = [ ];

  nixpkgs = {
    overlays = [ ];
  };

  nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    # garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      trusted-users = root erd
    '';
    settings.auto-optimise-store = true;
  };

  # Auto update
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  # Flatpak
  services.flatpak.enable = true;

  networking.nameservers =
    [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    dnsovertls = "true";
  };

  # Enable kdeconnect
  programs.kdeconnect = { enable = true; };

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable app image and tell kernel use `appimage-run` to run binary
  programs.appimage = {enable = true; binfmt = true;};


  # Docker - Requires user to be in docker group to use without sudo.

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Virtual machine
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["erd"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";

    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager = {
    enable = true;
    sddm.enable = true;
  };
  # programs.regreet = {
  #   enable = true;
  #   font.size = 12;
  # };

  # services.xserver.displayManager.gdm.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.desktopManager.gnome.enable = true;
  services.desktopManager.plasma6.enable = true;
  # plasma6 tries to enable ksshaskpass which conflicts with ssh-askpass
  environment.plasma6.excludePackages = [ pkgs.kdePackages.ksshaskpass ];
  programs.ssh.askPassword =
    pkgs.lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "tr";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "trq";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  programs.zsh.enable = true;

  users.users.erd = {
    isNormalUser = true;
    description = "erd";
    # docker group is for using docker as non-root user.
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ floorp brave winetricks ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    coreutils # basic GNU utilities
    clang
    lshw
    wine
    wine64
    mangohud
    bottles
    easyeffects # Audio effects for PipeWire applications.
    pwvucontrol # Audio volume controller for pipewire
    # gnome-network-displays
    mangohud
    veikk-linux-driver-gui # Drawing tablet driver
    podman-compose
    podman-tui
    cachix
  ];

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
  ];

  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # 22000 TCP/UDP and 21027 UDP ports are opened because of syncthing
    allowedUDPPorts = [ 22000 21027 ];
    allowedTCPPorts = [ 22000 ];
  };

  environment.variables.EDITOR = "nvim";

  # Power management and cpu scaling for laptops
  # powerManagement.enable = true;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };

  # Gaming stuff
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall =
      true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # TMUX: Terminal multiplexer
  programs.tmux = {
    enable = true;
    extraConfig = ''
      ...
      set -g status-right '#[fg=black,bg=color15] #{cpu_percentage}  %H:%M '
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
  };

  security.pam.services.erd.enableGnomeKeyring = true;
  programs.nix-ld.enable = true;
}
