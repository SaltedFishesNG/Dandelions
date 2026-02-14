{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    nixy.url = "github:cuskiy/nixy";
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    { nixpkgs, nixy, ... }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forSystems = f: lib.genAttrs systems f;
      cluster =
        system:
        nixy.eval {
          inherit lib;
          imports = [
            ./traits
            ./nodes
          ];
          args = { inherit inputs system; };
        };
      mkSystem = node: lib.nixosSystem { modules = [ node.module ]; };
    in
    {
      nixosConfigurations = lib.mapAttrs (_: mkSystem) (cluster null).nodes;
      formatter = forSystems (s: nixpkgs.legacyPackages.${s}.nixfmt-tree);
      packages = forSystems (
        s:
        let
          nodes = (cluster s).nodes;
        in
        {
          diskoImage = (mkSystem nodes.Image).config.system.build.diskoImages;
          iso = (mkSystem nodes.iso).config.system.build.isoImage;
        }
      );
    };
}
