Process (spawn_link)
####################

Using gen servers for absolutely everything is very much overkill, quite often we just want to spin up a child process via *spawn* or *spawn_link*, and then communicate with it by sending it messages directly. This can be useful when performing longer tasks as part of a gen server for example but not wanting to block the execution of that gen server

We'll build up that as the example here because it's such a common pattern. 


Spinning up a child process
===========================

The bare minimum to spin up a child process is

* Define the type of message it will expect to receive
* Define a function that will receive *(SpawnedProcessState msg)* and return *Effect Unit*

.. code-block:: haskell

  data ChildMsg = Tick

  childProcess :: SpawnedProcessState ChildMsg -> Effect Unit
  childProcess s = pure unit

  init :: Gen.Init Msg State
  init = do
    _ <- Gen.lift $ Process.spawnLink childProcess
    pure {}

Now in this example, the process will start up and then immediately terminate because we don't do anything in the function invoked as part  of spawnLink - we did say the bare minimum required..

We can change this to wait for a message indefinitely and *then* exit by using the functions given to us in SpawnedProcessState

.. code-block:: haskell

  data ChildMsg = Tick

  childProcess :: SpawnedProcessState ChildMsg -> Effect Unit
  childProcess s@{ receive } = do
    msg <- receive
    case msg of
      Tick -> pure unit

  init :: Gen.Init Msg State
  init = do
    _ <- Gen.lift $ Process.spawnLink childProcess
    pure {}


Or indeed, wait for a message and then loop and wait for a message again


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
    _ <- Gen.lift $ Process.spawnLink childProcess
    pure {}

So how we do we send this newly awakened process a message? We're presently discarding the result of spawnLink - which is of type *Process ChildMsg*, so we'll want that obviously.

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
    child ! Tick
    pure { child }


Next up we'll probably want to get a message back from our long running process, to do that we'll want to pass the *childProcess* a reference to ourself so it can do that. Rather than trying to separate our datatypes with emitters, it's easiest to just give it a *Process Msg*, wheree Msg is our Gen server's msg type. Typically in this sort of setup the code is tightly coupled anyway because we're just trying to orchestrate a long running process within the same module and setting up layers of indirection isn't helpful when trying to re-read the code later.


.. code-block:: haskell

  data ChildMsg = Tick
  data Msg = Response

  childProcess :: Process Msg -> SpawnedProcessState ChildMsg -> Effect Unit
  childProcess parent s@{ receive } = do
    msg <- receive
    case msg of
      Tick -> 
        parent ! Response
        childProcess parent s

  init :: Gen.Init Msg State
  init = do
    self <- Gen.self
    child <- Gen.lift $ Process.spawnLink $ childProcess self
    child ! Tick
    pure { child }

  handleInfo :: Msg -> State -> Gen.HandleInfo State Msg
  handleInfo msg state =
    case msg of 
      Response -> ...

And voila, we have an arbitrary process spun up via spawnLink capable of being sent messages and sending messages back to its parent. All typed, all safe and remarkably compact.


