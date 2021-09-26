Dynamic Supervision Trees
=========================

It is obviously possible to start and stop children on a normal supervisor by calling the appropriate functions and passing in the specification of the child involved, a supervisor has a *serverName* with which it was started and we just use that when calling the API against it. With a typical Supervisor the interaction is as follows.. (The behaviour of these functions mapping exactly onto the actual OTP documentation).

.. code-block:: haskell

  import Pinto.Sup as Sup

  main :: Effect Unit
  main = do
    -- Start the child with a spec
    Sup.startChild serverName $ Sup.spec
      { "my_child_name"
      , childType: Worker
      , start: MyGenServer.startLink {}
      , restartStrategy: RestartTransient
      , shutdownStrategy: ShutdownTimeout 5000
      }

    -- Stop and delete a child by id
    Sup.terminateChild serverName "my_child_name"
    Sup.deleteChild serverName "my_child_name"

This uses the same specification types as when :doc:`building a supervision tree <supervisor>` so shouldn't look too unfamiliar.

simple_one_for_one
******************

A special case for supervisors in OTP is *simple_one_for_one*, where the whole supervision tree is set up for the benefit of a single type of child which gets defined by a template up front and gets 'completed' by the *start_child* call on the supervisor. 

For this purpose, a separate module exists with a slightly different API under Pinto.Sup.Dynamic.

First we define a supervision tree that uses a a child template to set up everything except the arguments for a child:

.. literalinclude:: /demo-ps/server/src/OneForOneSup.purs
  :language: haskell
  :linenos:
  :lines: 11-29

The reader will note that the server name of a *dynamic* supervisor actually contains the types needed for the child to be started (the running pid of the child and the arguments the child expects). This allows us to then export an API for our supervisor to start children in that supervisor

.. literalinclude:: /demo-ps/server/src/OneForOneSup.purs
  :language: haskell
  :linenos:
  :lines: 31-33

The API for terminating/stopping these children is slightly different, as rather than take an ID, the functions take the pid of the started child (just as in Erlang itself).

.. code-block:: haskell

  import Pinto.Sup.Dynamic as Sup

    -- Stop and delete a child by pid
    Sup.terminateChild serverName pid
    Sup.deleteChild serverName pid


By having this separate module for that special case of simple_one_for_one, we 

- We enforce the use of the correct arguments for startLink on the child
- We enforce that children started have the correct/unified message types
- Get rid of the need for the specific errors that arise when calling the delete/terminate methods with the wrong arguments
