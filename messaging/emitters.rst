Emitters
########

The convention for anything wishing to send messages, is for a callback to be accepted of type *(msg -> Effect Unit)* into which messages will be passed, but how do we construct that callback usefully?

.. code-block:: haskell

  SomeModule.sendMeSomething  (\msg -> -- what


Most of the time, we are sat inside a process that has state of its own that we want to mutate based on this message, but in order to do that we need the callback to be invoked within the context of that process. 

Handily, most places we might want to receive a message provide the means of constructing these emitters in order to ensure messages that come in are of the right type.

Receiving messages in a Genserver
==================================================

Within any Genserver callback, we have access to *Gen.self*, which is of type *Process our_msg*, we can use this to route messages to our process.

.. code-block:: haskell

  init :: Gen.Init State Msg
  init = 
    self <- Gen.self
    SomeModule.sendMeSomething (\msg -> self ! SomeMessage msg)

  handleInfo :: Msg -> State -> Gen.HandleInfo State Msg
  handleInfo msg state = ....


The typical pattern however, is,

.. code-block:: haskell

  init :: Gen.Init State Msg
  init = 
    self <- Gen.self
    Gen.lift $ SomeModule.sendMeSomething $ SomeMessage >>> send self

  handleInfo :: Msg -> State -> Gen.HandleInfo State Msg
  handleInfo msg state = ....

Both of these result in passing an emitter of type *their_msg -> Effect Unit* into sendMeSomething.


Receiving messages in a Stetson WebSocket handler
==================================================

Within any WebSocket callback, we have access to *WebSocket.self*, which unsurprisingly is of type *Process our_msg*, we can use this to route messages to our handler


.. code-block:: haskell

  # WebSocket.init (\s ->  do
                              self <- WebSocket.self
                              Gen.lift $ SomeModule.sendMeSomething $ SomeMessage >>> send self

                              pure $ Stetson.NoReply s
                             )
  # WebSocket.info (\(SomeMessage msg) state -> ...

Receiving messages in a Stetson Loop handler
==================================================

And the same goes for the Loop handlers as well

.. code-block:: haskell

  # Loop.init (\s ->  do
                              self <- Loop.self
                              Gen.lift $ SomeModule.sendMeSomething $ SomeMessage >>> send self

                              pure $ Stetson.NoReply s
                             )
  # Loop.info (\(SomeMessage msg) state -> ...



In essence, anywhere we can get hold of Process msg, we can create an emitter that'll result in messages of the right type being sent to that process.

