{ ... }: {
  flake.nixosModules.darwinDefaults = { inputs, lib, config, pkgs, unstable-pkgs, ... }: {
    system.stateVersion = 5;

    nix = {
      enable = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
      };
      optimise = {
        automatic = true;
      };
      gc = {
        automatic = true;
        interval = { Weekday = 0; Hour = 2; Minute = 0; };
        options = "--delete-older-than 30d";
      };
    };

    environment.systemPackages = with pkgs; [
      vim
      git
      curl
      wget
    ];

    system.defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        showhidden = true;
        mineffect = "scale";
        launchanim = false;
        static-only = true;
        tilesize = 48;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        expose-animation-duration = 0.1;
        mru-spaces = false;
        show-recents = false;
        magnification = true;
        largesize = 64;
        minimize-to-application = true;
        show-process-indicators = true;
        wvous-tl-corner = 2;
        wvous-tr-corner = 7;
        wvous-bl-corner = 4;
        wvous-br-corner = 5;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Always";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      screencapture.location = "~/Screenshots";
    };

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };
}
