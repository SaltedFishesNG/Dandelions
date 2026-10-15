{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    adw-gtk3
    bibata-cursors
    brightnessctl
    file-roller
    firefox
    fuzzel
    mako
    nautilus
    papirus-icon-theme
    pavucontrol
    swaybg
    swaylock
    waybar
    waypipe
    wezterm
    xwayland-satellite
  ];

  programs = {
    dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          cursor-size = lib.gvariant.mkInt32 20;
          cursor-theme = "Bibata-Modern-Ice";
          gtk-theme = "adw-gtk3";
          icon-theme = "Papirus";
        };
      }
    ];
    niri.enable = true;
    nm-applet.enable = config.networking.networkmanager.enable;
    seahorse.enable = config.services.gnome.gnome-keyring.enable;
  };

  security.soteria.enable = true;

  services = {
    blueman.enable = config.hardware.bluetooth.enable;
    greetd = {
      enable = true;
      settings.default_session.command = "${lib.getExe pkgs.tuigreet}";
      useTextGreeter = true;
    };
    gvfs.enable = true;
    playerctld.enable = config.services.pipewire.enable;
  };

  systemd.user.services.swayidle = {
    description = "Idle manager for Wayland";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${lib.getExe pkgs.swayidle} -w  \
          timeout 365 '${lib.getExe pkgs.niri} msg action power-off-monitors' \
          timeout 600 '${pkgs.systemd}/bin/systemctl suspend-then-hibernate' \
          before-sleep '${lib.getExe pkgs.playerctl} pause -a' \
          before-sleep '${lib.getExe pkgs.swaylock} -Fi ~/Pictures/lock.png '
      '';
      Restart = "on-failure";
    };
  };

  environment.sessionVariables = {
    DEFAULT_BROWSER = "${lib.getExe pkgs.firefox}";
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/xhtml_xml" = "firefox.desktop";
    "application/xml" = "firefox.desktop";
    "image/*" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "text/xml" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
}
