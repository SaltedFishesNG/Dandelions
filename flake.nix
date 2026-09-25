{
  description = "Until dandelions spread across the desert...";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit.follows = "";
    };
    nixy.url = "github:cuskiy/nixy";
    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    { nixpkgs, nixy, ... }@inputs:
    let
      cluster = nixy.eval { imports = [ ./nodes ] ++ [ ./traits ]; };
      mkSystem =
        system: node:
        nixpkgs.lib.nixosSystem {
          modules = [ node.module ];
          specialArgs = { inherit inputs system node; };
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (_: mkSystem null) cluster.nodes;
      packages = builtins.mapAttrs (system: pkgs: {
        diskoImage = (mkSystem system cluster.nodes.Image).config.system.build.diskoImages;
        iso = (mkSystem system cluster.nodes.iso).config.system.build.isoImage;
      }) nixpkgs.legacyPackages;
      formatter = builtins.mapAttrs (system: pkgs: pkgs.nixfmt-tree) nixpkgs.legacyPackages;
    };
}
