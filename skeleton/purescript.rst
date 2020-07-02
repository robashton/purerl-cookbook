Purescript
##########

For the most part, the Purescript code is entirely self contained, compiling into a single JS bundle that can be served by the web server running in Purerl.

That said, in a Purerl application is it convenient to share *some* code with the Purerl as well (view models and such), and this is why the '*./shared*' folder in the root of the project is symlinked to the '*./client/shared*' directory.

client/packages.dhall
---------------------

This file contains a reference to a package set that is maintained by the `Purescript Organisation <https://github.com/purescript/>`_. A package set is a collection of packages that (hopefully) work nicely together as well as a description of the dependencies between them.

.. literalinclude:: /demo-ps/client/packages.dhall
  :language: dhall
  :linenos:

In the case of demo_ps we're happy with this default package set so don't add anything to it or override anything.

server/spago.dhall
---------------------

Having set up the package set we want to refer to, we *then* define both the packages we're interested in from that package set and where to look for the code files that we are going to write alongside all of this. We use the default backend to generate Javascript.

.. literalinclude:: /demo-ps/client/spago.dhall
  :language: dhall

server/Makefile
---------------------

Make is relatively well understood so while it's not strictly necessary to have in in this project it's nice to set up the build to be dependent on the files in the project so we don't build unnecessarily. We could of course just invoke *spago bundle* from the '*./rebar.config*' in top level and forgo this step.

client/src/*
------------

All of the '*.purs*' found within here (and nested directories) will be built by *spago build* and '*.js*' files will be produced the '*output*' directory corresponding to those files.

*spago bundle* produces a single bundle.js out of these which we can include from HTML to get our client side application up and running. That index.html happens to be found in *priv/www/index.html* and it is next to this file to which this bundle.js gets copied as part of build.
