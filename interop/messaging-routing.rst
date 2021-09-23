Message Routing
###############

The package `erl-pinto <https://github.com/id3as/purescript-erl-pinto>`_ contains a module (Pinto.MessageRouter) whose job it is is to perform the subscription on your behalf and then translate any messages using a provided function.

Practically any legacy API with a '*start*' and '*stop*' of some sort (subscribe/unsubscribe) can be shuffled behind a message router and that will convert the messages and pass them into the appropriate emitter.

*Note: The message router will automatically terminate when its parent terminates and also call the stop method it was provided with when that happens.*

Using the example on the original messaging page, if we wished to use that legacy API as written, we could invoke it behind a message router inside a gen server or similar like so

.. code-block:: haskell

   import Pinto.MessageRouter as MR
   import LegacyApi as LegacyApi
   import Pinto.GenServer (InitFn)
   import Erl.Process (self, send)

   data Msg 
    = SomeMessage 
    | LegacyMessage LegacyApi.Msg

   init :: InitFn Unit Unit Msg State
   init = do
     me <- self
     MR.startRouter LegacyApi.start LegacyApi.stop (send me <<< LegacyMessage <<< LegacyApi.interpretForeign)


In this, we start up a router - letting it know about the start/stop methods of the LegacyApi and in the callback

- calling interpretForeign on the Foreign tht was received
- lifting it into the Msg type with the LegacyMessage constructor
- send it to the parent process

Thus enabling us to receive messages from more than one source, but lifted into the correct types

.. code-block:: haskell

   handleInfo msg state = 
    case msg of 
      SomeMessage -> handleSomeMessage state
      LegacyMessage msg -> handleLegacyMessage msg state

An equivalent method **MR.maybeStartRouter** exists for cases where an instance of our legacy code may fail. 

A note worth making is that this incurs the "cost" of an additional process so shouldn't be used in excessively performance oriented code - in that case we'd be better off 

- accepting the foreign messages directly 
- Simply writing code in Erlang to do the lifting
- Using `Untagged Unions <messaging-untagged>` to make our purescript aware of the incoming types in the first place




