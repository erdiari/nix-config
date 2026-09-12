{ ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  flake.nixosModules.nixosDefaults =
    {
      inputs,
      lib,
      config,
      pkgs,
      ...
    }:
    {
      nixpkgs = {
        overlays = [ ];
      };

      nix =
        let
          flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
        in
        {
          settings = {
            experimental-features = [ "nix-command" "flakes" ];
            flake-registry = "";
            nix-path = config.nix.nixPath;
            extra-substituters = [
              "https://nix-community.cachix.org"
              "https://hyprland.cachix.org"
              "https://devenv.cachix.org"
              "https://noctalia.cachix.org"
              "https://cache.nixos-cuda.org"
            ];
            extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
              "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
              "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            ];
          };
          channel.enable = false;
          registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
          nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
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

      system.autoUpgrade = {
        enable = true;
        dates = "weekly";
      };

      services.flatpak.enable = true;

      networking.nameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];

      services.resolved = {
        enable = true;
        settings.Resolve = {
          DNSSEC = "true";
          Domains = [ "~." ];
          FallbackDNS = [
            "1.1.1.1#one.one.one.one"
            "1.0.0.1#one.one.one.one"
          ];
          DNSOverTLS = "true";
        };
      };

      programs.kdeconnect = {
        enable = true;
      };

      networking.networkmanager.enable = true;

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = [ "erd" ];
      virtualisation.libvirtd.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;

      time.timeZone = "Europe/Istanbul";

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

      services.xserver.enable = true;
      services.displayManager = {
        enable = true;
        sddm.enable = true;
      };

      services.desktopManager.plasma6.enable = true;
      environment.plasma6.excludePackages = [ pkgs.kdePackages.ksshaskpass ];

      services.xserver = {
        xkb.layout = "tr";
        xkb.variant = "";
      };

      console.keyMap = "trq";

      services.printing.enable = true;
      services.pulseaudio.enable = false;

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.openssh = {
        enable = true;
        settings = {
          X11Forwarding = true;
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
        openFirewall = true;
      };

      services.libinput.enable = true;

      programs.zsh.enable = true;

      users.users.erd = {
        isNormalUser = true;
        description = "erd";
        extraGroups = [
          "networkmanager"
          "wheel"
          "lp"
        ];
        # packages = with pkgs; [ floorp-bin brave winetricks ];
        shell = pkgs.zsh;
      };

      services.udev.extraRules = ''
        # Set permissions for POS58 USB thermal receipt printer
        SUBSYSTEM=="usb", ATTR{idVendor}=="0416", ATTR{idProduct}=="5011", MODE="0666"
      '';

      environment.systemPackages = with pkgs; [
        vim
        wget
        git
        coreutils
        clang
        lshw
        wine
        wine64
        mangohud
        # bottles
        easyeffects
        pwvucontrol
        mangohud
        podman-compose
        podman-tui
        cachix
      ];

      fonts.packages = with pkgs; [
        nerd-fonts._0xproto
        nerd-fonts.droid-sans-mono
        nerd-fonts.sauce-code-pro
        dejavu_fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
      ];

      networking.firewall = {
        enable = true;
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [
          22000
          21027
        ];
        allowedTCPPorts = [ 22000 ];
      };

      environment.variables.EDITOR = "nvim";

      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "client";
      };

      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

      programs.tmux = {
        enable = true;
        extraConfig = ''
          ...
          set -g status-right '#[fg=black,bg=color15] #{cpu_percentage}  %H:%M '
          run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
        '';
      };

      security.pam.services.erd.enableGnomeKeyring = true;
      programs.nix-ld.enable = true;
    };
}
