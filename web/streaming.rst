Stetson Streaming
###################

A reasonably common pattern for streaming data to the client is to subscribe to a bus/process of some sort and then send that data to the client as it comes in. The handler for that in Cowboy is `cowboy_loop <https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_loop/>`_ for which there is the equivalent module `Stetson.Loop <https://pursuit.purerl.fun/packages/erl-stetson/docs/Stetson.Loop>`_

Loop from the onset
*******************

Again there is an entry point specifically for kicking off a Loop handler and callbacks for handling messages sent to the handler, we have

* *Loop.handler* which is where we set up our initial state and start a streamed reply
* *Loop.init* which is called immediately after with additional context (Loop.self now possible)
* *Loop.info* for handling messages that we receive to our process

.. code-block:: haskell

  data DataStreamMessage = Data Binary
                                             
  dataStream :: StetsonHandler DataStreamMessage Unit
  dataStream = Loop.handler (\req -> do
                 req2 <- streamReply (StatusCode 200) Map.empty req
                 Loop.initResult req2 unit)

      # Loop.init (\req state -> do 
                        self <- Loop.self
                        void $ Loop.lift $  MonitorExample.registerClient $ send self <<< Data
                        pure state)

      # Loop.info (\msg req state ->  do
                  case msg of
                       Data binary -> do
                          _ <- Loop.lift $ streamBody binary req
                          pure $ LoopOk req state
                   )


This is a simplified version of the code in demo_ps repo which also attaches a monitor to the remote process so the connection can be closed in case the data source goes missing.

Switch to Loop from Rest
************************

A common use-case across our codebases for streaming handlers, is to use the Rest handler to negotiate a sensible response based on stream availability, validation of the request, authorization, etc. This is possible in Stetson at any point but the most common place to perform this conversion is in the accept callback for returning the data.


.. code-block:: haskell

  data EventsWsMsg = BookMsg BookEvent

  eventsFirehoseRest :: StetsonHandler EventsWsMsg Unit
  eventsFirehoseRest =
    emptyHandler (\req -> Rest.initResult req unit)
      # Rest.allowedMethods (\req state -> Rest.result (Stetson.HEAD : Stetson.GET : Stetson.OPTIONS : nil) req state)
      # Rest.contentTypesProvided (\req state -> Rest.result (streamEvents : nil) req state)
      # Loop.init (\req state -> do
                                self <- Loop.self
                                _ <- Loop.lift $ SimpleBus.subscribe BookLibrary.bus $ BookMsg >>> send self
                                pure state)
      # Loop.info (\(BookMsg msg) req state ->  do
            _ <- Loop.lift $ streamBody (stringToBinary $ writeJSON msg) req
            pure $ LoopOk req state)
      where 
            streamEvents = tuple2 "application/json" (\req state -> do
                           req2 <- streamReply (StatusCode 200) Map.empty req
                           Rest.switchHandler LoopHandler req2 state)


This is a simplified version of the code in the demo_ps project, but essentially we do some work with Rest handler, setting up an accept for *application/json*, which when invoked in *streamEvents* switches  to the LoopHandler by calling *Rest.switchHandler*. It is at *this* point that *Loop.init* will be invoked and then its just a plain ol' LoopHandler from that point on.
