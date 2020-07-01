Nix
###

Nix is probably the easiest way to get started with Purerl (and stay up to date with releases).

Packages are provided in the following Github repos

* `nixerl/nixpkgs-nixerl <https://github.com/nixerl/nixpkgs-nixerl>`_ Erlang + Rebar3 Releases
* `purerl/nixpkgs-purerl <https://github.com/purerl/nixpkgs-purerl>`_ Purerl backend
* `id3as/nixpkgs-purerl-support <https://github.com/id3as/nixpkgs-purerl-support>`_ Purerl support packages

The core nix packages do contain tools like Purescript and Dhall, but these can laig a bit behind at times - the above repos when combined contain packages for everything sat at at up-to-date versions of those things (written as overlays on top of existing packages where possible).

Using them
----------

An up to date and working `shell.nix <https://github.com/id3as/demo-ps/blob/master/env/common/shell.nix>`_ can be found in the `demo_ps project <https://github.com/id3as/demo_ps>`_ and can usually be copied as-is.  Combined with `direnv <https://direnv.net/>`_, a sensible nix-shell can automatically provide a functional Purerl development environment as soon as you enter the directory for a project.

Essentially if the .envrc does

.. code-block:: bash

  use_nix


And a shell.nix is provided next to this file, for example

.. code-block:: nix

  let
    erlangReleases = builtins.fetchTarball https://github.com/nixerl/nixpkgs-nixerl/archive/v1.0.4-devel.tar.gz;

    pinnedNix =
      builtins.fetchGit {
        name = "nixpkgs-pinned";
        url = "https://github.com/NixOS/nixpkgs.git";
        rev = "cc6cf0a96a627e678ffc996a8f9d1416200d6c81";
      };

    pursPackages =
      builtins.fetchGit {
        name = "purerl-packages";
        url = "git@github.com:purerl/nixpkgs-purerl.git";
        rev = "5da0a433bcefe607e0bd182b79b220af980a4c78";
      };

    supportPackages =
      builtins.fetchGit {
        name = "purerl-support-packages";
        url = "git@github.com:id3as/nixpkgs-purerl-support.git";
        rev = "2299658a78f2827e3844084861ae4fa88dcddd8b";
      };


    nixpkgs =
      import pinnedNix {
        overlays = [
          (import erlangReleases)
          (import pursPackages)
          (import supportPackages)
        ];
      };

    inherit (nixpkgs.stdenv.lib) optionals;
    inherit (nixpkgs)stdenv;
  in

  with nixpkgs;

  mkShell {
    buildInputs = with pkgs; [

      nixerl.erlang-22-3.erlang
      nixerl.erlang-22-3.rebar3

      purerl.purerl-0-0-5

      purerl-support.purescript-0-13-6
      purerl-support.spago-0-12-1-0
      purerl-support.dhall-json-1-5-0
     ];
  }


Then all the tooling required will be available for building the project, simples.
