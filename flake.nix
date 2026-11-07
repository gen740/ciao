{
  description = "CIAO, the Chandra X-ray Center's analysis tools, built from source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } rec {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];

      flake = {
        flakeModules.ciao = import ./src/ciao.nix { };
        mkFlakeModules.ciao = import ./src/ciao.nix;
      };

      imports = [ flake.flakeModules.ciao ];
    };
}
