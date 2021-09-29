Stetson Websockets
###################

One of the "coolest" things we can do with Stetson in Purerl and a suitable client written in Purescript is use websockets to send *typed* messages back and forth without too much ceremony.

The handler for this in Cowboy is `cowboy_websocket <https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_websocket/>`_ for which there is the equivalent module `Stetson.Websocket <https://pursuit.purerl.fun/packages/erl-stetson/docs/Stetson.WebSocket>`_.

The first thing we need to do is setup the handler by specifying some sort of message type and our state type (in this case, just 'unit'). 

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 173-180

init
****

At this point in time, this handler is still just a plain old Cowboy handler and we need to signal to Cowboy that we'd like it to start invoking the callbacks for Websockets (Also, it kicks this off in another process so messags can safely be sent to it).

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 183-183

wsInit
******

Once we've informed Cowboy that this is to be a Websocket handler, it'll invoke our wsInit (*websocket_init*) in the correct process, so this is the time to subscribe to any messages we might want to forward down to the client.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 187-192

wsHandle
********

We then have wsHandle for messages set to us by the client (*websocket_handle*) given to us as a Frame (binary, text, ping, etc) and we can easily parse json into our model at this point if we receive a text message, or process the binary etc.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 195

wsInfo
******

Finally we have *info* into which messages sent to our process from elsewhere in Erlang will be received so we can proxy them down to our client in the form of the Frame type (binary, text, ping, etc).


.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 198

With the use of messages that can easily be serialised/deserialised to/from JSON defined in a shared folder, the client and server can very easily communicate with a stream of back and forth typed messages.
