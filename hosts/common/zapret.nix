{ lib, config, ... }:
let
  readLines =
    file:
    builtins.filter (l: l != "" && !(lib.hasPrefix "#" l)) (
      lib.splitString "\n" (builtins.readFile file)
    );
  ipsetExcludeArg = [ "--ipset-exclude=/etc/zapret2/lists/ipset-exclude.txt" ];
  ipsetArgs = [ "--ipset=/etc/zapret2/lists/ipset-all.txt" ] ++ ipsetExcludeArg;
in
{
  disabledModules = [ "services/networking/zapret2.nix" ];

  services.zapret2 = {
    enable = true;
    presets = [
      "youtube"
      "discord"
      "general"
      "general-ts"
      "winws"
    ];
    firewall.ports.udp = [ "443" ];
    defaultPreset = "winws";
    extraPresets.winws = {
      description = "Custom strategy migrated from Windows winws.exe bat script (zapret v1 syntax)";
      hostlist = readLines ./zapret-data/lists/list-general.txt;
      hostlistExclude = readLines ./zapret-data/lists/list-exclude.txt;
      profiles = [
        {
          name = "quic-general";
          filter.udp = "443";
          hostlist = true;
          payload = [ "quic_initial" ];
          desync = [
            "fake:blob=fake_default_quic:repeats=1"
            "send:ipfrag:ipfrag_pos_udp=64"
            "drop"
          ];
          extraArgs = ipsetExcludeArg;
        }

        {
          name = "discord-voice";
          filter.l7 = [
            "discord"
            "stun"
          ];
          hostlist = false;
          payload = [
            "discord_ip_discovery"
            "stun"
          ];
          desync = [ "fake:blob=discord_udp:repeats=6" ];
          extraArgs = [
            "--blob=quic_rutube:@${./zapret-data/blobs/quic_initial_rutube_ru.bin}"
            "--blob=quic_google:@${./zapret-data/blobs/quic_initial_www_google_com.bin}"
            "--blob=discord_udp:@${./zapret-data/blobs/ACTIVE_DISCORD_UDP.bin}"
            "--blob=tls_google:@${./zapret-data/blobs/tls_clienthello_www_google_com.bin}"
            "--blob=stun_tls:@${./zapret-data/blobs/stun.bin}"
            "--blob=tls_max_ru:@${./zapret-data/blobs/tls_clienthello_max_ru.bin}"
            "--blob=game_udp:@${./zapret-data/blobs/ACTIVE_GAME_UDP.bin}"
          ];
        }

        {
          name = "discord-tls";
          filter.tcp = "443-65535";
          hostlist = lib.unique (
            [ "discord.media" ]
            ++ lib.filter (lib.hasInfix "discord") (readLines ./zapret-data/lists/list-general.txt)
          );
          payload = [ "tls_client_hello" ];
          desync = [ "hostfakesplit:host=www.google.com:tcp_ts=-1000:tcp_md5:repeats=4" ];
        }

        {
          name = "google-tls";
          filter.tcp = "443";
          hostlist = readLines ./zapret-data/lists/list-google.txt;
          payload = [ "tls_client_hello" ];
          desync = [ "multidisorder:pos=sniext+4" ];
        }

        {
          name = "general-tls";
          filter.tcp = "80,443";
          hostlist = true;
          payload = [
            "tls_client_hello"
            "http_req"
          ];
          desync = [
            "multidisorder:pos=sniext+4:payload=tls_client_hello"
            "fake:blob=tls_max_ru:repeats=6:tcp_seq=1000:payload=http_req"
            "multisplit:pos=1:payload=http_req"
          ];
          extraArgs = ipsetExcludeArg;
        }

        {
          name = "quic-ipset";
          filter.udp = "443";
          payload = [ "quic_initial" ];
          desync = [
            "fake:blob=fake_default_quic:repeats=1"
            "send:ipfrag:ipfrag_pos_udp=64"
            "drop"
          ];
          extraArgs = ipsetArgs;
        }

        {
          name = "tls-ipset";
          filter.tcp = "80,443,8443";
          payload = [
            "tls_client_hello"
            "http_req"
          ];
          desync = [
            "multidisorder:pos=sniext+4:payload=tls_client_hello"
            "fake:blob=tls_max_ru:repeats=6:tcp_seq=1000:payload=http_req"
            "multisplit:pos=1:payload=http_req"
          ];
          extraArgs = ipsetArgs;
        }

        {
          name = "game-tcp";
          filter.tcp = "12";
          extraArgs = ipsetArgs ++ [
            "--payload=all"
            "--out-range=-n3"
            "--lua-desync=fake:blob=stun_tls:repeats=6:tcp_seq=1000:payload=all"
            "--lua-desync=fake:blob=tls_google:repeats=6:tcp_seq=1000:payload=all"
            "--lua-desync=fake:blob=tls_max_ru:repeats=6:tcp_seq=1000:payload=all"
            "--lua-desync=multisplit:pos=1"
          ];
        }

        {
          name = "game-udp";
          filter.udp = "12";
          extraArgs = ipsetArgs ++ [
            "--payload=all"
            "--out-range=-n2"
            "--lua-desync=fake:blob=game_udp:repeats=10:payload=all"
          ];
        }
      ];
    };
  };

  environment.etc."zapret2/lists/ipset-all.txt".source = ./zapret-data/lists/ipset-all.txt;
  environment.etc."zapret2/lists/ipset-exclude.txt".source = ./zapret-data/lists/ipset-exclude.txt;
  networking.nftables.enable = true;

  networking.nftables.tables.zapret2-voice = {
    family = "inet";
    content =
      let
        mark = config.services.zapret2.firewall.desyncMark;
      in
      ''
        chain zapret2_voice_postrouting {
          type filter hook postrouting priority mangle + 10; policy accept;
          meta mark and ${mark} == ${mark} counter return
          udp dport { 19294-19344, 50000-50100 } counter queue flags bypass to ${toString config.services.zapret2.qnum}
        }
      '';
  };
}
