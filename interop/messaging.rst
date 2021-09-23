Messaging
#########

Another chapter called "messaging", because this *is* Erlang after all.

It is very common for legacy APIs to send arbitary messages back to the invoking process, convenient, useful, handy... not practical in Purescript however. 

Consider the following code, where in Erlang we subscribe to some API that immediately starts sending us some sort of erlang tuple/record.

.. code-block:: erlang

  %% Subscribe to the legacy API
  { ok, Ref } = legacy_api:start()

  %% And start receiving messages from it
  receive 
    #legacy_message{} ->  ... ... ... ...
      

If we were to write a straight wrapper for this API in Purescript, it'd look very simple indeed

First, the purescript foreign import, which merely invokes the function and returns the ref

.. code-block:: haskell

  module LegacyApi where

  foreign import start :: Effect Handle


Which, in the Erlang is unpacked as thus

.. code-block:: erlang

  -module(legacyApi@foreign).
  
  start() ->
    fun() ->
       { ok, Ref } = legacy_api:start(),
       Ref
    end
  end.
  
Now we have a problem - if we try and use this in Purescript, our message receiving code has to operate on the Foreign data type because it has no idea what an Erlang record is. 

A further call into the LegacyApi wrapper could unpack this of course so this doesn't present an immediate problem.

.. code-block:: haskell

  do 
    _subscription <- LegacyApi.start

    msg :: Foreign <- receive

    case LegacyApi.interpretForeign msg of 
      LegacyApi.ThisHappened -> ....
    


This *might* be okay, but it means if we want to receive any other kind of message we are out of luck unless we pack *them* into Foreign as well, and ask various mappers to attempt to unpack these foreigns in sequence until one works and oh boy this is not enjoyable in the slightest.

The choices
***********

It'd be nice to be able to unpack these Foreigns into sensible types, and to do this we have the following options

* :doc:`Routing <messaging-routing>` - intercept the messages with a proxy process and lift them into more appropriate types before sending them to the owning process
* :doc:`Untagged Unions <messaging-untagged>` - describe the messages with an ADT and have them matched inline into more appropriate types

Most of the time you'll want Routing as processes are cheap and this is easy, but if writing a wrapper around a native Erlang library, untagged unions might be more useful.

