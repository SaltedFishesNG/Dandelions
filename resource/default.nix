{ pkgs, username, ... }:
{
  systemd.user.tmpfiles.users.${username}.rules = [
    "L+ %h/.icons/default                       - ${username} users - ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice"

    "L+ %h/.config/fuzzel/fuzzel.ini            - ${username} users - ${./fuzzel.ini}"
    "L+ %h/.config/mako/config                  - ${username} users - ${./mako.ini}"
    "L+ %h/.config/niri/bg.png                  - ${username} users - ${./images/bg.png}"
    "L+ %h/.config/niri/config.kdl              - ${username} users - ${./niri.kdl}"
    "L+ %h/.config/niri/lock.png                - ${username} users - ${./images/lock.png}"
    "L+ %h/.config/waybar/config.jsonc          - ${username} users - ${./waybar/config.jsonc}"
    "C+ %h/.config/waybar/service.sh         0500 ${username} users - ${./waybar/service.sh}"
    "L+ %h/.config/waybar/style.css             - ${username} users - ${./waybar/style.css}"

    "D  %h/.mozilla/firefox/'Profile Groups' 0755 ${username} users - -"
    "L+ %h/.mozilla/firefox/default/user.js     - ${username} users - ${./firefox/user.js}"
    "L+ %h/.mozilla/firefox/profiles.ini        - ${username} users - ${./firefox/profiles.ini}"
    "L+ %h/.wezterm.lua                         - ${username} users - ${./wezterm.lua}"
  ];
}
