{...}: {
  disko.devices = {
    disk = {
      hdd = {
        type = "disk";
        device = "/dev/disk/by-label/HDD";
        content = {
          type = "filesystem";
          format = "ntfs-3g";
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

      win = {
        type = "disk";
        device = "/dev/disk/by-uuid/A49CF3769CF340FA";
        content = {
          type = "filesystem";
          format = "ntfs-3g";
          mountpoint = "/mnt/win";
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

      music = {
        type = "disk";
        device = "/dev/disk/by-uuid/CAA6D29EA6D28A79";
        content = {
          type = "filesystem";
          format = "ntfs-3g";
          mountpoint = "/mnt/music";
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
    };
  };
}
