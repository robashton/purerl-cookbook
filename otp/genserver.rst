OTP Gen server
===============

The workhorse of the OTP world, it's no surprise that the API for Pinto.Gen is one of the most involved of the APIs shown at this point.

The most basic Genserver is just a startLink taking in some arguments, calling the default *Gen.startLink* with an *init* callback and creating some state inside that callback when that gen server gets started.

.. literalinclude:: /demo-ps/server/src/EmptyGenServer.purs
  :language: haskell
  :linenos:
  :lines: 16-

Now this is a bit of a useless example, our start args are a record with no fields, our state is a record with no fields and there are no operations defined over this empty state.

Let's define a gen server that has some start args (an initial value), and a state (that value). How do we *do things* to that state once the process is started?

.. literalinclude:: /demo-ps/server/src/CounterExample.purs
  :language: haskell
  :linenos:
  :lines: 16-28

In Erlang there are two ways you would typically talk to a gen server specifially, `gen_server:cast <https://erlang.org/doc/man/gen_server.html#cast-2>`_ (send a message and don't wait for a response) and `gen_server:call <https://erlang.org/doc/man/gen_server.html#call-2>`_ (send a message and get something back).

This is quite a verbose process in Erlang as the message-send and the message-receive are written independently of each other despite often being identical. This can be useful when you're throwing versioned tuples around on a wing and a prayer but unless you're in the minority of circumstances where you're doing this to help with hotloading/upgrades it's quite a long winded way of 'calling a function within the context of my running gen server'.

In Pinto.Gen this is represented instead as a simple callback that can be expressed inline at the callsite. 

.. literalinclude:: /demo-ps/server/src/CounterExample.purs
  :language: haskell
  :linenos:
  :lines: 30-33

.. literalinclude:: /demo-ps/server/src/CounterExample.purs
  :language: haskell
  :linenos:
  :lines: 34-36

The return results and function signatures still map fairly cleanly onto the Erlang API so the documentation for Pinto and OTP don't need to diverge too much.
