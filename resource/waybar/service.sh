#!/usr/bin/env sh
set -eu

case "$1" in
  theme)
    current_scheme="$(dconf read /org/gnome/desktop/interface/color-scheme || echo "'prefer-light'")"
    if [ "$current_scheme" = "'prefer-dark'" ]; then
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
        dconf write /org/gnome/desktop/interface/icon-theme "'Papirus'"
    else
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
        dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
    fi
    ;;
  bluetooth)
    if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
    ;;
  *)
    exit 1
    ;;
esac
