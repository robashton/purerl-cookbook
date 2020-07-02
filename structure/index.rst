Skeleton
########

As mentioned in the :doc:`build env</devenv/index>` section, setting up a Purerl application is unfortunately a bit of a dance involving the merging of several worlds, the Erlang world, Rebar3/Relx and Purescript itself along with its build toools.

This can be quite daunting, Erlang already had quite a bit of overhead for a basic 'hello world' demo and adding the complexity of additional tooling and configuration to support Purescript can make it quite even tougher. If you're approaching Purerl from the point of view of either an Erlang programmer or a Purescript programmer than at least half of this world  will be familiar to you, if you're coming at it fresh then you have my sympathies.

The easy solution for the most part is to copy an empty application (like  `demo_ps <https://github.com/id3as/demo_ps>`_ and delete the bits you don't want. In time you'll learn what all the moving parts are when you need to make changes. The other solution is to just spend a bit of time reading, making notes and mapping what you read onto the code that exists in the demo project. 

For the purposes of this section we'll separate these various aspects into

* :doc:`Erlang <erlang>`: The various files needed to support a plain ol' Erlang Application
* :doc:`Purerl <purerl>`: The various files needed to support a server-side Purescript application
* :doc:`Purescript <purescript>`: The various files needed to support a client-side Purescript application


.. toctree::
   :hidden:
   :titlesonly:

   erlang
   purerl
   purescript


