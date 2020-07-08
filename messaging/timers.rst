Timers
######

Timers are a special case in Erlang, because they're leaned on so heavily there has always been effort to avoid spinning up processes all over the show for them. The module *timer* is implemented as a single process which processes all of the timer messages and maintains the references. That proved to be a bottleneck so we now have an even lower level timer implemention in the *erlang* module that avoids even that.

This is a long winded way of saying that the proxy processes that are used to perform message redirection/emitting are not desirable in Purerl, instead the API takes a *Process msg* to send the messages to, and a pre-built *msg* to send when the timer is fired. This means we don't incur any extra overhead by virtue of being in Purerl.

Note: Timer.sendEvery uses the old *timer:send_every* implementation and Timer.sendAfter uses the new *erlang:send_after* code, this is an implementation detail but is worth pointing out in case it causes confusion.

.. code-block:: haskell

  data Msg = Tick

  init :: Gen.Init State Msg
  unit = do
    self <- Gen.self
    Gen.lift $ Timer.sendAfter 500 Tick self
    pure {}
    
  handleInfo :: Msg -> State -> Gen.HandleInfo State Msg
  handleInfo msg state = ...


Or

.. code-block:: haskell

  data Msg = Tick

  init :: Gen.Init State Msg
  unit = do
    self <- Gen.self
    Gen.lift $ Timer.sendEvery 500 Tick self
    pure {}
    
  handleInfo :: Msg -> State -> Gen.HandleInfo State Msg
  handleInfo msg state = ...


Because we're using *Process msg*, this will also work inside any kind of Process as well as Stetson handlers, our below example spinning off a looping child process which will receive a Tick message every 500ms.

.. code-block:: haskell

  data ChildMsg = Tick

  childProcess :: SpawnedProcessState ChildMsg -> Effect Unit
  childProcess s@{ receive } = do
    msg <- receive
    case msg of
      Tick -> -- do something
        childProcess s

  init :: Gen.Init Msg State
  init = do
    child <- Gen.lift $ Process.spawnLink childProcess
    Timer.sendEvery 500 Tick child
    pure { child }


