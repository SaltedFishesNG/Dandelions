{
  config,
  lib,
  userName,
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

  preservation.preserveAt."/persist".users.${userName} = {
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
      ".mozilla/firefox/default"
    ]
    ++ lib.optionals config.services.flatpak.enable [ ".var/app" ];
  };
}
