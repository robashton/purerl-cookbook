Subscribing to messages
#######################

A typical pattern in Erlang would be to get hold of the current process, and initiate a subscription to messages that will then be sent to that pid.


.. code-block:: erlang

   Self = self()
   some_api:subscribe(Self),


An equivalent to this exists in *Erl.Process.Raw*

.. code-block:: haskell

   self :: Effect Pid

But as we can see, this Pid has no type information associated with it so we could be sending and receiving anything. This is useful in test suites (when we can just use type inference, wishes, and prayers to send messages about the place for assertion), but less useful in a production setting.

.. code-block:: haskell

   send :: forall a. Pid -> a -> Effect Unit

What we really need is a typed Process 

Getting hold of a Process Msg
=============================

In the latest package sets, a typeclass is defined so that within any monad that supports it we should be able to get hold of a Process Msg if one exists (as usually the type of Msg is encoded within that context).


.. code-block:: haskell

  class HasSelf (x :: Type -> Type) a | x -> a where
    self :: x (Process a)


This exists so that custom process types can be designed, but is implemented for all the common process types that already exist across Erl.Process, Erl.Pinto and Erl.Stetson.

Sending messages to a spawned process
=====================================

The simplest example is a spawned process via Erl.Process.spawnLink


.. code-block:: haskell

    import Erl.Process (spawnLink, ProcessM, self, send)
    import Pinto.Timer (sendEvery)

    -- Our message type
    data Msg
      = Tick
      | Stop

    main :: Effect Unit
    main = do
      -- note: pid is of type 'Process Msg'
      pid <- spawnLink startWorker  

      -- After 5 seconds, send a Stop message to the spawned pid
      sleep 5000
      send pid Stop

    startWorker :: ProcessM Msg Unit
    startWorker = do 

      -- note: me is of type 'Process Msg'
      me <- self 

      -- Ask for a Tick message to be sent every second
      sendEvery 1000 Tick me

      -- And enter the receive loop
      workerLoop 
    
    workerLoop :: ProcessM Msg Unit
    workerLoop = do
      -- msg is of type Msg
      msg <- receive 
      case msg of
        Stop -> pure unit -- unit because it's ProcessM msg result 
        Tick ->  do
          log "Tick"
          workerLoop

As can be seen, we're in the ProcessM monad which has two types assocated with it - the messages we expect to receive and the return result of the process (which is typically unit because it'll get discarded anyway!).

So long as we restrict ourselves to using the typed API that exists here, we will never receive a message that we don't expect and life is good.

Sending messages to a spawned GenServer
=======================================

The GenServer context is a bit heavier, most operations taking place inside a 'ResultT'

.. code-block:: haskell

   ResultT cont stop msg state result

The only relevant type parameter here is 'msg', and an implementation of HasSelf exists for this context that'll get you a *Process msg*

.. code-block:: haskell

  import Pinto.GenServer (InitFn, InfoFn, liftEffect)
  import Erl.Process (self, send)

  ...

  data Msg = Tick | SomethingElse

  init :: Gen.InitFn State Msg
  init = 
    me <- self
    liftEffect $ sendEvery 1000 Tick me
    pure $ InitOk {}

  handleInfo :: InfoFn Unit Unit Msg State
  handleInfo msg state = ....


Receiving messages in a Stetson WebSocket handler
==================================================

Stetson also implements HasSelf for websocket callbacks


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

----

The typical convention (at present) for anything wishing to send messages back to a calling process in Purerl, is not to send the message directly but to instead accept a callback and let the consumer choose how to consume those messages.


.. code-block:: haskell

  -- We could just pass in a process to send messages to
   subscribe :: Config -> Process Msg -> Effect Unit

   -- Or, we could pass in a callback, which allows the consumer to decide what to do
   subscribe :: Config -> (Msg -> Effect Unit) -> Effect Unit


Of course, whilst passing the Process Msg in is less flexible, it is also less error prone - consider a callback with an error in it which crashes the process it was passed to - care should be taken to handle these when designing APIs.

