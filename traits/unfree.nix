{
  traits.unfree =
    { lib, pkgs, ... }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "crossover"
          "fcitx5-pinyin-moegirl"
          "ida-pro"
          "nvidia-settings"
          "nvidia-x11"
          "steam"
          "steam-unwrapped"
        ];

      # nixpkgs.config.cudaSupport = true;

      environment.systemPackages = [
        (pkgs.callPackage ./_pkgs/crossover.nix { })
        # (pkgs.callPackage ./_pkgs/ida-pro.nix { })
      ];

      i18n.inputMethod.fcitx5.addons = [ pkgs.fcitx5-pinyin-moegirl ];

      programs.steam = {
        enable = true;
        package = pkgs.steam.override { extraArgs = "-system-composer"; };
        gamescopeSession.enable = true;
        extest.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
    };
}
