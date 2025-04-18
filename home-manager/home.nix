{ inputs, lib, config, pkgs, unstable-pkgs, ... }: {

  imports = [ ../nixos/modules/stylix.nix ./yazi.nix];

  nixpkgs = {
    overlays = [ ];
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
    geany
    unstable-pkgs.neovim
    # unstable-pkgs.windsurf
    dolphin
    # LSPs and formatter and stuff
    ruff
    # unstable-pkgs.basedpyright => Bugged
    pylyzer
    cargo
    rustc
    nixfmt
    nil
    shfmt
    shellcheck
    devenv
    # Python
    unstable-pkgs.python3
    # unstable-pkgs.python3Packages.torch-bin
    uv
    # For screenshots
    grim
    slurp
    # Clipboard manager for nvim
    # xclip #X-server
    wl-clipboard # Wayland
    # Apps
    flatpak
    obsidian
    libreoffice-qt6-fresh
    spotify
    typst # => For Documents
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
    ouch
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
    # Archive utilities
    gnutar
    gzip
    bzip2
    xz
    zip
    unzip
    p7zip
    unrar
    zstd
    file  # for file type detection
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
    settings = { use_nerdfond = true; cover.enable=true; };
    package = unstable-pkgs.ncspot.override {
      withCover = true;
    };
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

  programs.nushell = {
    enable = true;
    package = unstable-pkgs.nushell;
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
      install-homemanager =
        "home-manager switch --flake ~/Documents/nix-config/home-manager/home.nix#default";
      doom = "~/.emacs.d/bin/doom";
      ls = "eza --icons=always";
      lt = "ls -T";
      la = "ls -al";
    };

    initExtra = ''
      eval "$(zoxide init zsh)"

      function yy() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                  builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
      }

      extract() {
          if [ -z "$1" ]; then
              echo "Usage: extract <archive_file>"
              return 1
          fi

          if [ ! -f "$1" ]; then
              echo "Error: '$1' is not a valid file"
              return 1
          fi

          # Get the file extension
          filename=$(basename "$1")
          extension="''${filename##*.}"
          extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

          case "$extension" in
              "tar")
                  tar xf "$1"
                  ;;
              "gz" | "tgz")
                  if [[ "$filename" = *.tar.gz || "$filename" = *.tgz ]]; then
                      tar xzf "$1"
                  else
                      gunzip "$1"
                  fi
                  ;;
              "bz2" | "tbz2")
                  if [[ "$filename" = *.tar.bz2 || "$filename" = *.tbz2 ]]; then
                      tar xjf "$1"
                  else
                      bunzip2 "$1"
                  fi
                  ;;
              "xz" | "txz")
                  if [[ "$filename" = *.tar.xz || "$filename" = *.txz ]]; then
                      tar xJf "$1"
                  else
                      xz -d "$1"
                  fi
                  ;;
              "zip")
                  unzip "$1"
                  ;;
              "7z")
                  7z x "$1"
                  ;;
              "rar")
                  unrar x "$1"
                  ;;
              "z")
                  uncompress "$1"
                  ;;
              "lzma")
                  unlzma "$1"
                  ;;
              "zst")
                  zstd -d "$1"
                  ;;
              *)
                  # Try to detect the format using file command
                  file_type=$(file -b "$1")
                  case "$file_type" in
                      *"XZ compressed data"*)
                          xz -d "$1"
                          ;;
                      *"gzip compressed data"*)
                          gunzip "$1"
                          ;;
                      *"bzip2 compressed data"*)
                          bunzip2 "$1"
                          ;;
                      *"Zip archive data"*)
                          unzip "$1"
                          ;;
                      *"7-zip archive data"*)
                          7z x "$1"
                          ;;
                      *"RAR archive data"*)
                          unrar x "$1"
                          ;;
                      *"Zstandard compressed data"*)
                          zstd -d "$1"
                          ;;
                      *)
                          echo "Error: Unknown archive format for '$1'"
                          return 1
                          ;;
                  esac
                  ;;
          esac

          # Check if extraction was successful
          if [ $? -eq 0 ]; then
              echo "Successfully extracted '$1'"
              return 0
          else
              echo "Error: Extraction failed for '$1'"
              return 1
          fi
      }
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

  # lorri for faster direnv
  services.lorri.enable = true;

  # # Configurations -> Will use symbolic links to configure
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
