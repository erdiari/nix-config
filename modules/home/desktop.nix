{ ... }:
let
  desktop =
    { unstable-pkgs, ... }:
    {
      programs.firefox = {
        enable = false;
        policies = {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
        };
      };

      programs.kitty = {
        enable = true;
        shellIntegration.enableZshIntegration = true;
        settings = {
          confirm_os_window_close = 0;
          dynamic_background_opacity = true;
          enable_audio_bell = false;
          mouse_hide_wait = "-1.0";
          window_padding_width = 10;
          font_family = "SauceCodePro Nerd Font";
          font_size = 12;
        };

        extraConfig = ''
          map ctrl+shift+w>h neighboring_window left
          map ctrl+shift+w>l neighboring_window right
          map ctrl+shift+w>j neighboring_window down
          map ctrl+shift+w>k neighboring_window up

          map ctrl+shift+w>shift+h move_window left
          map ctrl+shift+w>shift+l move_window right
          map ctrl+shift+w>shift+j move_window down
          map ctrl+shift+w>shift+k move_window up

          map ctrl+shift+w>s launch --location=hsplit
          map ctrl+shift+w>v launch --location=vsplit

          scrollback_pager nvim --noplugin -c 'set buftype=nofile' -c 'set noswapfile' -c 'silent! %s/\%x1b\[[0-9;]*[sumJK]//g' -c 'silent! %s/\%x1b]133;[A-Z]\%x1b\\//g' -c 'silent! %s/\%x1b\[[^m]*m//g' -c 'silent! %s///g' -
        '';
      };

      home.packages = [ unstable-pkgs.obsidian ];

      services.syncthing.enable = true;

      home.file.".doom.d" = {
        source = ../../home_modules/doom.d;
        recursive = true;
      };
    };
in
{
  flake.modules.homeManager.desktop = desktop;
  flake.homeModules.desktop = desktop;
}
