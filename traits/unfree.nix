{
  traits.unfree =
    { lib, pkgs, ... }:
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "crossover"
          "ida-pro"
          "nvidia-settings"
          "nvidia-x11"
          "steam"
          "steam-unwrapped"
        ];

      # nixpkgs.config.cudaSupport = true;

      environment.systemPackages = with pkgs; [
        crossover
        # ida-pro
      ];

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
