{ pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ./font.nix
  ];

  environment.systemPackages = with pkgs; [
    disko
    file
    gnupg
    ncdu
    nh
    nix-output-monitor
    p7zip
    parted
    tree
    unrar-free
    unzip
    wget
    zip
  ];

  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      config = {
        core.autocrlf = "input";
        core.editor = "vim";
        log.date = "iso8601";
        merge.autoStash = true;
        pull.autoStash = true;
        pull.rebase = true;
        rebase.autoStash = true;
        safe.directory = "*";
      };
    };
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-tty;
    };
    htop = {
      enable = true;
      settings = {
        color_scheme = 6;
        hide_userland_threads = true;
        highlight_base_name = true;
        highlight_changes = true;
        shadow_other_users = true;
        show_cpu_temperature = true;
        show_program_path = false;
        tree_view = true;
      };
    };
    nix-ld.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };

  services.flatpak.enable = true;
}
