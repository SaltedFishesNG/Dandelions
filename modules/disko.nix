let
  device = "/dev/null";
  wichLUKS = false;
  espSize = "512M";
  swapfileSize = "1G";

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
      "/swap" = {
        mountpoint = "/swap";
        mountOptions = [ "noatime" ];
        swap.swapfile.size = swapfileSize;
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
  disko.devices.nodev."/" = {
    fsType = "tmpfs";
    mountOptions = [
      "size=100%"
      "defaults"
      "mode=755"
    ];
  };

  disko.devices.disk.main = {
    type = "disk";
    device = device;
    content.type = "gpt";
    content.partitions = {
      ESP = {
        size = espSize;
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
        content = if wichLUKS then luks else btrfs;
      };
    };
  };
}
