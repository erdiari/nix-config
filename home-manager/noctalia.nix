{ pkgs, inputs, ... }:
{
  # Import the home manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Configure Noctalia
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "default";
        position = "top";
        showCapsule = true;
        widgets = {
          left = [
            {
              id = "Launcher";
            }
            {
              id = "Clock";
            }
            {
              id = "ActiveWindow";
            }
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "none";
            }
          ];
          right = [
            {
              id = "Tray";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "Battery";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
            {
              id = "Volume";
            }
            {
              id = "Brightness";
            }
            {
              id = "ControlCenter";
            }
          ];
        };
      };
      general = {
        avatarImage = "";
        radiusRatio = 1;
      };
      location = {
        name = "Istanbul, Turkey";
        monthBeforeDay = false;
      };
      colorSchemes = {
        predefinedScheme = "Noctalia (default)";
      };
    };
  };
}
