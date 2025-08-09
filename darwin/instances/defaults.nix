{ inputs, lib, config, pkgs, unstable-pkgs, ... }: {

  # Basic system configuration
  system.stateVersion = 5;

  # Nix configuration
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

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # System preferences
  system.defaults = {
    dock = {
      # Basic dock behavior
      autohide = true;                    # Hide dock when not in use
      orientation = "bottom";             # Position dock at bottom of screen
      showhidden = true;                  # Show hidden applications with transparent icons
      mineffect = "scale";               # Use scale effect for minimizing windows
      launchanim = false;                # Disable launch animations for faster app opening
      static-only = true;                # Prevent dock from moving between monitors
      tilesize = 48;                     # Set dock icon size to 48 pixels
      
      # Performance improvements
      autohide-delay = 0.0;              # Remove delay before dock appears (instant response)
      autohide-time-modifier = 0.2;      # Speed up dock hide/show animation (default is 0.5)
      expose-animation-duration = 0.1;    # Faster Mission Control transitions (default is 0.2)
      
      # Space and organization behavior  
      mru-spaces = false;                # Keep spaces in fixed order instead of most recently used
      show-recents = false;              # Hide "Recent Applications" section for cleaner dock
      
      # Visual enhancements
      magnification = true;              # Enable icon magnification on hover
      largesize = 64;                   # Maximum icon size when magnified (makes targeting easier)
      
      # Window and app management
      minimize-to-application = true;     # Minimize windows into app icon instead of separate dock tile
      show-process-indicators = true;     # Show dots under running applications
      
      # Clean slate configuration (can be customized per machine)
      persistent-apps = [
        "/System/Applications/Launchpad.app"
      ];              # Start with Launchpad in dock
      persistent-others = [];            # Start with empty dock folders/documents
      
      # Hot corners for productivity (move mouse to screen corner to trigger action)
      # Values: 0=None, 2=Mission Control, 3=Show application windows, 4=Desktop, 5=Start screen saver, 6=Disable screen saver, 7=Dashboard, 10=Put display to sleep, 11=Launchpad, 12=Notification Center, 13=Lock screen
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

    # Screenshot configuration
    screencapture.location = "~/Screenshots";  # Set screenshot save location
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}
