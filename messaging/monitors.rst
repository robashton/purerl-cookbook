Monitors
#########

Pids and processes
==================

One of the most useful concepts in erlang is the `monitor <https://erlang.org/doc/man/erlang.html#monitor-2>`_. Monitoring a pid means we get sent a message if that pid is non-existent, or when it otherwise terminates.

Obviously a direct FFI to *erlang:monitor* won't work in most processes, as it'll result in native Erlang tuples being sent directly to our Purerl where it'll immediately fail to match our expected types.

Pinto has a wrapper for monitors that works around this by routing the messages through an emitter.

.. code-block:: haskell

  data Msg = 
    ProcessDown Pinto.MonitorMsg

  self <- Gen.self
  Monitor.pid pid $ ProcessDown >>> send self


MonitorMsg has quite an involved type because it holds all the information that an Erlang monitor would give us. 

.. code-block:: haskell

  data MonitorMsg = Down (MR.RouterRef MonitorRef) MonitorType MonitorObject MonitorInfo


It's quite common to disregard this message entirely as we can bundle the information that we actually need into our message at the time of subscription.

.. code-block:: haskell

  data Msg = 
    ProcessDown Pid

  self <- Gen.self
  Monitor.pid pid (\_ -> self ! ProcessDown pid)

There is an equivalent to *Monitor.pid* for (Process msg), *Monitor.process* which works in exactly the same way and entirely disregards the *msg* type of the Process (Process msg is just a newtype for Pid anyway)

Gen servers
===========

Gen servers obviously have a pid and there is short-hand available for monitoring a gen server in Pinto, providing the serverName is exported from the gen server. Presently this takes two emitters, one for when the process goes down and one for when the process is already down. This may yet change to simply return a success value, this API has emerged as a result of mirroring the behaviour of the existing monitors and possibly isn't optimal.

.. code-block:: haskell

  data Msg = 
    ProcessDown Pid

  self <- Gen.self
  Gen.monitor ExternalGen.serverName (\_ -> self ! ProcessDown) (self ! ProcessAlreadyDown)



