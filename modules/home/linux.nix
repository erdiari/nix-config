{ inputs, pkgs, unstable-pkgs, ... }: {
  imports = [
    inputs.stylix.homeModules.stylix
    ./noctalia.nix
    ./default.nix
  ];

  home = {
    username = "erd";
    homeDirectory = "/home/erd";
  };

  programs.direnv = {
    enableZshIntegration = true;
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs;
    [
      yaak
      geany
      kdePackages.dolphin
      devenv
      grim
      slurp
      wl-clipboard
      flatpak
      deadbeef
      tilix
      ueberzugpp
      cliphist
      brightnessctl
      poweralertd
      libreoffice-qt6-fresh
      steam-run
      gamemode
      mangohud
    ] ++ (with unstable-pkgs;
      [
        heroic
        logseq
      ]);

  programs.git = {
    userName = "Erdi ARI";
    userEmail = "me@erdiari.dev";
  };

  programs.zsh.shellAliases = {
    install-homemanager =
      "home-manager switch --flake ~/Documents/nix-config#erd";
    doom = "~/.emacs.d/bin/doom";
  };

  services.ssh-agent.enable = true;

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
      map ctrl+shift+w>h neighboring_window left
      map ctrl+shift+w>l neighboring_window right
      map ctrl+shift+w>j neighboring_window down
      map ctrl+shift+w>k neighboring_window up

      map ctrl+shift+w>shift+h move_window left
      map ctrl+shift+w>shift+l move_window right
      map ctrl+shift+w>shift+j move_window down
      map ctrl+shift+w>shift+k move_window up

      map ctrl+shift+w>s launch --location=hsplit
      map ctrl+shift+w>v launch --location=vsplit

      scrollback_pager nvim --noplugin -c 'set buftype=nofile' -c 'set noswapfile' -c 'silent! %s/\%x1b\[[0-9;]*[sumJK]//g' -c 'silent! %s/\%x1b]133;[A-Z]\%x1b\\//g' -c 'silent! %s/\%x1b\[[^m]*m//g' -c 'silent! %s///g' -
    '';
  };

  services.syncthing.enable = true;
  services.lorri.enable = true;

  home.file.".config" = {
    source = ./external-config;
    recursive = true;
  };

  systemd.user.startServices = "sd-switch";
}
