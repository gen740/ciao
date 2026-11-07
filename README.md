# ciao-nix

Nix flake that builds [CIAO](https://cxc.cfa.harvard.edu/ciao/), the Chandra
X-ray Center's analysis software, from source.

| Package | Upstream                  | Version (default) |
| ------- | ------------------------- | ----------------- |
| `ciao`  | Chandra X-ray Center, SAO | 4.18.0            |

The source is downloaded from the CXC's conda channel and fixed by its hash. It
is **not** redistributed here; see [License](#license).

## Supported systems

| System           | State                                                                   |
| ---------------- | ----------------------------------------------------------------------- |
| `aarch64-linux`  | Built and run. The CXC publishes no binaries for it, so this is the way to get CIAO there |
| `aarch64-darwin` | Built and run                                                           |
| `x86_64-linux`   | Listed, not built yet                                                   |

"Run" means `dmcopy`, `dmstat` and `dmlist` on the events of Chandra ObsID 25628:
images in three energy bands, 360x360 pixels each, were the same in every pixel as
a histogram made with numpy. CIAO's own test suite has not been run.

## Usage

```console
$ nix build github:gen740/ciao#ciao
```

### In your own flake

```nix
{
  inputs.ciao.url = "github:gen740/ciao";

  outputs = inputs@{ flake-parts, ciao, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ciao.flakeModules.ciao ];
      systems = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ];
    };
}
```

This adds `ciao` to `perSystem.packages`. To pin another source, use
`(ciao.mkFlakeModules.ciao { ciaoSrc = { version = "..."; url = "..."; sha256 = "..."; }; })`.

### Without flakes

`src/package.nix` is a plain function of `pkgs`:

```nix
import ./src/package.nix { inherit pkgs; }
```

It needs `ciao-setup-hook.sh` next to it.

## Environment setup

The package ships a setup hook, so adding it to a `devShell` exports
`ASCDS_INSTALL` and `PFILES`. Outside one, set them yourself:

```console
$ export ASCDS_INSTALL=/nix/store/...-ciao-4.18.0
$ export PFILES="$HOME/cxcds_param4;$ASCDS_INSTALL/param"
```

`PFILES` needs a writable folder first, because the tools save their parameters
there.

## What is and is not included

Included: the libraries and command line tools (`corelibs`, `ciaolibs` and
`ciaotools` in the source).

Not included:

- `pyciao`: the Python modules (`pycrates` and the like), so scripts that import
  them do not work
- `obsvis`: the ds9 integration
- Sherpa and `ciao-contrib`
- CALDB, the calibration data, which many tools need (`specextract`, for instance)

## Differences from the CXC's build

| | CXC | Here |
| --- | --- | --- |
| Compiler on Linux | GCC 13 | nixpkgs' default |
| cfitsio | 4.5.0 | nixpkgs' |
| Boost | 1.85 | 1.86 |
| libwcs | wcssubs 3.9.5 | wcstools 3.9.7 (the 3.9.5 tarball is no longer on the server) |
| `-ffp-contract=off` | macOS ARM only | also Linux ARM |

## License

The **packaging code** in this repository is licensed under the
[MIT License](./LICENSE).

The MIT License covers **only** this packaging code. CIAO is licensed under the
GNU GPL version 3 or later, with parts under its own license (see
[Licenses](https://cxc.cfa.harvard.edu/ciao/download/license.html)). It and the
other third-party software are downloaded from upstream at build time, are **not**
redistributed here, and are governed by their own terms. See the `SCOPE OF THIS
LICENSE / NOTICE ON THIRD-PARTY SOFTWARE` section in [LICENSE](./LICENSE).
