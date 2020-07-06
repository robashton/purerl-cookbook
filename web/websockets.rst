Stetson Websockets
###################

One of the "coolest" things we can do with Stetson in Purerl and a suitable client written in Purescript is use websockets to send *typed* messages back and forth without too much ceremony.

The handler for this in Cowboy is `cowboy_websocket <https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_websocket/>`_ for which there is the equivalent module `Stetson.Websocket <https://pursuit.purerl.fun/packages/erl-stetson/docs/Stetson.WebSocket>`_.

The first thing we need to do is setup the handler by specifying some sort of message type and our state (in this case, just 'unit'). We'll use *Websocket.handler* to kick off the configuration of the web socket and otherwise leave the request object alone and return an empty state.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 151-160

init
****

The Websocket handler only needs a few callbacks defined, *init*, which will be called straight away on startup - this is a good place to subscribe to messages - and our typed *Process msg* can be retrieved for this purpose with a call to *Websocket.self*. Most event emitters will ask for a callback of *(msg -> Effect Unit)* so the usual pattern to get one of these is simply to invoke *Process.send* and compose that with the appropriate contructor.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 164-172

handle
******

We then have *handle* for messages set to us by the client (given to us as a Frame (binary, text, ping, etc) and we can easily parse json into our model at this point if we receive a text message, or process the binary etc.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 175

info
******

Finally we have *info* into which messages sent to our process from elsewhere in Erlang will be received so we can proxy them down to our client in the form of the Frame type (binary, text, ping, etc).


.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 178

With the use of messages that can easily be serialised/deserialised to/from JSON defined in a shared folder, the client and server can very easily communicate with a stream of back and forth messages. 
