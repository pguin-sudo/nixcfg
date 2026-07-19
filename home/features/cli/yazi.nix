{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.cli.yazi;
in
{
  options.features.cli.yazi.enable = mkEnableOption "yazi file manager";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yazi
      ffmpeg
      poppler
      imagemagick
    ];

    home.file.".config/yazi/yazi.toml".text = ''
      [mgr]
      show_hidden = true

      [manager]
      ratio           = [1, 4, 3]
      linemode        = "size"
      sort_by         = "natural"
      sort_dir_first  = true
      show_hidden     = false
      show_symlink    = true
      scrolloff       = 6

      [preview]
      wrap            = "no"
      image           = true
      image_quality   = 90

      [opener]
      zed = [
          { run = 'zed "$@"', desc = "Zed", orphan = true, for = "unix" },
      ]
    '';

    programs.zsh.initContent = ''
      function y() {
        local tmp="$(mktemp -t "yazi-cwd-XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
  };
}
