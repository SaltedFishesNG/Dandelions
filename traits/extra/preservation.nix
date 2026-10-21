{
  traits."extra/preservation" =
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

          ".config/mozilla/firefox/default"
          ({ directory = ".gnupg"; } // { mode = "0700"; })
          ".local/share/PrismLauncher"
          ({ directory = ".ssh"; } // { mode = "0700"; })
        ]
        ++ lib.optionals (config.i18n.inputMethod.type == "fcitx5") [ ".local/share/fcitx5/rime" ]
        ++ lib.optionals config.programs.steam.enable [ ".local/share/Steam" ]
        ++ lib.optionals config.services.flatpak.enable ([ ".var/app" ] ++ [ ".local/share/flatpak" ])
        ++ lib.optionals config.services.gnome.gnome-keyring.enable [ ".local/share/keyrings" ]
        ++ lib.optionals node.schema.software.extra [
          ".config/Signal"
          ".config/qBittorrent"
          ".config/thunderbird/default"
          ".config/zed"
          # ".local/share/bottles"
          ".local/share/fractal"
          ".local/share/qBittorrent"
          ".local/share/zed"
        ];
      };
    };
}
