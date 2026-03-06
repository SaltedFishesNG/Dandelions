{
  inputs,
  mkBool,
  mkStr,
  ...
}:
{
  schema.disko = {
    device = mkStr "/dev/null";
    withLUKS = mkBool true;
    useZFS = mkBool false;
    espSize = mkStr "1000M";
    swapfileSize = mkStr null;
    withPostMbrGap = mkBool false;
    imageSize = mkStr "2G";
  };

  traits.disko =
    {
      lib,
      schema,
      system,
      ...
    }:
    let
      cfg = schema.disko;
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
        }
        // lib.optionalAttrs (cfg.swapfileSize != null) {
          "/swap" = {
            mountpoint = "/swap";
            mountOptions = [ "noatime" ];
            swap.swapfile.size = cfg.swapfileSize;
          };
        };
      };

      zfsPool.zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
              atime = "off";
            };
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
        }
        // lib.optionalAttrs (cfg.swapfileSize != null) {
          "local/swap" = {
            type = "zfs_volume";
            content.type = "swap";
            options = {
              volblocksize = "4096";
              compression = "zle";
              logbias = "throughput";
              sync = "always";
              primarycache = "metadata";
              secondarycache = "none";
              "com.sun:auto-snapshot" = "false";
            };
            size = cfg.swapfileSize;
          };
        };
      };

      zfs = {
        type = "zfs";
        pool = "zroot";
      };

      fsContent = if cfg.useZFS then zfs else btrfs;
      luks = {
        type = "luks";
        name = "primary";
        settings = {
          allowDiscards = true;
          bypassWorkqueues = true;
        };
        content = fsContent;
      };
    in
    {
      imports = [ inputs.disko.nixosModules.disko ];

      disko.imageBuilder = lib.mkIf (system == null) {
        enableBinfmt = true;
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_latest;
      };
      disko.devices.nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=100%"
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
            size = cfg.espSize;
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
            content = if cfg.withLUKS then luks else fsContent;
          };
        };
      }
      // lib.optionalAttrs cfg.withPostMbrGap {
        boot = {
          size = "1M";
          type = "EF02";
          priority = 0;
        };
      };

      disko.devices.zpool = if cfg.useZFS then zfsPool else { };
    };
}
