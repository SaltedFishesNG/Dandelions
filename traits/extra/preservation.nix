{
  traits.preservation =
    {
      config,
      inputs,
      lib,
      node,
      ...
    }:
    {
      imports = [ inputs.preservation.nixosModules.preservation ];

      preservation.enable = true;
      preservation.preserveAt."/persist".directories = [
        "/var/lib/sbctl"
      ]
      ++ lib.optionals config.hardware.bluetooth.enable [ "/var/lib/bluetooth" ]
      ++ lib.optionals config.networking.wireless.iwd.enable [ "/var/lib/iwd" ]
      ++ lib.optionals config.services.archisteamfarm.enable [ "/var/lib/archisteamfarm/config" ]
      ++ lib.optionals config.services.flatpak.enable [ "/var/lib/flatpak" ]
      ++ lib.optionals config.services.v2raya.enable [ "/etc/v2raya" ]
      ++ lib.optionals config.virtualisation.libvirtd.enable [ "/var/lib/libvirt" ];

      preservation.preserveAt."/persist".users.${node.schema.base.username} = {
        files = [ ".local/share/fish/fish_history" ];
        directories = [
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Projects"

          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".ssh";
            mode = "0700";
          }
          ".local/share/PrismLauncher"
          ".mozilla/firefox/default"
        ]
        ++ lib.optionals config.programs.steam.enable [ ".local/share/Steam" ]
        ++ lib.optionals config.services.flatpak.enable [
          ".var/app"
          ".local/share/flatpak"
        ]
        ++ lib.optionals config.services.gnome.gnome-keyring.enable [ ".local/share/keyrings" ]
        ++ lib.optionals node.schema.software.extra [
          ".config/Signal"
          ".config/qBittorrent"
          ".local/share/bottles"
          ".local/share/fractal"
          ".local/share/qBittorrent"
          ".thunderbird/default"
        ];
      };
    };
}
