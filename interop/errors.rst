Error handling
##############

In the previous code, we had the following FFI

.. code-block:: erlang

  -module(legacyApi@foreign).

  -export([ openDatabase/1, readFromDatabase/2 ]).

  openDatabase(ConnectionString) ->
    fun() ->
      { ok, Handle } = legacy_api:open_database(ConnectionString),
      Handle
    end.
  
  readFromDatabase(Handle, Key) ->
    fun() ->
      { ok, Value } = legacy_api:read_from_database(Handle, Key),
      Value
    end.

There are runtime crashes in this code that may or may not be desirable *("it depends")*. Let's say for the sake of argument that we in a situation where failing to open a database shouldn't crash the containing process.

A good way to model this in Purescript would be to expose the API as a **Maybe Handle**, or **Either ErrorMessage Handle**

.. code-block:: haskell

  foreign import openDatabase :: String -> Effect (Maybe Handle)

By snooping around some other compiled Erlang, we can see that **Maybe Handle** is represented as a tuple of either **{just, Handle}** or  **{nothing}**, so in our FFI we could use this to fulfil the foreign import definition above.

.. code-block:: erlang

  openDatabase(ConnectionString) ->
    fun() ->
       case legacy_api:open_database(ConnectionString) of
         { ok, Handle } -> { just, Handle };
         _ -> {nothing}
       end
    end.

Once again however, we're showing the wrong way to do things before we demonstrate the right way. Relying on the types that the compiler generates is typically a bad way of doing business, they are subject to change and aren't remotely type-checked. The pattern is therefore to write an FFI that passes in the appropriate contructors for the Maybe type, and then export a function that uses this FFI and hides that detail.

.. code-block:: haskell

  foreign import openDatabaseImpl :: (Handle -> Maybe Handle) -> Maybe Handle -> String -> Effect (Maybe Handle)

  openDatabase :: String -> Effect (Maybe Handle)
  openDatabase = openDatabase Just Nothing


and

.. code-block:: erlang

  openDatabase(Just, Nothing, ConnectionString) ->
    fun() ->
       case legacy_api:open_database(ConnectionString) of
         { ok, Handle } -> Just(Handle);
         _ -> Nothing
       end
    end.

This is typically the pattern for mapping to code that returns Purescript types and if you find yourself writing more code than this in Erlang then it's a sign that the FFI is too heavy and a thinner layer (and more Purescript) is required.

*Note: While the above is "correct", it must be pointed out that in most of our code these days, we simply return {just} and {nothing} from FFI as a matter of course as it is very common - for most other data types however, constructors are still passed in.*
