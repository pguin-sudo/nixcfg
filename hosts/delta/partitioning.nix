{...}: {
  disko.devices = {
    disk = {
      hdd = {
        type = "disk";
        device = "/dev/disk/by-uuid/7C006A080069C9AA";
        content = {
          type = "filesystem";
          format = "ntfs3";
          mountpoint = "/mnt/hdd";
          mountOptions = [
            "rw"
            "uid=1000"
            "gid=100"
            "umask=022"
            "fmask=113"
            "dmask=002"
          ];
        };
      };
      #win = {
      #  type = "disk";
      #  device = "/dev/disk/by-uuid/ata-Samsung_SSD_850_EVO_120GB_S21SNXAGC01969M-part3";
      #  content = {
      #    type = "filesystem";
      #    format = "ntfs3";
      #    mountpoint = "/mnt/win";
      #    mountOptions = [
      #      "rw"
      #      "uid=1000"
      #      "gid=100"
      #      "umask=022"
      #      "fmask=113"
      #      "dmask=002"
      #    ];
      #  };
      #};

      #music = {
      #  type = "disk";
      #  device = "/dev/disk/by-uuid/wwn-0x50014ee6b006eea5-part2";
      #  content = {
      #    type = "filesystem";
      #    format = "ntfs3";
      #    mountpoint = "/mnt/music";
      #    mountOptions = [
      #      "rw"
      #      "uid=1000"
      #      "gid=100"
      #      "umask=022"
      #      "fmask=113"
      #      "dmask=002"
      #    ];
      #  };
      #};
    };
  };
}
