OTP Supervisor
===============

Typically, the application in the entry point will kick off a single supervision tree that will contain other supervision trees as well as various worker processes (typically gen servers but absolutely not strictly so).

A supervisor has a name (because we might want to interact with it programatically once it has started), and typically exposes a function *startLink* that will call *Sup.StartLink* passing in a callback to an 'init' function that'll be invoked by OTP within the context of supervision process in order to get the children that need starting as part of this supervision tree.

.. literalinclude:: /demo-ps/server/src/BookSup.purs
  :language: haskell
  :linenos:
  :lines: 21-23

At the heart of it, a supervision tree is just a list of children that will be spun up by the supervisor, and instructions on what to do when thos children crash. There are quite a few options available for configuring this so in Pinto builders are provided for this purpose, which are kicked off by *Pinto.Sup.buildSupervisor* for the overall supervision tree and *Pinto.Sup.buildChild*. It's worth looking up these types and functions in Pursuit as it becomes a matter of going "I am building a child, what options do I have available for that". Most of the options map directly onto their OTP equivalents so the existing Erlang documentation remains valid.

.. literalinclude:: /demo-ps/server/src/BookSup.purs
  :language: haskell
  :linenos:
  :lines: 25-

In this code, we are building a supervision tree and returning it to OTP so it knows what to do. All of startLinks with their arguments are type checked (unlike in straight Erlang) but other than that, there are very few differences between this code and what you would expect to see in the Erlang documentation. This is intentional because it saves us re-writing the Erlang documentation.



