{ pkgs, ... }:
{
  systemd.user.tmpfiles.rules = [
    "L+ %h/.icons/default - - - - ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice"

    "L+ %h/.config/fuzzel/fuzzel.ini    - - - - ${./fuzzel.ini}"
    "L+ %h/.config/mako/config          - - - - ${./mako.ini}"
    "L+ %h/.config/niri/bg.png          - - - - ${./images/bg.png}"
    "L+ %h/.config/niri/config.kdl      - - - - ${./niri.kdl}"
    "L+ %h/.config/niri/lock.png        - - - - ${./images/lock.png}"
    "L+ %h/.config/waybar/config.jsonc  - - - - ${./waybar/config.jsonc}"
    "C+ %h/.config/waybar/service.sh 0500 - - - ${./waybar/service.sh}"
    "L+ %h/.config/waybar/style.css     - - - - ${./waybar/style.css}"

    "D  %h/.mozilla/firefox/'Profile Groups' 0755 - - - -"
    "L+ %h/.mozilla/firefox/default/user.js     - - - - ${./firefox/user.js}"
    "L+ %h/.mozilla/firefox/profiles.ini        - - - - ${./firefox/profiles.ini}"
    "L+ %h/.wezterm.lua                         - - - - ${./wezterm.lua}"
  ];
}
