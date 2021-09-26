Timers
######

Timers are a special case in Erlang itself, because they're leaned on so heavily there has always been effort to avoid spinning up processes all over the show for them. The module *timer* was implemented as a single process which processed all of the timer messages and maintains the references. That proved to be a bottleneck so we now have an even lower level timer implemention in the *erlang* module that avoids even that.

This is a long winded way of saying that the proxy processes that are used to perform message redirection/emitting from Pinto.MessageRouter are not desirable for this use case, instead the API takes a *Process msg* to send the messages to, and a pre-built *msg* to send when the timer is fired. This means we don't incur any extra overhead by virtue of being in Purerl.

Note: Timer.sendEvery uses the old *timer:send_every* implementation and Timer.sendAfter uses the new *erlang:send_after* code, this is an implementation detail but is worth pointing out in case it causes confusion.

.. code-block:: haskell

  data Msg = Tick

  init :: InitFn Unit Unit Msg State
  unit = do
    self <- self
    liftEffect $ Timer.sendAfter 500 Tick self
    pure $ InitOk {}
    
  handleInfo :: InfoFn Unit Unit Msg State
  handleInfo msg state = ...


Or

.. code-block:: haskell

  data Msg = Tick

  init :: InitFn Unit Unit Msg State
  unit = do
    self <- Gen.self
    Gen.lift $ Timer.sendEvery 500 Tick self
    pure $ InitOk {}
    
  handleInfo :: InfoFn Unit Unit Msg State
  handleInfo msg state = ...


Timers operate on anything that implement *HasProcess msg*, thus we can invoke them targetted at GenServer, ProcessM, Loop handlers, etc etc..

.. code-block:: haskell

  data ChildMsg  
    = Tick
    | Exit

  childProcess :: ProcessM ChildMsg Unit
  childProcess = do
    msg <- receive
    case msg of
      Tick -> 
        childProcess
      Exit -> pure unit

  init :: InitFn Unit Unit Msg State
  init = do
    child <- liftEffect $ Process.spawnLink childProcess
    Timer.sendEvery 500 Tick child
    pure $ InitOk { child }

