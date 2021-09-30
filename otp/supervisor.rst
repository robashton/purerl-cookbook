OTP Supervisor
===============

Typically, the application in the entry point will kick off a single supervision tree that will contain other supervision trees as well as various worker processes (typically gen servers but absolutely not strictly so).

A supervisor has a name (because we might want to interact with it programatically once it has started), and typically exposes a function *startLink* that will call *Supervisor.StartLink* passing in a callback to an 'init' function that'll be invoked by OTP within the context of supervision process in order to get the children that need starting as part of this supervision tree.

.. literalinclude:: /demo-ps/server/src/BookSup.purs
  :language: haskell
  :linenos:
  :lines: 22-24

At the heart of it, a supervision tree is just a list of children that will be spun up by the supervisor, and instructions (flags) on what to do when those children crash. The names of everything in this specification map onto the names in the underlying erlang API so for the most part no explicit documentation is required from it.

.. literalinclude:: /demo-ps/server/src/BookSup.purs
  :language: haskell
  :linenos:
  :lines: 26-48

That worker function just contains the defaults for our specific supervisor:

.. literalinclude:: /demo-ps/server/src/BookSup.purs
  :language: haskell
  :linenos:
  :lines: 53-64
   
So we can see in this code we simply return the flags for this tree and a list of children that need starting. Each of those children is just an (Effect childPid) and with this mechanism, it means that the arguments for each child are type checked (unlike in straight Erlang). 
