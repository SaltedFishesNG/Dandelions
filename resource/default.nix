{ pkgs, userName, ... }:
{
  systemd.user.tmpfiles.users.${userName}.rules = [
    "L+ %h/.icons/default                       - ${userName} users - ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice"

    "L+ %h/.config/fuzzel/fuzzel.ini            - ${userName} users - ${./fuzzel.ini}"
    "L+ %h/.config/mako/config                  - ${userName} users - ${./mako.ini}"
    "L+ %h/.config/niri/bg.png                  - ${userName} users - ${./images/bg.png}"
    "L+ %h/.config/niri/config.kdl              - ${userName} users - ${./niri.kdl}"
    "L+ %h/.config/niri/lock.png                - ${userName} users - ${./images/lock.png}"
    "L+ %h/.config/waybar/config.jsonc          - ${userName} users - ${./waybar/config.jsonc}"
    "C+ %h/.config/waybar/service.sh         0500 ${userName} users - ${./waybar/service.sh}"
    "L+ %h/.config/waybar/style.css             - ${userName} users - ${./waybar/style.css}"

    "D  %h/.mozilla/firefox/'Profile Groups' 0755 ${userName} users - -"
    "L+ %h/.mozilla/firefox/default/user.js     - ${userName} users - ${./firefox/user.js}"
    "L+ %h/.mozilla/firefox/profiles.ini        - ${userName} users - ${./firefox/profiles.ini}"
    "L+ %h/.wezterm.lua                         - ${userName} users - ${./wezterm.lua}"
  ];
}
