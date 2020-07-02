Purerl 
#######

The Purerl code is relatively easy to follow coming from any sort of JS environment, in essence it boils down to a single folder of code with a manifest describing the package and its dependencies. The compiler will take all of the Purescript and compile both it and the modules to the output directory and then it's up to us to copy that to somewhere the Erlang compiler can find so it can be further compiled into the beam format.

It is convenient sometimes to share some code between the client and server, and in the demo_ps project this is located in a '*./shared*' folder that is symlinked from '*./server/shared*'.

server/packages.dhall
---------------------

This file contains a reference to a package set that is maintained by the `Purerl Organisation <https://github.com/purerl/>`_. A package set is a collection of packages that (hopefully) work nicely together as well as a description of the dependencies between them.

.. literalinclude:: /demo-ps/server/packages.dhall
  :language: dhall
  :linenos:
  :lines: 1-2

This is followed (presently) by some overrides of packages that exist within the package set, but of which we want later versions of (because we like to live life on the edge)

.. literalinclude:: /demo-ps/server/packages.dhall
  :language: dhall
  :linenos:
  :lines: 3-21

This gives us an amount of flexibility to work on both a stable set of packages as well as actively developed/updated packages that we might ourselves be maintaining.

server/spago.dhall
---------------------

Having set up the package set we want to refer to, we *then* define both the packages we're interested in from that package set and where to look for the code files that we are going to write alongside all of this. We also specify that our backend  is going to be 'purerl' because compiling all of this code into Javascript isn't going to do us very much good.

.. literalinclude:: /demo-ps/server/spago.dhall
  :language: dhall


server/Makefile
---------------------

Make is relatively well understood so while it's not strictly necessary to have in in this project it's nice to set up the build to be dependent on the files in the project so we don't build unnecessarily. We could of course just invoke *spago build* from the '*./rebar.config*' in top level and forgo this step.


server/src/*
------------

All of the '*.purs*' found within here (and nested directories) will be built by *spago build* and '*.erl*' files will be produced the '*output*' directory corresponding to those files.

These then get copied into '*./src/compiled_ps*' for compilation by the standard Erlang workflow.
