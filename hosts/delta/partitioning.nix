{ ... }:

{
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/mnt/hdd" = { 
    device = "/dev/disk/by-uuid/7C006A080069C9AA";
    fsType = "ntfs";
    options = [ "rw" "uid=1000" "gid=100" ];
  };

  fileSystems."/mnt/win" = { 
    device = "/dev/disk/by-uuid/a49078ce-3cff-4422-b92e-4b946522bdb2";
    fsType = "ext4";
  };
}
