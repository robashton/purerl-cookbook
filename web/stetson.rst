Stetson
#######

The primary Stetson entry point is *Stetson.configure* which returns a builder for configuring away the default values, at the most basic a web server with no routes would look like this:

.. code-block:: haskell

  Stetson.configure
    # Stetson.port 8080
    # Stetson.bindTo 0 0 0 0
    # Stetson.startClear "http_listener"

The final step is to *startClear* (or other start methods), which with a name kicks off the server  which will listen on all interfaces on port 8080 (and return 404 because nothing has been setup to listen to anything).

Very much like with Pinto, these options have as much as possible been taken 1-1 from the underlying library (Cowboy) so the documentation can be followed on the Cowboy docs.

* `StetsonConfig <https://pursuit.purerl.fun/packages/erl-stetson/0.0.7/docs/Stetson#t:StetsonConfig>`_
* `TCP options (ranch_tcp) <https://ninenines.eu/docs/en/ranch/1.7/manual/ranch_tcp>`_
* `HTTP options (cowboy_http) <https://ninenines.eu/docs/en/cowboy/2.8/manual/cowboy_http/>`_

It's all reasonably discoverable (the advantage of typed records in Purerl over grab-bag maps in Erlang (specced or otherwise), if anything is missing feel free to file an issue against Stetson (or even a pull request) - a lot of this functionality has been written very much on an on-demand basis.
