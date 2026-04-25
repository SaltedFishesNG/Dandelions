{
  traits."software/fcitx5" =
    { pkgs, ... }:
    let
      rime-config = pkgs.runCommand "rime-config" { } ''
        mkdir -p $out/share/rime-data
        cp ${builtins.toFile "default.yaml" ''
          __include: rime_ice_suggestion:/
          ascii_composer:
            good_old_caps_lock: true
            switch_key:
              Caps_Lock: noop
              Shift_L: noop
              Shift_R: noop
              Control_L: noop
              Control_R: noop
          menu:
            page_size: 7
        ''} $out/share/rime-data/default.yaml
      '';
    in
    {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = [
            pkgs.fcitx5-mellow-themes
            (pkgs.fcitx5-rime.override { rimeDataPkgs = [ pkgs.rime-ice ] ++ [ rime-config ]; })
            # pkgs.fcitx5-pinyin-zhwiki
            # pkgs.kdePackages.fcitx5-chinese-addons
          ];
          settings.addons = {
            classicui.globalSection = {
              Theme = "mellow-graphite";
              DarkTheme = "mellow-graphite-dark";
              UseDarkTheme = "True";
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
          settings.globalOptions = {
            "Hotkey/TriggerKeys"."0" = "Control+space";
            "Hotkey/ActivateKeys"."0" = "VoidSymbol";
            "Hotkey/AltTriggerKeys"."0" = "VoidSymbol";
            "Hotkey/DeactivateKeys"."0" = "VoidSymbol";
            "Hotkey/EnumerateGroupBackwardKeys"."0" = "VoidSymbol";
            "Hotkey/EnumerateGroupForwardKeys"."0" = "VoidSymbol";
          };
          ignoreUserConfig = false; # Rime will use .local/share/fcitx5/rime/build
        };
      };
    };
}
