{
  traits.unfree =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfreePackages = [
        # "ida-pro"
        "steam"
        "steam-unwrapped"
      ];

      environment.systemPackages = [
        # (pkgs.callPackage ./_pkgs/ida-pro.nix { })
      ];

      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
        extest.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
    };
}
