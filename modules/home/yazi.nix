{ ... }:
let
  yazi =
    { pkgs, unstable-pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
        package = unstable-pkgs.yazi;
        plugins = with unstable-pkgs.yaziPlugins; {
          starship = starship;
          duckdb = duckdb;
          git = git;
          projects = projects;
          wl-clipboard = wl-clipboard;
          rich-preview = rich-preview;
          gitui = gitui;
        };

        settings = { };
      };

      home.file.".config/yazi" = {
        source = ../../home_modules/external-config/yazi;
        recursive = true;
      };

      home.packages = with pkgs; [
        duckdb
        jq
      ];
    };
in
{
  flake.modules.homeManager.yazi = yazi;
  flake.homeModules.yazi = yazi;
}
