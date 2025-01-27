{ pkgs, config, lib, ... }: {
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://github.com/erdiari/nix-config/blob/main/wp.png?raw=true";
      sha256 =
        "sha256-TGB+YWYfsGrFEF1laCB55zyOrct3eFGKGgFfhLYF8V0=";
    };
    polarity = "dark"; # "light" or "dark"

    # Base colors
    # https://tinted-theming.github.io/base16-gallery/
    base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";

    fonts = {
      monospace = {
        package = pkgs.nerdfonts;
        name = "Source Code Pro";
        # name = "Agave Nerd Font";
      };
    };
  };
}
