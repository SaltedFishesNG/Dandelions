{ inputs, ... }:
{
  modules.extra.nixvim.load = [
    inputs.nixvim.nixosModules.nixvim
    {
      programs.nixvim = {
        enable = true;
      };
    }
  ];
}
