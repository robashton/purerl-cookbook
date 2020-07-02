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

An up to date and working `shell.nix <https://github.com/id3as/demo-ps/blob/master/shell.nix>`_ can be found in the `demo_ps project <https://github.com/id3as/demo_ps>`_ and can usually be copied as-is.  Combined with `direnv <https://direnv.net/>`_, a sensible nix-shell can automatically provide a functional Purerl development environment as soon as you enter the directory for a project.

Essentially if the .envrc does

.. code-block:: bash

  use_nix

And a shell.nix is provided next to this file, for example

.. literalinclude:: /demo-ps/shell.nix
  :language: nix

Then allowing direnv to execute within the directory will provide all the tooling required for building the project once nix has downloaded and built the required assets, simples. Building and running the project from within this nix shell therefore looks like this:

.. code-block:: bash

  # Compile the project
  rebar3 compile

  # Build a release
  rebar3 release

  # Run the whole shebang
  ./run
