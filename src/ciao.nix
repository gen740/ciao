{
  ciaoSrc ? null,
}:
_: {
  perSystem =
    { pkgs, ... }:
    {
      packages.ciao = import ./package.nix ({ inherit pkgs; } // pkgs.lib.optionalAttrs (ciaoSrc != null) { inherit ciaoSrc; });
    };
}
