{ inputs, ... }:
{
  traits.nixvim = {
    imports = [ inputs.nixvim.nixosModules.nixvim ];

    programs.nixvim = {
      enable = true;
    };
  };
}
