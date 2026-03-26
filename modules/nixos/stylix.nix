{ inputs, ... }: {
  flake.nixosModules.stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      image = ../../wp.png;
      polarity = "dark";
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

      targets = { };
    };
  };
}
