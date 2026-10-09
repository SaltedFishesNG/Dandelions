{
  traits."software/fcitx5" =
    { pkgs, ... }:
    {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = [
            pkgs.fcitx5-mellow-themes
            pkgs.fcitx5-rime
            # pkgs.kdePackages.fcitx5-chinese-addons
          ];
          settings.addons = {
            classicui.globalSection = {
              Theme = "mellow-graphite";
              DarkTheme = "mellow-graphite-dark";
              UseDarkTheme = "True";
              UseAccentColor = "False";
            };
          };
          settings.inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "rime";
            # "Groups/0/Items/1".Name = "pinyin";
          };
          settings.globalOptions."Hotkey/AltTriggerKeys"."0" = "VoidSymbol";
          ignoreUserConfig = false; # Rime will use .local/share/fcitx5/rime/build
        };
      };
    };
}
