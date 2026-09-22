{ ... }:
let
  media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mpv
        yt-dlp
      ];
    };
in
{
  flake.modules.homeManager.media = media;
  flake.homeModules.media = media;
}
