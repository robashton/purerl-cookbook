The build process
##################

In an ideal world there would  be a single tool for building, releasing, testing and performing package management for Purerl applications.

This is not the case, and we have tools for building Purescript and we have tools for building and releasing Erlang. To add onto this we're writing our clientside application in Purescript as well so that makes for three isolated build processes.

We *do* use a single tool for running all of the individual builds however, and that is rebar3 (the Erlang build tool), this will invoke both the client and server builds and then the Erlang.

It is easier mentally, to separate the Erlang and Purescript aspects of a Purerl application out and treat them as wholly independent, but this is not the case either - as Purescript modules can have (documented, but not automated) runtime dependencies on Erlang packages. 

Purerl (Server) Build
*********************

There is a Makefile in the *'server'* folder in demo_ps, which will compile the '*.purs*' and dependencies into '*.erl*' in an '*output*' folder and then copy them into '*src/compiled_ps*'. This uses the tools of *spago*, *dhall*, *purs* and *purerl* for this task and the contents of '*packages.dhall*' and '*spago.dhall*' to determine how to do that.

Assuming this is succesful, then we are strictly back in Erlang world and using Erlang tools to handle these compiled files.

Erlang (Server) Build
*********************

The tool for building Erlang is *Rebar3*, which reads the contents of '*rebar.config*' to determine what dependencies to bring down and compile as well as anything found in the '*src*' directory (including our *compiled_ps*' from the Purerl world).

There are hooks in the '*rebar.config*' to invoke the Makefile found in '*server*' in order to perform the purescript build automatically before running the Erlang build. 

Purescript (Client) Build
*************************

There is a Makefile in the *'client'* folder in demo_ps, which will compile the *.purs* and dependencies into *.js* in an 'output' folder and bundle them so the browser can understand them. This uses the tools of *spago*, *dhall* and *purs* for this task and the contents of *packages.dhall* and *spago.dhall* to determine how to do that.  

The output of this will be copied into the 'priv' folder of the Erlang application so they can be served by the web server (Stetson).

Again, there are hooks in the *rebar.config* to invoke this Makefile, so the only command that actually needs executing for performing all of the above tasks is *rebar3 compile*.

.. toctree::
   :hidden:
   :titlesonly:

   Tools <tools>
   Docker <docker>
   Nix <nix>

