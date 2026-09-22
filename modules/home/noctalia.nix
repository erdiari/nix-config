{ inputs, ... }:
let
  noctalia =
    { ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;

        settings = {
          shell = {
            avatar_path = "~/.face";
            corner_radius_scale = 1.0;
          };

          theme = {
            mode = "dark";
            source = "wallpaper";
          };

          location = {
            address = "Istanbul, Turkey";
          };

          bar.main = {
            position = "top";
            capsule = true;
            start = [
              "launcher"
              "clock"
              "activewindow"
            ];
            center = [ "workspaces" ];
            end = [
              "tray"
              "notifications"
              "battery"
              "volume"
              "brightness"
              "control-center"
            ];
          };
        };
      };
    };
in
{
  flake.modules.homeManager.noctalia = noctalia;
  flake.homeModules.noctalia = noctalia;
}
