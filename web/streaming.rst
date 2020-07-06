Stetson Streaming
###################

A reasonably common pattern for streaming data to the client is to subscribe to a bus/process of some sort and then send that data to the client as it comes in. The handler for that in Cowboy is `cowboy_loop <https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_loop/>`_ for which there is the equivalent module `Stetson.Loop <https://pursuit.purerl.fun/packages/erl-stetson/docs/Stetson.Loop>`_



