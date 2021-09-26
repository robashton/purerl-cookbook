Process (spawn_link)
####################

Using gen servers for absolutely everything is very much overkill, quite often we just want to spin up a child process via *spawn* or *spawn_link*, and then communicate with it by sending it messages directly. This can be useful when performing longer tasks as part of a gen server for example but not wanting to block the execution of that gen server

We'll build up that as the example here because it's such a common pattern. 

Spinning up a child process
===========================

The bare minimum to spin up a child process is

* Define the type of message it will expect to receive
* Define a function that will operate within the context of the newly spawned child process (the ProcessM Monad)

.. code-block:: haskell

  data ChildMsg = Tick

  childProcess :: ProcessM ChildMsg Unit
  childProcess = pure unit

  init :: Effect Unit
  init = do
    _ <- Process.spawnLink childProcess

Now in this example, the process will start up and then immediately terminate because we don't do anything in the function invoked as part  of spawnLink - we did say the bare minimum required..

We can change this to wait for a message indefinitely and *then* exit by using the functions given to us in the ProcessM context.

.. code-block:: haskell

  data ChildMsg = Tick

  childProcess :: ProcessM ChildMsg Unit
  childProcess = do 
    msg <- receive
    case msg of
      Tick -> pure unit

  init :: Effect Unit
  init = do
    _ <- Process.spawnLink childProcess


Or indeed, wait for a message and then loop and wait for a message again


.. code-block:: haskell

  data ChildMsg 
    = Tick
    | Exit

  childProcess :: ProcessM ChildMsg Unit
  childProcess = do
    msg <- receive
    case msg of
      Tick -> do
        log "tick"
        childProcess 
      Exit -> pure unit

  init :: Effect Unit
  init = do
    _ <- Process.spawnLink childProcess


Note: an Exit value was added in this example, as *some* branch of the function *has* to return the expected type (unit), or the compiler will get upset.

So how we do we send this newly awakened process a message? We're presently discarding the result of spawnLink - which is of type *Process ChildMsg*, so we'll want that obviously.

.. code-block:: haskell

  data ChildMsg 
    = Tick
    | Exit

  childProcess :: ProcessM ChildMsg Unit
  childProcess = do
    msg <- receive
    case msg of
      Tick -> do
        log "tick"
        childProcess 
      Exit -> pure unit

  init :: Effect Unit
  init = do
    child <- Process.spawnLink childProcess
    child ! Tick


Next up we'll probably want to get a message back from our long running process, to do that we'll probably want to pass it a pid or a process - so let's move into the context of a GenServer and spin up a child process from there.

.. code-block:: haskell

  data ChildMsg 
    = Tick
    | Exit

  data Msg 
    = Response

  childProcess :: Process Msg -> ProcessM ChildMsg Unit
  childProcess parent = do
    msg <- receive
    case msg of
      Tick -> do
        parent ! Response
        childProcess parent
      Exit -> pure unit

  init :: InitFn Unit Unit Msg {}
  init = do
    self <- self
    child <- Process.spawnLink $ childProcess self
    child ! Tick

  handleInfo :: InfoFn Unit Unit Msg State
  handleInfo msg state =
    case msg of 
      Response -> ...

And voila, now we have a gen server that starts a child process that when sent a 'Tick' message, responds to use with a 'Response' message and it's all type safe thanks to the wonders of Purescript.

