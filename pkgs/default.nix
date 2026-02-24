final: prev: {
  crossover = final.callPackage ./crossover.nix { };
  ida-pro = final.callPackage ./ida-pro.nix { };
}
