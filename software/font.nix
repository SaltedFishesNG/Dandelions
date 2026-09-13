{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      fira-code
      font-awesome
      iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      sarasa-gothic
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Noto Serif"
        "Noto Serif CJK TC"
      ];
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK TC"
      ];
      monospace = [
        "Fira Code"
        "Iosevka"
        "Sarasa Mono CL"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
