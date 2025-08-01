{ inputs, lib, config, pkgs, unstable-pkgs, ... }: {

  imports = [ ../nixos/modules/stylix.nix ./yazi.nix ./default.nix ];

  home = {
    username = "erd";
    homeDirectory = "/home/erd";
  };

  # Linux-specific packages
  home.packages = with pkgs; [
    # Linux-specific editors
    geany
    kdePackages.dolphin
    # For screenshots (Linux/Wayland)
    grim
    slurp
    # Clipboard manager for nvim (Linux/Wayland)
    wl-clipboard
    # Linux-specific apps
    flatpak
    deadbeef # music player
    tilix
    ueberzugpp
    cliphist
    brightnessctl
    poweralertd
    # Office suite (not available on macOS ARM64)
    libreoffice-qt6-fresh
    # Gaming (Linux)
    steam-run
    gamemode
    mangohud
  ] ++ (with unstable-pkgs; [
    vesktop
    heroic
  ]);

  # Linux-specific git configuration
  programs.git = {
    userName = "Erdi ARI";
    userEmail = "me@erdiari.dev";
  };

  # Linux-specific shell aliases
  programs.zsh.shellAliases = {
    install-homemanager = "home-manager switch --flake ~/Documents/nix-config#erd";
    doom = "~/.emacs.d/bin/doom";
  };

  services.ssh-agent.enable = true;

  # NCspot -> Ncurses spotify client
  programs.ncspot = {
    enable = true;
    settings = {
      use_nerdfont = true;
      cover.enable = true;
    };
    package = unstable-pkgs.ncspot.override { withCover = true; };
  };

  # Kitty - terminal with image support
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 10;
      font_family = "SauceCodePro Nerd Font";
      font_size = 12;
    };

    extraConfig = ''
      # Jump around neighboring window Vi key binding
      map ctrl+shift+w>h neighboring_window left
      map ctrl+shift+w>l neighboring_window right
      map ctrl+shift+w>j neighboring_window down
      map ctrl+shift+w>k neighboring_window up

      map ctrl+shift+w>shift+h move_window left
      map ctrl+shift+w>shift+l move_window right
      map ctrl+shift+w>shift+j move_window down
      map ctrl+shift+w>shift+k move_window up

      # Create a new window splitting the space used by the existing one so that
      # the two windows are placed one above the other
      map ctrl+shift+w>s launch --location=hsplit

      # Create a new window splitting the space used by the existing one so that
      # the two windows are placed side by side
      map ctrl+shift+w>v launch --location=vsplit

      # Use nvim as the pager. Remove all ASCII formatting characters.
      scrollback_pager nvim --noplugin -c 'set buftype=nofile' -c 'set noswapfile' -c 'silent! %s/\%x1b\[[0-9;]*[sumJK]//g' -c 'silent! %s/\%x1b]133;[A-Z]\%x1b\\//g' -c 'silent! %s/\%x1b\[[^m]*m//g' -c 'silent! %s///g' -
    '';
  };

  services.syncthing.enable = true;

  # lorri for faster direnv
  services.lorri.enable = true;

  # Configurations -> Will use symbolic links to configure
  home.file.".config" = {
    source = ./external-config;
    recursive = true;
  };

  # doom emacs configuration, requires manual installation of doom emacs
  home.file.".doom.d" = {
    source = ./doom.d;
    recursive = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}