{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    inputs.preservation.nixosModules.preservation
    ./preservation.nix
  ];
}
