# My nixos config

## Installation

### Pre-install
1. Install nixos
2. Enable flake and nix-commands experimental features via adding this to your
   "/etc/nixos/configuration.nix"

```nix
nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        #"repl-flake"
      ];
      warn-dirty = false;
    };
  };
```

### Setting up config
1. Clone this repository to your machine
2. Change all "pguin" occurrences to your-user-name, change pass
3. Change initialHashedPassword to yours and delete it
4. Copy your hardware-configuration from `/etc/nixos/hardware-configuration.conf` to `<flake>/hosts/<delat&nu>/`
5. Look through all files in `<flake>/hosts/<delta&nu>/` and set they up

### Switch to flake
1. Build and switch to flake with

```sh
sudo nixos-rebuild switch --flake <path/to/this-flake>#<delta(for desktops)/nu(for netbooks)>
```
