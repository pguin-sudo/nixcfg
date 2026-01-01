{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.common.services.zapret;
in {
  options.common.services.zapret.enable = mkEnableOption "enable zapret";

  config = mkIf cfg.enable {
    services.zapret = {
      enable = true;
      params = [
        "--dpi-desync=fake,multidisorder"
        "--dpi-desync-fake-tls=0x00000000"
        "--dpi-desync-fake-tls=!"
        "--dpi-desync-split-pos=1,midsld"
        "--dpi-desync-repeats=2"
        "--dpi-desync-fooling=badseq"
        "--dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com"
        #"--filter-l7=discord,stun"
      ];
      #udpSupport = true;
      #udpPorts = [
      #  "50000:50099"
      #  "1234"
      #];
      httpMode = "full"; # Change to full
    };

    #networking.nftables.enable = true;
  };
}
