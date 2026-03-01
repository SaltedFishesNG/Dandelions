let
  device = "/dev/vda";
  wichLUKS = false;

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
      "/swap" = {
        mountpoint = "/swap";
        mountOptions = [ "noatime" ];
        swap.swapfile.size = "1G";
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
      "size=50%"
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
        size = "512M";
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
