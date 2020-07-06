Web Server
##########

The de-facto web server in Erlang is `Cowboy <https://github.com/ninenines/cowboy>`_ for which a direct set of `bindings <https://github.com/purerl/purescript-erl-cowboy>`_ is available in the Purerl package sets along with `examples <https://github.com/nwolverson/purerl-ws-demo>`_ on how to `use them <https://github.com/nwolverson/pscowboytest>`_.

This is good practise, to build direct bindings that are true (where possible) to underlying Erlang libraries/APIs and then build nicely typed Purerl on top of that. Building a whole application using these bindings directly would be a bit burdensome and it is for this reason that I wrote `Stetson <https://github.com/id3as/purescript-erl-stetson>`_ which sits on top of Cowboy and exposes something a litle more Purerl specific.

Versioning is a case of 'check what we're linking to in the demo projects', which at the moment is Cowboy 2.8.

* :doc:`Stetson <stetson>`: Intro to configuring Stetson as a web server
* :doc:`Routing <routing>`: Building typed routes to fire off handlers
* :doc:`Rest <rest>`: Writing restful handlers
* :doc:`Web sockets <websockets>`: Writing Websocket handlers
* :doc:`Streaming <streaming>`: Writing streaming (loop) handlers

.. toctree::
   :hidden:
   :titlesonly:

   stetson
   routing
   rest
   websockets
   streaming


