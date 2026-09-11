{ pkgs, ... }:
let
  background.png = builtins.fetchurl {
    # https://www.pixiv.net/artworks/127830851
    url = "https://i.pixiv.re/img-original/img/2025/03/03/20/23/49/127830851_p0.png";
    sha256 = "sha256-QJZVozq43uurp+4oupbZo8h3sPwazusiG67vShpqHWc=";
  };
  lock.png = builtins.fetchurl {
    # https://www.pixiv.net/artworks/137010221
    url = "https://i.pixiv.re/img-original/img/2025/11/02/18/09/43/137010221_p0.png";
    sha256 = "sha256-lvePbQWEw9ASayyxkMFauTc6H3Ug59T7RB9QpSzva8I=";
  };
in
{
  systemd.user.tmpfiles.rules = [
    "L+ %h/.icons/default - - - - ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice"

    "L+ %h/.config/fuzzel/fuzzel.ini    - - - - ${./fuzzel.ini}"
    "L+ %h/.config/mako/config          - - - - ${./mako.ini}"
    "L+ %h/.config/mpv/mpv.conf         - - - - ${builtins.toFile "mpv.conf" "ytdl-raw-options=cookies-from-browser=firefox"}"
    "L+ %h/.config/niri/config.kdl      - - - - ${./niri.kdl}"
    "L+ %h/.config/openbox/autostart    - - - - ${./openbox/autostart}"
    "L+ %h/.config/waybar/config.jsonc  - - - - ${./waybar/config.jsonc}"
    "C+ %h/.config/waybar/service.sh 0500 - - - ${./waybar/service.sh}"
    "L+ %h/.config/waybar/style.css     - - - - ${./waybar/style.css}"
    # "L+ %h/.mozilla/firefox/default/chrome/userChrome.css  - - - - ${./firefox/userChrome.css}"
    # "L+ %h/.mozilla/firefox/default/chrome/userContent.css - - - - ${./firefox/userContent.css}"
    "L+ %h/.mozilla/firefox/default/user.js - - - - ${./firefox/user.js}"
    "L+ %h/.mozilla/firefox/profiles.ini    - - - - ${./firefox/profiles.ini}"
    "L+ %h/.thunderbird/default/user.js - - - - ${./firefox/user.js}"
    "L+ %h/.thunderbird/profiles.ini    - - - - ${./firefox/profiles.ini}"
    "L+ %h/.wezterm.lua                 - - - - ${./wezterm.lua}"
    "L+ %h/Pictures/background.png      - - - - ${background.png}"
    "L+ %h/Pictures/lock.png            - - - - ${lock.png}"
  ];
}
