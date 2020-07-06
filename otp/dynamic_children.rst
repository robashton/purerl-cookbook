Dynamic Supervision Trees
=========================

It is obviously possible to start and stop children on a supervisor by calling the appropriate functions and passing in the specification of the child involved, a supersor has a *serverName* with which it was started and we just use that when calling the Gen.Sup API.

.. code-block:: haskell

  -- Stop and delete a child by name
  Sup.terminateChild serverName "my_child_name"
  Sup.deleteChild serverName "my_child_name"

  -- Start the child with a spec
  Sup.startSpeccedChild serverName (buildChild
                                    # childType Worker
                                    # childId "my_child_name"
                                    # childStart SomeGenServer.startLink {}
                                   )

This uses the same specification types as when :doc:`building a supervision tree <supervisor>` so shouldn't look too unfamiliar.

simple_one_for_one
******************

A special case for supervisors in OTP is *simple_one_for_one*, where the whole supervision tree is set up for the benefit of a single type of child which gets defined by a template up front and gets 'completed' by the *start_child* call on the supervisor. 

This *at the moment* is still a little bit handwavey as far as types go (the plan is to make something more Pinto/Purescript specific once it becomes a pain point for somebody), the Purerl API at present maps almost entirely onto the Erlang/OTP API.

First we define a supervision tree that uses a a child template to set up everything except the arguments for a child:

.. literalinclude:: /demo-ps/server/src/OneForOneSup.purs
  :language: haskell
  :linenos:
  :lines: 17-38


*childTemplate* has been defined in a function so we can use it in a specific API provided by Pinto for starting this type of child:

.. literalinclude::  /demo-ps/server/src/OneForOneSup.purs
  :language: haskell
  :linenos:
  :lines: 40-

This API is subject to change, as it's not very good but it'll do for now.
