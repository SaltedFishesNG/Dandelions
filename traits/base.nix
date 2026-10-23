{
  schema.base = {
    lix.enable = false; # bool

    username = "alice"; # str
    authorizedKeys = [ ]; # listOf singleLineStr

    bluetooth.enable = true; # bool
    isLaptop = false; # bool
    pipewire.enable = true; # bool
    sudo-rs.enable = false; # bool
    tpm2.enable = true; # bool
  };

  traits.base =
    {
      config,
      inputs,
      lib,
      node,
      pkgs,
      ...
    }:
    let
      cfg = node.schema.base;
    in
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

      users.mutableUsers = false;
      users.users.${cfg.username} = {
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
        isNormalUser = true;
        autoSubUidGidRange = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.fish;
      };
      programs.fish = {
        enable = true;
        shellAbbrs = {
          sudo = lib.mkIf (!cfg.sudo-rs.enable) "doas";
        };
        interactiveShellInit = ''
          set fish_color_command blue
          bind ctrl-w backward-kill-bigword
        '';
      };

      security = {
        doas = {
          enable = true;
          extraConfig = "permit persist keepenv :wheel";
        };
        sudo.enable = false;
        sudo-rs = {
          enable = cfg.sudo-rs.enable;
          execWheelOnly = true;
          wheelNeedsPassword = true;
        };
        tpm2 = {
          enable = cfg.tpm2.enable;
          pkcs11.enable = true;
          tctiEnvironment.enable = true;
        };
      };

      hardware.bluetooth = {
        enable = cfg.bluetooth.enable;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      services = {
        dbus.implementation = "broker";
        kmscon = {
          enable = true;
          extraOptions = "--term xterm-256color";
        };
        logind.settings.Login = lib.mkIf cfg.isLaptop {
          HandlePowerKey = "hibernate";
          HandleLidSwitch = "suspend-then-hibernate";
        };
        openssh = {
          enable = true;
          ports = [ 22 ];
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "prohibit-password";
            X11Forwarding = true;
          };
        };
        pipewire = {
          enable = cfg.pipewire.enable;
          alsa.enable = true;
          pulse.enable = true;
        };
        userborn.enable = true;
      };

      documentation.nixos.enable = false;
      documentation.man.cache.enable = false; # Slow build due to fish enabling caches

      nix = {
        package = if cfg.lix.enable then pkgs.lixPackageSets.latest.lix else pkgs.nixVersions.latest;
        channel.enable = false;
        settings = {
          allowed-users = [ "@wheel" ];
          auto-allocate-uids = true;
          auto-optimise-store = true;
          builders-use-substitutes = true;
          download-attempts = 15;
          experimental-features = [
            "auto-allocate-uids"
            "cgroups"
            "flakes"
            "nix-command"
          ]
          ++ lib.optionals cfg.lix.enable [ "pipe-operator" ]
          ++ lib.optionals (!cfg.lix.enable) [
            "ca-derivations"
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
    };
}
