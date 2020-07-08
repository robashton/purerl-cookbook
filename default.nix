
let
  pinnedNix =
    builtins.fetchGit {
      name = "nixpkgs-pinned";
      url = "https://github.com/NixOS/nixpkgs.git";
      rev = "cc6cf0a96a627e678ffc996a8f9d1416200d6c81";
    };

  nixpkgs = import pinnedNix {};

in

with nixpkgs;

mkShell {
  buildInputs = with pkgs; [
    python37Packages.sphinx
    python37Packages.readthedocs-sphinx-ext
    python37Packages.sphinxcontrib-spelling
    python37Packages.sphinx_rtd_theme
    python37Packages.recommonmark
   ];
}
