Monitors
#########

Pids and processes
==================

One of the most useful concepts in erlang is the `monitor <https://erlang.org/doc/man/erlang.html#monitor-2>`_. Monitoring a pid means we get sent a message if that pid is non-existent, or when it otherwise terminates.

Obviously a direct FFI to *erlang:monitor* won't work in most processes, as it'll result in native Erlang tuples being sent directly to our Purerl where it'll immediately fail to match our expected message types.

Pinto has a wrapper for monitors that works around this by routing the messages through an emitter.

.. code-block:: haskell

  data Msg = 
    ProcessDown MonitorMsg

  self <- self
  Monitor.monitor pid $ send self <<< ProcessDown


MonitorMsg has quite an involved type because it holds all the information that an Erlang monitor would give us. 

.. code-block:: haskell

  data MonitorMsg
    = Down (MR.RouterRef MonitorRef) MonitorType MonitorObject MonitorInfo


It's quite common to disregard this message entirely as we can bundle the information that we actually need into our message at the time of subscription.

.. code-block:: haskell

  data Msg = 
    ProcessDown Pid

  self <- Gen.self
  Monitor.monitor pid (\_ -> self ! ProcessDown pid)


Gen servers
===========

A running GenServer has a pid that you can get hold of if you started it with startLink yourself which is precisely *not* how one would usually start a GenServer.

A convenience method exists therefore for getting hold of the typed process of an already-running gen server, so long as you have access to the name of that gen server (typically exported from the module implementing the gen server).

.. code-block:: haskell

  data Msg = 
    ProcessDown Pid

  self <- self
  maybePid <- liftEffect $ GenServer.whereIs MyCoolGenServer.serverName
  case maybePid of 
    Just pid -> do
      void $ liftEffect $ Monitor.monitor pid (\_ -> send self DataSourceDied)
      pure unit 
    _ -> do
      liftEffect $ send self DataSourceAlreadyDown
      pure unit




