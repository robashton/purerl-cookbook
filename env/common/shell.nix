
let
  pinnedNix =
    builtins.fetchGit {
      name = "nixpkgs-pinned";
      url = "https://github.com/NixOS/nixpkgs.git";
      rev = "cc6cf0a96a627e678ffc996a8f9d1416200d6c81";
    };

  nixpkgs =
    import pinnedNix {
      overlays = [
        (import ./.)
      ];
    };

  inherit (nixpkgs.stdenv.lib) optionals;
  inherit (nixpkgs)stdenv;
in

with nixpkgs;

mkShell {
  buildInputs = with pkgs; [
    python27Packages.sphinx
    python27Packages.readthedocs-sphinx-ext
    python27Packages.sphinx_rtd_theme
    python27Packages.recommonmark
   ];
}
