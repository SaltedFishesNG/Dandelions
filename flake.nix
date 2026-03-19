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
      # nixpkgs-patched = system: import ./nixpkgs-patches { inherit nixpkgs system; };
      cluster = nixy.eval { imports = [ ./nodes ] ++ [ ./traits ]; };
      mkSystem =
        system: node:
        nixpkgs.lib.nixosSystem {
          modules = [ node.module ];
          specialArgs = { inherit inputs system node; };
        };
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed f;
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (_: mkSystem null) cluster.nodes;
      packages = forAllSystems (system: {
        diskoImage = (mkSystem system cluster.nodes.Image).config.system.build.diskoImages;
        iso = (mkSystem system cluster.nodes.iso).config.system.build.isoImage;
      });
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
