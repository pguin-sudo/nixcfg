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
      #      win = {
      #        type = "disk";
      #        device = "/dev/disk/by-uuid/a49078ce-3cff-4422-b92e-4b946522bdb2";
      #        content = {
      #          type = "filesystem";
      #format = "ext4";
      #          mountpoint = "/mnt/win";
      #        };
      #      };
    };
  };
}
