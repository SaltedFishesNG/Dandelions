{ inputs, ... }:
{
  traits = [
    {
      name = "nixvim";
      module = {
        imports = [ inputs.nixvim.nixosModules.nixvim ];

        programs.nixvim = {
          enable = true;
        };
      };
    }
  ];
}
