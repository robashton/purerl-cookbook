Effects
#######

A lot of interop is effectful, and care really must be taken to describe it as such, consider the legacy API below

.. code-block:: erlang

  { ok, Handle } = legacy_api:open_database(ConnectionString),
  { ok, Value } = legacy_api:read_from_database(Handle, Key).


A *naive* implementation of an FFI module for this might look like this

.. code-block:: haskell

  module LegacyApi where

  foreign import data Handle :: Type

  foreign import openDatabase :: String -> Handle
  foreign import readFromDatabase :: Handle -> String -> String

.. code-block:: erlang

  -module(legacyApi@foreign).

  -export([ openDatabase/1, readFromDatabase/2 ]).

  openDatabase(ConnectionString) ->
    { ok, Handle } = legacy_api:open_database(ConnectionString),
    Handle.
  
  readFromDatabase(Handle, Key) ->
    { ok, Value } = legacy_api:read_from_database(Handle, Key),
    Value.
    

But this would be a lie, both opening a database and reading from a database are clearly effectful actions; whilst this code will work when invoked from Purescript, the effectful actions will be taking place outside of the Effect system and this will bite us in the ass in the form of runtime errors later down the line when we accidentally end up invoking side effects from the wrong processes.

A more *correct* implementation of this would be to define these functions as effectful.

.. code-block:: haskell

  module LegacyApi where

  foreign import data Handle :: Type

  foreign import openDatabase :: String -> Effect Handle
  foreign import readFromDatabase :: Handle -> String -> Effect String

We can view an Effect as 'a function' to be invoked at the top level of execution - we might create a whole stack of effects as a result of calling an effectful function and these all get bubbled up to the point of entry which is then responsible for actually unpacking the result. Any effectful action is just a function that returns a function - functions all the way down.

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

Passing effectful Purescript functions back to Erlang
=====================================================

Quite often, Erlang APIs will take in a module name on which it will invoke several functions (perhaps defined as a "behaviour"), easy examples come to mind would be the gen_server callbacks and cowboy_rest/cowboy_loop callbacks. For the purposes of this example we'll define an interface for handling events from some sort of legacy Erlang system.

An implementation of our imaginary event callback module in Erlang might look like this

.. code-block:: erlang

  -module(callback_module).

  -export([ handle_event/1 ]).

  handle_event(Event) ->
    db:write_event(Event).


And we'd register that with the system with a call that looked something like

.. code-block:: erlang
  
  legacy_system:register_callbacks(callback_module).


If we wanted to write our callback module directly in Purescript, a naive implementation would look like this

.. code-block:: haskell

  module CallbackModule where

  handle_event :: Effect Atom
  handle_event ev = do
    void $ Db.writeEvent ev
    pure $ (atom "ok")

Registered with something like this

.. code-block:: haskell

  legacySystem.registerCallbacks (atom "callbackModule@ps)

However, if we are to invoke handle_event from Erlang, we would quickly discover that it does not return the *(atom "ok")* as expected, but instead something like *#Fun<callbackModule@ps.97.23242010>* (because an Effect is just a function).

We could remove the Effect from our function definition but this would leave us unable to perform side effects. Handily we have functions to help with this kind of dance in Effect.Uncurried

.. code-block:: haskell

  module CallbackModule where

  import Effect.Uncurried (EffectFn1, mkEffectFn1)

  handle_event :: EffectFn1 Event Atom
  handle_event = mkEffectFn1 \ev -> do
      void $ Db.writeEvent ev
      pure $ (atom "ok")

This will give us an effectful function in a callback, but at the top level it'll execute the effect and return the result to the native Erlang code. These uncurried helpers are available for functions up to 10 arguments deep and if you really need more than that the only real problem is that you have a function that big in the first place - creating additional versions of mkEffectFn is just a case of taking the code from the Effect.Uncurried module and adding some parameters.

