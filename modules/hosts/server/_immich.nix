{ ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/mnt/media/immich";
  };

  systemd.tmpfiles.settings.immich."/mnt/media/immich"."d" = {
    mode = "0750";
    user = "immich";
    group = "immich";
  };
}
