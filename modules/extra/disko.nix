{
  inputs,
  mkBool,
  mkStr,
  ...
}:
{
  schema.extra.disko = {
    device = mkStr "/dev/sda";
    wichLUKS = mkBool true;
    swapfileSize = mkStr null;
    ESPsize = mkStr "1000M";
    wichPostMbrGap = mkBool false;
    imageSize = mkStr "2G";
  };

  modules.extra.disko.load = [
    inputs.disko.nixosModules.disko
    (
      {
        host,
        inputs,
        lib,
        system,
        ...
      }:
      let
        cfg = host.extra.disko;
        btrfs = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "/nix" = {
              mountpoint = "/nix";
              mountOptions = [
                "noatime"
                "compress-force=zstd"
              ];
            };
            "/persist" = {
              mountpoint = "/persist";
              mountOptions = [
                "noatime"
                "compress-force=zstd"
              ];
            };
            "/tmp" = {
              mountpoint = "/tmp";
              mountOptions = [
                "noatime"
                "compress-force=zstd"
              ];
            };
          }
          // lib.optionalAttrs (cfg.swapfileSize != null) {
            "/swap" = {
              mountpoint = "/swap";
              mountOptions = [ "noatime" ];
              swap.swapfile.size = cfg.swapfileSize;
            };
          };
        };

        luks = {
          type = "luks";
          name = "primary";
          settings = {
            allowDiscards = true;
            bypassWorkqueues = true;
          };
          content = btrfs;
        };
      in
      {
        disko.imageBuilder = {
          enableBinfmt = true;
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_latest;
        };
        disko.devices.nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=50%"
            "defaults"
            "mode=755"
          ];
        };

        disko.devices.disk.main = {
          imageSize = cfg.imageSize;
          type = "disk";
          device = cfg.device;
          content.type = "gpt";
          content.partitions = {
            ESP = {
              size = cfg.ESPsize;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            primary = {
              size = "100%";
              content = if cfg.wichLUKS then luks else btrfs;
            };
          };
        }
        // lib.optionalAttrs cfg.wichPostMbrGap {
          boot = {
            size = "1M";
            type = "EF02";
            priority = 0;
          };
        };
      }
    )
  ];
}
