# This file should not be tracked by Git, but Nix does not process files that are not tracked by Git.
{
  traits.secrets =
    { node, pkgs, ... }:
    {
      system.stateVersion = "26.11";
      users.users.${node.schema.base.username}.password = "";
      # users.users.${node.schema.base.username}.hashedPassword = "";
      preservation.preserveAt."/persist".users.${node.schema.base.username}.directories = [ ];
      environment.systemPackages = with pkgs; [ ];
    };
}
