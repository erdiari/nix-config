{ inputs, lib, config, pkgs, unstable-pkgs, ... }: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    package = unstable-pkgs.yazi;
    plugins = {
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "c070754";
        sha256 = "sha256-H8j+9jcdcpPFXVO/XQZL3zq1l5f/WiOm4YUxAMduSRs=";
      };

      # TODO: Find a way to download nbpreview package and uncomment
      # nbpreview = pkgs.fetchFromGitHub {
      #         owner = "AnirudhG07";
      #         repo = "nbpreview";
      #         rev = "f8879b3";
      #         # sha256 = "sha256-...";
      # };
    };

    settings = { }; # will use external-config

  };

  home.packages = with pkgs;
    [ duckdb jq ]; # ++ (with unstable-pkgs; [ yaziPlugins.duckdb ]);
}
