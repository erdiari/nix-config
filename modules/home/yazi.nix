{ inputs, lib, config, pkgs, unstable-pkgs, ... }: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
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

  home.packages = with pkgs; [ duckdb jq ];
}
