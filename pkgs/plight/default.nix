{
  lib,
  stdenv,
  ...
}: let
  rev = "2d88511b7cb7f017a338a0c9a79ea7fed699a14c";
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
