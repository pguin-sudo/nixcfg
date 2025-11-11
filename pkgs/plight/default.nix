{
  lib,
  stdenv,
  ...
}: let
  rev = "cd6a836b820d8277f5cc06410ad8629e42793ae2";
  plightFlake = builtins.getFlake "github:pguin-sudo/plight/${rev}";
  pkg = plightFlake.packages.${stdenv.hostPlatform.system}.default;
in
  pkg.overrideAttrs (oldAttrs: {
    meta =
      oldAttrs.meta or {}
      // (with lib; {
        description = "A configurable program for organizing dynamic backlighting";
        homepage = "https://github.com/pguin-sudo/plight";
        license = licenses.gpl3Only;
        maintainers = ["pguin-sudo"];
        platforms = platforms.linux;
      });
  })
