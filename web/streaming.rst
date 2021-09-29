Stetson Streaming
###################

A reasonably common pattern for streaming data to the client is to subscribe to a bus/process of some sort and then send that data to the client as it comes in. The handler for that in Cowboy is `cowboy_loop <https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_loop/>`_ for which there is the equivalent module `Stetson.Loop <https://pursuit.purerl.fun/packages/erl-stetson/docs/Stetson.Loop>`_

Loop from the onset
*******************

Just like with WebSockets, the first step is to set up a handler with an appropriate message type, for the handler needs to receive messages to send down to the client in the form of some sort of data.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 253-259

Then, our init needs to send an initial response down to the client before signalling to Cowboy that we're to become a loop handler.

.. code-block:: haskell

  loopInit req state = do 
    self <- self
    void $ liftEffect $ DataSource.registerClient $ send self <<< Data
    pure state

And then all that's left to do is define the handler for dealing with the messages that come in.

.. code-block:: haskell

  loopInfo msg req state = do
    case msg of
      Data iodata -> do
        -- Then stream that down to the client
        void $ liftEffect $ streamBody iodata req
        pure $ LoopOk req state
      ...

This is a simplified version of the code in demo_ps repo which also attaches a monitor to the remote process so the connection can be closed in case the data source goes missing.

Switch to Loop from Rest
************************

A common pattern across our codebases for streaming handlers, is to use the Rest callbacks to negotiate a sensible response based on auth/availability/etc and then switch into a looping handler for actually sending the data.

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 202-210
 
We see here that our init kicks off the Rest workflow for which callbacks are also configured, but also there is a loopInit and loopInfo provided.

In our content callback, once we've negotiated the various REST callbacks, we can signal to Cowboy that we want to stream the data now

.. literalinclude:: /demo-ps/server/src/BookWeb.purs
  :language: haskell
  :linenos:
  :lines: 238-244

The full code for this can be found in the demo_ps repo.



