Required  Tools
###############

There are quite a lot of dependencies and tools required to build a fully fledged Purerl application, it is for this purpose that the nix/docker scripts are used in the demo_ps project.  

They can obviously be installed independently or by other automated means so for that purpose they are linked and detailed below for those wishing to embark on that journey.

`Purescript <https://www.purescript.org>`_
***************************************************

At the heart of it, Purescript is just a binary *'purs'* that knows how to compile Purescript into JS (its original purpose). Binary releases are provided for most platforms and this just needs to be in path.

`Purerl <https://github.com/purerl/purescript>`_ 
***************************************************

Purs (above) supports different backends, so with the right switches (in spago.dhall) we can use a different backend and compile into something else. In this case we're compiling the Purescript into Erlang.

`Spago <https://github.com/purescript/spago>`_ 
***************************************************

Spago is a build tool used for both Purescript on the frontend and Purerl on the backend, it is used to download dependencies for the relevant application and also to configure the inputs to the purs compiler. That is which files it needs to compile, which backend to use for that compilation process amongst any other flags configureed.

`Dhall <https://dhall-lang.org/>`_ 
***************************************************

Dhall is a typed configuration language used for more than one thing, but specifically in this case it's used to describe the available dependencies for a Purescript project in the form of "package sets".

`Erlang <https://erlang.org>`_ 
***************************************************

Erlang is the original language that compiles into BEAM, which is what is executed by the Erlang runtime. It comes with a compiler (erlc) for this purpose, and various other tools that we don't need to know about here.

`Rebar3 <https://www.rebar3.org/>`_ 
***************************************************

Rebar3 is a build tool for Erlang which reads the configuration for the project and pulls down dependencies and knows how to invoke the Erlang compiler on both those dependencies and the code written within the project. It also knows  how to read various other assets in the project in order to package them up for release.
