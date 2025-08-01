{ pkgs, ... }: {
  stylix = {
    enable = true;
    image = ../../wp.png;
    polarity = "dark"; # "light" or "dark"

    # Base colors
    # https://tinted-theming.github.io/base16-gallery/
    base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "SauceCodePro Nerd Font";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
    };

    targets = {
      firefox = {
        profileNames = [ "default" ];
      };
    };
  };
}
