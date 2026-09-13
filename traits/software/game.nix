{
  schema.software.game = {
    ASF.enable = false; # bool
  };

  traits."software/game" =
    { node, pkgs, ... }:
    {
      nixpkgs.config.allowUnfreePackages = [
        "steam"
        "steam-unwrapped"
      ];

      environment.systemPackages = with pkgs; [
        prismlauncher
        protonplus
      ];

      programs = {
        gamescope.enable = true;
        gamemode.enable = true;
        steam = {
          enable = true;
          gamescopeSession.enable = true;
          extest.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
      };

      services.archisteamfarm = {
        enable = node.schema.software.game.ASF.enable;
        web-ui.enable = true;
      };

      users.users.${node.schema.base.username}.extraGroups = [ "gamemode" ];
    };
}
