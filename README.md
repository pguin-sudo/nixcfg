# My nixos config

## Installation

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

3. Clone this repository to your machine
4. Change all "pguin" occurrences to your-user-name
5. Build and switch to flake with

```sh
sudo nixos-rebuild switch --flake <path/to/this-flake>#<delta(for desktops)/nu(for netbooks)>
```
