# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  unstable-pkgs,
  ...
}: {
  imports = [
  ];

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "erd";
    homeDirectory = "/home/erd";
  };

  home.packages = with pkgs; [
    tilix
    # Editors
    neovim
    emacs
    vscodium-fhs
    vscode
    # Clipboard manager for nvim
    xclip
    # Apps
    flatpak
    gnome.gnome-software
    mpv
    # Terminal Apps
    ripgrep
    fd
    btop
    bat
    yt-dlp
    pandoc
    tectonic
    yazi
    ueberzugpp
    # Gaming
    steam
    heroic
    gamemode
    mangohud
    # Gnome extensions
    gnomeExtensions.pano
    gnomeExtensions.tailscale-status
    gnomeExtensions.syncthing-indicator
    # gnomeExtensions.gpu-profile-selector
    # nixpkgs-unstable.conda
    unstable-pkgs.python3
    unstable-pkgs.conda
    # ollama
  ];


  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Erdi ARI";
    userEmail = "me@erdiari.dev";
    lfs.enable = true;
  };

  services.ssh-agent.enable = true;

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # Kitty - terminal with image support
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    defaultKeymap = "viins";

    shellAliases = {
      v = "nvim";
      install-homemanager = "home-manager switch --flake ~/Documents/nix-config/home-manager/home.nix#default";
      doom = "./.emacs.d/bin/doom";
    };
  };

  services.syncthing.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
