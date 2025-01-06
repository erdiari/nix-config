{
  inputs,
  lib,
  config,
  pkgs,
  unstable-pkgs,
  ...
}:
{
  imports = [
    ../nixos/modules/stylix.nix
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
    emacs
    vscode
    geany
    neovide
    zed-editor
    unstable-pkgs.neovim
    # LSPs
    ruff
    basedpyright
    # For screenshots
    grim
    slurp
    # Clipboard manager for nvim
    # xclip #X-server
    wl-clipboard #Wayland
    # Apps
    flatpak
    # gnome.gnome-software
    mpv
    deadbeef # music player
    vesktop
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
    brightnessctl
    poweralertd
    # Gaming
    steam
    heroic
    gamemode
    mangohud
    # Python
    unstable-pkgs.python3
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

  # NCspot -> Ncurses spotify client
  programs.ncspot = {
    enable = true;
    settings = {
      use_nerdfont = true;
    };
    package = unstable-pkgs.ncspot; # There is bug in previous versions of ncspot which makes it unusable
  };

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
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 10;
      # background_opacity = "0.5";
      # background_blur = 5;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
      enableZshIntegration = true;
      enable = true;
      nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    autosuggestion = {
      enable = true;
      # strategy = "history";
    };

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
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
          sha256 = "1b4pksrc573aklk71dn2zikiymsvq19bgvamrdffpf7azpq6kxl2";
        };
      }
    ];
  };

  services.syncthing.enable = true;

  # # Configurations -> Will use symbolic links to configure
  home.file.".config" = {
    source = ./external-config;
    recursive = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
