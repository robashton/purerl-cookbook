OTP Gen servers
===============

The workhorse of the OTP world, it's no surprise that the API for Pinto.GenServer is one of the most involved of the APIs shown at this point.

The most basic Genserver is just a startLink taking in some arguments, calling the default *GenServer.startLink* with a 'spec' containing the init callback and optional callbacks for things like handle_info/terminate/etc. 

That init callback will be invoked by OTP and is responsible for setting up the initial state of the gen server (or failing).

.. literalinclude:: /demo-ps/server/src/EmptyGenServer.purs
  :language: haskell
  :linenos:
  :lines: 17-

Now this is a bit of a useless example, our start args are a record with no fields, our state is a record with no fields and there are no operations defined over this empty state.

There is a lot of 'Unit' in this empty code, GenServer.ServerType allows us to define the type of our 'continue', 'stop' and 'info' message types, as well as our state. Unit is the default for 'we're not using those things' and you would interchange for your own data types as you required additional functionality.

Let's define a gen server that has some start args (an initial value), and a state (that value). How do we *do things* to that state once the process is started?

.. literalinclude:: /demo-ps/server/src/CounterExample.purs
  :language: haskell
  :linenos:
  :lines: 12-26

In Erlang there are two ways you would typically talk to a gen server specifially, `gen_server:cast <https://erlang.org/doc/man/gen_server.html#cast-2>`_ (send a message and don't wait for a response) and `gen_server:call <https://erlang.org/doc/man/gen_server.html#call-2>`_ (send a message and get something back).

This is quite a verbose process in Erlang as the message-send and the message-receive are written independently of each other despite often being identical. This can be useful when you're throwing versioned tuples around on a wing and a prayer but unless you're in the minority of circumstances where you're doing this to help with hotloading/upgrades it's quite a long winded way of 'calling a function within the context of my running gen server'.

In Pinto.GenServer this is represented instead as a simple callback that can be expressed inline at the callsite. 

.. literalinclude:: /demo-ps/server/src/CounterExample.purs
  :language: haskell
  :linenos:
  :lines: 28-29

.. literalinclude:: /demo-ps/server/src/CounterExample.purs
  :language: haskell
  :linenos:
  :lines: 31-32

The return results and function signatures still map fairly cleanly onto the Erlang API so the documentation for Pinto and OTP don't need to diverge too much.


The monad
---------

When operating inside a gen server context, we're actually inside a ReaderT with a whole pile of phantom types enforcing the various messages that a gen server can receive/return. This doesn't need to be thought about in too much detail unless you're sending a pull request to Pinto itself, but in essence this means that a few things need to be beared in mind when writing code.


In order to invoke an effect inside a gen server, it will need to be lifted into the Reader monad with *liftEffect*

.. code-block:: haskell

  import Effect.Class (liftEffect)

  current :: Effect Int
  current = GenServer.call (ByName serverName) (\_from s ->  do
    liftEffect $ SomeApi.doSomethingCool
    pure $ GenServer.reply s.value s)


On the bright side, being sat in this monad means  getting hold of 'self' as a *Process Msg* is as simple as calling 'self' from the 'HasSelf' typeclass in Erl.Process.

.. code-block:: haskell

  import Erl.Process (self)

  current :: Effect Int
  current = GenServer.call (ByName serverName) (\_from s ->  do
    me <- self
    liftEffect $ SomeApi.playWithMe me
    pure $ GenServer.reply s.value s)


The callbacks
-------------

As mentioned, our call to startLink can optionally set up various callbacks. These are largely self explanatory if you already are familiar with Erlang and you can just follow the types. The goto example is probably handle_info for which there is a '`complete <https://github.com/robashton/demo-ps/blob/master/server/src/HandleInfoExample.purs>`_' example in the embedded repo for these docs.


