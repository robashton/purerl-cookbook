Message Bus
###########

A convenient method of sending messages to other processes is via a message bus; one can be contructed quite easily using `gproc <https://github.com/uwiger/gproc>`_ in Erlang and for ease a package `erl-simplebus <https://github.com/id3as/purescript-erl-simplebus>`_ does just that.


Defining a bus
==============

A bus is just a 'name' with a phantom type associated with it onto which messages of that type can be placed and received by multiple listeners


.. code-block:: haskell

  data BusMessage = StreamStarted String
                  | Data Binary
                  | Eof 

  bus :: SimpleBus.Bus String BusMessage
  bus = SimpleBus.bus "file_reading_bus"

  
In the above example, we define a bus called  *file_reading_bus*, which will be capable of distributing messages of *BusMessage*, The convention is that a module wishing to expose a bus will just export it via its module definition. By keeping the constructor for the ADT private, only the owner of the bus will be able to place messages on it.


.. code-block:: haskell
  
  module StreamReader ( bus
                      , BusMessage
                      ) where


To place a message onto the bus, the module that 'owns' the bus need only call *send*, passing in the bus involved and a constructed message.


.. code-block:: haskell

  _ <- SimpleBus.send bus $ StreamStarted "stargate.ts"
  _ <- SimpleBus.send bus Eof


Subscribing to a bus
====================

From another process or module, we only need call *subscribe*, passing in the bus and a callback to receive the messages. In a Genserver, this would look like this

.. code-block:: haskell

  data Msg = Tick
           | DoSomething String
           | StreamMessage StreamReader.BusMessage

  init :: InitFn Unit Unit Msg State
  init = do
    self <- self
    _ <- liftEffect $ SimpleBus.subscribe StreamReader.bus $ send self <<<  StreamMessage
    pure $ InitOk {}

  handleInfo :: InfoFn Unit Unit Msg State
  handleInfo msg state = do
    case msg of
      Tick  -> 
        handleTick state
      DoSomething what  -> 
        handleSomething what state
      ReaderMessage msg  -> 
        handleReaderMessage msg state

We can see clearly here the pattern of lifting an external module's message into our own type so we can handle it in our *handleInfo* dispatch loop. 

Unsubscribing from a bus
========================

It's actually rare that we'll ever unsubscribe from a bus; most of the time we'll subscribe on a process startup and then allow the subscription to be automatically cleaned up on process termination.

However, it's worth pointing out that *SimpleBus.subscribe* actually returns a reference of type *SubscriptionRef* which we can stash in our process state for use later on.

.. code-block:: haskell

  init :: InitFn Unit Unit Msg State
  init = do
    self <- self
    busRef <- liftEffect $ SimpleBus.subscribe StreamReader.bus $ send self <<< StreamMessage
    pure $ InitOk { busRef: Just busRef }


  unsubscribe :: State -> Effect State
  unsubscribe s@{ busRef: Nothing } = pure s
  unsubscribe s@( busRef: Just ref } = do
    void SimpleBus.unsubscribe ref
    pure s { busRef = Nothing }

When to use a bus
=================

A bus is an extremely lazy way of sending messages about the place and care must be taken not to overuse them in complicated orchestration scenarios. In general they're *really* good for distributing *events* to multiple subscribers to let them know something has already happened and not *commands* that tell things to happen.
