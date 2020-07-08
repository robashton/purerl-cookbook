Messaging
#########

Another chapter called "messaging", because this *is* Erlang after all.

It is very common for legacy APIs to send arbitary messages back to the invoking process, convenient, useful, handy... not practical in Purescript however.

.. code-block:: erlang

  { ok, Ref } = legacy_api:start()

  %% and later on..
  handle_info(#legacy_message{}, State) -> ...

If we were to write a straight wrapper for this API in Purescript, it'd look very simple indeed

.. code-block:: haskell

  module LegacyApi where

  foreign import start :: Effect Handle

.. code-block:: erlang

  -module(legacyApi@foreign).
  
  start() ->
    fun() ->
       { ok, Ref } = legacy_api:start(),
       Ref
    end
  end.
  
However, now we have a problem - our message receiving code is effectively restricted to Foreign becuase we can't match against those erlang types.

.. code-block:: haskell

  init :: Gen.Init State Foreign
  init = do
    void $ Gen.lift LegacyApi.start
    pure {}

  handleInfo :: Foreign -> State -> Gen.HandleInfo State Foreign
  handleInfo msg = 
    case LegacyApi.interpretForeign msg of
      LegacyApi.ThisHappened -> ....

This *might* be okay, but it means if we want to receive any other kind of message we are out of luck unless we pack *them* into Foreign as well and start doing a dance around that.

It is for this purpose that **Pinto.MessageRouter** exists. Practically any legacy API with a '*start*' and '*stop*' of some sort can be shuffled behind a message router and that will convert the messages and pass them into the appropriate emitter.

.. code-block:: haskell

  module LegacyApi where

  import Pinto.MessageRouter as MR

  foreign import startImpl :: Effect Handle
  foreign import stopImpl :: Handle -> Effect Unit

  start :: (LegacyMessage -> Effect Unit) -> Effect (MR.RouterRef Handle)
  start emitter = do
    MR.startRouter startImpl stopImpl (\foreign -> emitter $ interpretForeign foreign)


  stop :: MR.RouterRef Handle -> Effect Unit
  stop = MR.stopRouter


An equivalent method **MR.maybeStartRouter** exists for cases where an instance of our legacy code may fail. 

This is then usable from Purescript code just like any other code that accepts an emitter

.. code-block:: haskell

  data Msg = Tick
           | LegacyMessage LegacyApi.Msg
          

  init :: Gen.Init State Msg
  init = do
    self <- Gen.emitter
    void $ Gen.lift $ LegacyApi.start $ LegacyMessage >>> send self
    pure {}

  handleInfo :: Msg -> State -> Gen.HandleInfo State Msg
  handleInfo msg = 
    case msg of
      LegacyMessage msg -> ....

A note worth making is that this incurs the "cost" of an additional process so shouldn't be used in excessively performance oriented code - in that case we'd be better off accepting the foreign messages directly or just writing code in Erlang (or using a single intermediate process in custom code). This works for most cases however.

The message router will automatically terminate when its parent terminates and also call the stop method it was provided with when that happens.



