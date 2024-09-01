{
  inputs,
  lib,
  config,
  pkgs,
  unstable-pkgs,
  ...
}: 
let
  external_config = pkgs.copyPathToStore ./external-config;
  # debug = builtins.trace "Current directory: ${builtins.toString ./.}" true;
  # debugExternalConfig = builtins.trace "external_config contents: ${builtins.toString (builtins.readDir ./external_config)}" true;
  # externalConfig = 
  #   if builtins.pathExists ./external_config
  #   then builtins.path { path = ./external_config; name = "external_config"; }
  #   else throw "external_config directory not found at ${toString ./external_config}";
in 
{
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
    affine
    # Terminal Apps
    tilix
    ripgrep
    fd
    btop
    bat
    yt-dlp
    pandoc
    tectonic
    yazi
    ueberzugpp
    eza
    fzf
    zoxide
    cliphist
    # Gaming
    steam
    heroic
    gamemode
    mangohud
    # Gnome extensions
    gnomeExtensions.tailscale-status
    gnomeExtensions.syncthing-indicator
    unstable-pkgs.gnomeExtensions.pano
    # Python
    unstable-pkgs.python3
    unstable-pkgs.conda
    unstable-pkgs.wezterm
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

  # # Wezterm - terminal with better settings
  # programs.wezterm = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   # extraConfig = ''
  #   #   local config = wezterm.config_builder()
  #   #   config.enable_wayland = true
  #   #   return config
  #   # '';
  # };
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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
      ls = "eza --icons=always";
      lt = "ls -T";
      la = "ls -al";
    };

    initExtra = ''
      eval "$(zoxide init zsh)"
    '';

    plugins = with pkgs; [
      {
        name = "formarks";
        src = fetchFromGitHub {
          owner = "wfxr";
          repo = "formarks";
          rev = "8abce138218a8e6acd3c8ad2dd52550198625944";
          sha256 = "1wr4ypv2b6a2w9qsia29mb36xf98zjzhp3bq4ix6r3cmra3xij90";
        };

        file = "formarks.plugin.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
   ];
  };

  services.syncthing.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # # Configurations -> Will use symbolic links to configure
  home.file."${config.xdg.configHome}" = {
  # home.file.".config" = {
    source = external_config;
    recursive = true;
  };
  
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
