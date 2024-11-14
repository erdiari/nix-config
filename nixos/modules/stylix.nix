{
  pkgs,
  config,
  lib,
  ...
}: {
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://github.com/erdiari/nix-config/blob/main/wp.jpg?raw=true";
      sha256 = "330a5725faec86c5ec3ad147d45015cfc72bf1e2141c4d9862d1f490f48305ce";
  };
  polarity = "dark"; # "light" or "dark"

  # # Base colors
  # base16Scheme = {
  #   base00 = "1e1e2e"; # Base background
  #   base01 = "181825"; # Lighter background (status bars)
  #   base02 = "313244"; # Selection background
  #   base03 = "45475a"; # Comments, invisibles
  #   base04 = "585b70"; # Dark foreground (status bars)
  #   base05 = "cdd6f4"; # Default foreground
  #   base06 = "f5e0dc"; # Light foreground
  #   base07 = "b4befe"; # Light background
  #   base08 = "f38ba8"; # Variables, XML tags, markup link text, markup lists
  #   base09 = "fab387"; # Integers, Boolean, constants, markup link url
  #   base0A = "f9e2af"; # Classes, markup bold, search text background
  #   base0B = "a6e3a1"; # Strings, inherited class, markup code
  #   base0C = "94e2d5"; # Support, regular expressions, escape characters, markup quotes
  #   base0D = "89b4fa"; # Functions, methods, attribute IDs, headings
  #   base0E = "cba6f7"; # Keywords, storage, selector, markup italic
  #   base0F = "f2cdcd"; # Deprecated, opening/closing embedded language tags
  # };
  #
  fonts = {
    monospace = {
      package = pkgs.nerdfonts;
      name = "Agave Nerd Font";
    };
  #
  #   serif = {
  #     package = pkgs.nerdfonts;
  #     name = "FiraCode Nerd Font";
  #   };
  #
  #   sansSerif = {
  #     package = pkgs.nerdfonts;
  #     name = "FiraCode Nerd Font";
  #   };
  #
  #   emoji = {
  #     package = pkgs.noto-fonts-emoji;
  #     name = "Noto Color Emoji";
  #   };
  };
  #
  #
  # # Targets to style -> All targets are on unless disabled explicitly
  # targets = {
  #   rofi.enable = false;
  #   # neovim.enable = lib.mkForce false;
  #   nixvim.enable = false;
  #   # firefox.enable = true;
  # };


  };
}
