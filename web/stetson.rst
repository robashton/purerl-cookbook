Stetson
#######

The primary Stetson entry point is *Stetson.configure* which returns a default configuration which can then be overriden using either the functions provided or by editing the record manually.

.. code-block:: haskell

  Stetson.configure
    # Stetson.port 8080
    # Stetson.bindTo 0 0 0 0
    # Stetson.startClear "http_listener"

Or

.. code-block:: haskell

  Stetson.startClear "http_listener"
    $ Stetson.configure { bindPort = 8080
                        , bindAddress = tuple4 0 0 0 0
                        }

Either method is comparable and down to preference and whether you wish to create erlang datatypes yourself.

The final step is to *startClear* (or other start methods such as startTls), which with a name kicks off the server with the configuration that was just built.

Very much like with Pinto, these options have as much as possible been taken 1-1 from the underlying library (Cowboy) so the documentation can be followed on the Cowboy docs rather than duplicated here with different terminology.

* `StetsonConfig <https://pursuit.purerl.fun/packages/erl-stetson/0.0.7/docs/Stetson#t:StetsonConfig>`_
* `TCP options (ranch_tcp) <https://ninenines.eu/docs/en/ranch/1.7/manual/ranch_tcp>`_
* `HTTP options (cowboy_http) <https://ninenines.eu/docs/en/cowboy/2.8/manual/cowboy_http/>`_

It's all reasonably discoverable (the advantage of typed records in Purerl over grab-bag maps in Erlang (specced or otherwise), if anything is missing feel free to file an issue against Stetson (or even a pull request) - a lot of this functionality has been written and continues to be written on a very much on an on-demand basis.
