{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
{
  time.timeZone = "UTC";
  i18n.defaultLocale = "C.UTF-8";
  i18n.extraLocales = "all";
  console.keyMap = "us";

  boot = {
    kernelParams = [ "drm.panic_screen=qr_code" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
      systemd-boot.configurationLimit = 25;
    };
    zfs.forceImportRoot = false;
    zswap.enable = config.swapDevices != [ ];
  };
  zramSwap.enable = config.swapDevices == [ ];

  system.etc.overlay.enable = true;
  system.nixos-init.enable = true;
  systemd.enableEmergencyMode = false;
  systemd.settings.Manager.LogLevel = "notice";

  networking = {
    hostName = "NixOS";
    hostId = "00000000";
    dhcpcd.enable = false;
    resolvconf.enable = false;
    networkmanager.enable = true;
    networkmanager.dns = lib.mkForce "none";
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
    nftables.enable = true;
  };
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];
  services.resolved.enable = false;
  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 1.0.0.1
    nameserver 2606:4700:4700::1111
    nameserver 2606:4700:4700::1001
  '';
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  users.mutableUsers = false;
  users.users.${username} = {
    password = "";
    isNormalUser = true;
    autoSubUidGidRange = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_color_command blue
      bind ctrl-w backward-kill-bigword
    '';
  };

  security = {
    # doas = {
    #   enable = true;
    #   extraConfig = "permit persist keepenv :wheel";
    # };
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  services = {
    dbus.implementation = "broker";
    kmscon = {
      enable = true;
      extraOptions = "--term xterm-256color";
    };
    # logind.settings.Login = {
    #   HandlePowerKey = "hibernate";
    #   HandleLidSwitch = "suspend-then-hibernate";
    # };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    userborn.enable = true;
  };

  documentation.nixos.enable = false;
  documentation.man.cache.enable = false; # Slow build due to fish enabling caches

  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      allowed-users = [ "@wheel" ];
      auto-allocate-uids = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      download-attempts = 15;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      flake-registry = "${inputs.flake-registry}/flake-registry.json";
      pure-eval = true;
      stalled-download-timeout = 15;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      use-cgroups = true;
      warn-dirty = false;
    };
  };
}
