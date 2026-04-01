{ inputs, ... }:
let
  homeCommon =
    {
      inputs,
      lib,
      config,
      pkgs,
      unstable-pkgs,
      ...
    }:
    {
      imports = [ ../../home_modules/yazi.nix ];

      nixpkgs = {
        overlays = [ ];
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      programs.firefox = {
        enable = false;
        policies = {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
        };
      };

      home.packages =
        with pkgs;
        [
          unstable-pkgs.claude-code
          unstable-pkgs.pi-coding-agent
          ruff
          cargo
          rustc
          nixfmt
          nil
          shfmt
          shellcheck
          unstable-pkgs.python3
          uv
          typst
          mpv
          gitui
          ripgrep
          fd
          btop
          bat
          yt-dlp
          pandoc
          tectonic
          ouch
          eza
          fzf
          zoxide
          lazygit
          lazydocker
          gnutar
          gzip
          bzip2
          xz
          zip
          unzip
          p7zip
          unrar
          zstd
          file
        ]
        ++ (with unstable-pkgs; [
          obsidian
          neovim
        ]);

      home.sessionPath = [ "$HOME/.local/bin" ];

      programs.home-manager.enable = true;
      programs.git = {
        enable = true;
        lfs.enable = true;
        settings.user = {
          name = "Erdi ARI";
          email = "me@erdiari.dev";
        };
      };

      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          gcloud.disabled = true;
          line_break.disabled = true;
        };
      };

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

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
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
        };
        defaultKeymap = "viins";
        shellAliases = {
          v = "nvim";
          doom = "~/.emacs.d/bin/doom";
          ls = "eza --icons=always";
          lt = "ls -T";
          la = "ls -al";
        };

        initContent = ''
          eval "$(zoxide init zsh)"


          extract() {
              if [ -z "$1" ]; then
                  echo "Usage: extract <archive_file>"
                  return 1
              fi

              if [ ! -f "$1" ]; then
                  echo "Error: '$1' is not a valid file"
                  return 1
              fi

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

      home.file.".config" = {
        source = ../../home_modules/external-config;
        recursive = true;
      };
      home.file.".doom.d" = {
        source = ../../home_modules/doom.d;
        recursive = true;
      };

      home.stateVersion = "23.05";
    };
in
{
  flake.nixosModules.homeCommon = homeCommon;

  flake.homeConfigurations."erd" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit inputs;
      unstable-pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };
    modules = [
      inputs.stylix.homeModules.stylix
      homeCommon
      ../../home_modules/linux.nix
    ];
  };

  flake.homeConfigurations."mac-m1" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit inputs;
      unstable-pkgs = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    };
    modules = [
      inputs.stylix.homeModules.stylix
      homeCommon
      ../../home_modules/darwin.nix
    ];
  };

  flake.homeConfigurations."mac-intel" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-darwin";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit inputs;
      unstable-pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
    };
    modules = [
      inputs.stylix.homeModules.stylix
      homeCommon
      ../../home_modules/darwin.nix
    ];
  };
}
