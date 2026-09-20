{ pkgs, ... }:
let
  qbittorrentConfig = pkgs.writeText "qBittorrent.conf" ''
    [LegalNotice]
    Accepted=true

    [Preferences]
    Downloads\\SavePath=/mnt/media/downloads/complete/
    Downloads\\TempPath=/mnt/media/downloads/incomplete/
    Downloads\\TempPathEnabled=true
    WebUI\\Address=*
  '';
  base_url = "http://home-boy.bandicoot-wyrm.ts.net";
in
{
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/815a3581-2ad8-4430-9a69-061442b137e7";
    fsType = "ext4";
  };

  users.groups.media = { };

  systemd.tmpfiles.settings.media = {
    "/mnt/media"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/mnt/media/downloads"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/mnt/media/downloads/complete"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/mnt/media/downloads/incomplete"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/mnt/media/movies"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/mnt/media/tv"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/mnt/media/music"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/mnt/media/comics"."d" = {
      mode = "2775";
      user = "root";
      group = "media";
    };
    "/var/lib/mylar"."d" = {
      mode = "0770";
      user = "erd";
      group = "media";
    };
  };

  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.server.bindaddress = "*";
  };

  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.server.bindaddress = "*";
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings.server.bindaddress = "*";
  };

  services.lidarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.server.bindaddress = "*";
  };

  services.flaresolverr.enable = true;

  virtualisation.oci-containers.containers.mylar = {
    image = "lscr.io/linuxserver/mylar3:latest";
    environment = {
      PUID = "1000";
      PGID = "993";
      TZ = "Europe/Istanbul";
      UMASK = "002";
    };
    volumes = [
      "/var/lib/mylar:/config"
      "/mnt/media/comics:/comics"
      "/mnt/media/downloads:/downloads"
    ];
    extraOptions = [ "--network=host" ];
  };

  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    group = "media";
    openFirewall = true;
    torrentingPort = 51413;
  };

  systemd.services.qbittorrent = {
    preStart = ''
      if [ ! -e /var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf ]; then
        ${pkgs.coreutils}/bin/install -Dm600 ${qbittorrentConfig} /var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf
      fi
    '';
    serviceConfig.UMask = "0002";
  };

  services.nzbget = {
    enable = true;
    group = "media";
    settings = {
      ControlIP = "0.0.0.0";
      ControlPort = 6789;
      DestDir = "/mnt/media/downloads/complete";
      InterDir = "/mnt/media/downloads/incomplete";
    };
  };

  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.seerr = {
    enable = true;
    openFirewall = true;
    stateRevision = 1;
  };

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "localhost:8082,127.0.0.1:8082,home-boy:8082,home-boy.bandicoot-wyrm.ts.net:8082,100.112.172.31:8082,192.168.1.126:8082";
    services = [
      {
        Media = [
          {
            Jellyfin = {
              href = "${base_url}:8096";
              description = "Media streaming";
            };
          }
          {
            Seerr = {
              href = "${base_url}:5055";
              description = "Media requests";
            };
          }
          {
            Immich = {
              href = "${base_url}:2283";
              description = "Image Library";
            };
          }
        ];
      }
      {
        Automation = [
          {
            Sonarr = {
              href = "${base_url}:8989";
              description = "TV series";
            };
          }
          {
            Radarr = {
              href = "${base_url}:7878";
              description = "Movies";
            };
          }
          {
            Lidarr = {
              href = "${base_url}:8686";
              description = "Music automation";
            };
          }
          {
            Mylar = {
              href = "${base_url}:8090";
              description = "Comic automation";
            };
          }
          {
            Bazarr = {
              href = "${base_url}:6767";
              description = "Subtitles";
            };
          }
          {
            Prowlarr = {
              href = "${base_url}:9696";
              description = "Indexer management";
            };
          }
          {
            qBittorrent = {
              href = "${base_url}:8080";
              description = "Download client";
            };
          }
          {
            NZBGet = {
              href = "${base_url}:6789";
              description = "Usenet download client";
            };
          }
        ];
      }
    ];
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/mnt/media";
        };
      }
    ];
    settings = {
      title = "Media";
      headerStyle = "boxedWidgets";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      6789
      8090
    ];
    allowedUDPPorts = [ 51413 ];
  };
}
