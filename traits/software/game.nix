{
  traits."software/game" =
    { node, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        prismlauncher
        protonplus
      ];

      programs = {
        gamescope.enable = true;
        gamemode.enable = true;
      };

      services.archisteamfarm = {
        enable = false;
        web-ui.enable = true;
      };

      users.users.${node.schema.base.username}.extraGroups = [ "gamemode" ];
    };
}
