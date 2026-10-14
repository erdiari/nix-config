{ inputs, lib, ... }:
{
  imports = [ inputs.copyparty.nixosModules.default ];

  # The module's default package is pkgs.copyparty, which only exists once
  # the upstream overlay is applied.
  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  # Password lives outside the nix store, mirroring the swaparr .env pattern:
  # the directory is created here, the file itself is placed by hand
  # (`umask 077; printf '%s' 'the-password' > /var/lib/copyparty-auth/erd.password`;
  # root:copyparty 0640). Must be readable by the copyparty service user.
  systemd.tmpfiles.settings.copyparty-auth."/var/lib/copyparty-auth"."d" = {
    mode = "0750";
    user = "root";
    group = "copyparty";
  };

  services.copyparty = {
    enable = true;
    openFilesLimit = 8192;

    settings = {
      i = "0.0.0.0";
      p = 3923;
      no-reload = true;
      # Kept from the module default; required for CacheDirectory to exist.
      hist = "/var/cache/copyparty";
    };

    accounts.erd.passwordFile = "/var/lib/copyparty-auth/erd.password";

    volumes."/" = {
      path = "/mnt/media";
      access.rwmd = "erd";
      flags = {
        # Uploads database (dedup/resume) and periodic rescan for files
        # dropped in by the *arr stack rather than uploaded through the UI.
        e2d = true;
        scan = 60;
        fk = 4;
      };
    };
  };

  # Uploads land as the copyparty OS user; put it in the shared media group so
  # setgid dirs under /mnt/media keep new files writable by the media stack.
  users.users.copyparty.extraGroups = [ "media" ];

  # The module hardcodes UMask=0077 (files 0600, group cannot read); the media
  # stack relies on group access, so restore the setgid-friendly umask.
  systemd.services.copyparty.serviceConfig.UMask = lib.mkForce "0002";

  networking.firewall.allowedTCPPorts = [ 3923 ];
}
