{
  config,
  lib,
  username,
  ...
}:
{
  preservation.enable = true;
  preservation.preserveAt."/persist".directories =
    [ ]
    ++ lib.optionals config.hardware.bluetooth.enable [ "/var/lib/bluetooth" ]
    ++ lib.optionals config.networking.wireless.iwd.enable [ "/var/lib/iwd" ]
    ++ lib.optionals config.services.flatpak.enable [ "/var/lib/flatpak" ]
    ++ lib.optionals config.services.v2raya.enable [ "/etc/v2raya" ];

  preservation.preserveAt."/persist".users.${username} = {
    files = [ ".local/share/fish/fish_history" ];
    directories = [
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Projects"

      ".config/mozilla/firefox/default"
      ({ directory = ".gnupg"; } // { mode = "0700"; })
      ({ directory = ".ssh"; } // { mode = "0700"; })
    ]
    ++ lib.optionals config.services.flatpak.enable ([ ".var/app" ] ++ [ ".local/share/flatpak" ])
    ++ lib.optionals config.services.gnome.gnome-keyring.enable [ ".local/share/keyrings" ];
  };
}
