Untagged Unions
###############

If when interacting with our legacy API we decided that the cost of spinning up an extra process was too much, it is possible with the use of the package `erl-untagged-union <https://github.com/id3as/purescript-erl-untagged-union>`_ to define an ADT in Purescript that maps onto the original data type and an instance of the appropriate typeclass to tell the code how to match on it. This isn't *too* different philosophically from the act of calling multiple interpreters against a Foreign to see which one succeeds except it does provide a more formal way of describing the alternatives and can provide value when writing code against a message based API that is going to be in heavy use and has multiple message types that need unpacking.

Consider the following legacy API in Erlang:

.. code-block:: erlang

  %% Subscribe to the legacy API
  { ok, Ref } = legacy_api:start()

  %% And start receiving messages from it
  receive 
    { data, From, Binary } -> ...
    { info, From, {trace, Binary} } -> ...
    { error, Error } -> ...


We could describe these messages in the form of a Purescript ADT pretty easily

.. code-block:: haskell

   data LegacyMsg 
    = Data Pid Binary
    | Info Pid (Tuple Atom Binary)
    | Error Foreign


And we *could* indeed provide a method as part of the legacy API to convert the foreign messages into this, if we were so inclined

.. code-block:: haskell

   interpretForeign :: Foreign -> LegacyMsg
   interpretForeign = ...

But this is potentially burdensome to write - not to mention error prone, so instead we can use the untagged unions module to help describe this message.


Describing the types
--------------------


.. code-block:: haskell

  import Data.Generic.Rep (class Generic)
  import Erl.Untagged.Union as U

  derive instance genericMsg :: Generic LegacyMsg _

  instance runtimeTypeLegacyMessage ::
    U.RuntimeType
      LegacyMsg
      ( U.RTOption (U.RTTuple3 (U.RTLiteralAtom "data") U.RTWildCard U.RTBinary)
          (U.RTOption (U.RTTuple3 (U.RTLiteralAtom "info") U.RTWildCard (RT.Tuple2 RT.Atom U.RTBinary))
            (U.RTTuple2 (U.RTLiteralAtom "error") U.RTWildCard)))

The way this works, is that if a more concrete type than *RTWildCard* is provided, then in order for the message to be unpacked by that line then it *has* to match. Obviously in this case there is a atom with a literal value being matched against as a discriminator so we could get away with just using RTWildCard in the rest of the expression like so

.. code-block:: haskell

  import Data.Generic.Rep (class Generic)
  import Erl.Untagged.Union as U

  derive instance genericMsg :: Generic LegacyMsg _

  instance runtimeTypeLegacyMessage ::
    U.RuntimeType
      LegacyMsg
      ( U.RTOption (U.RTTuple3 (U.RTLiteralAtom "data") U.RTWildCard U.RTWildcard)
          (U.RTOption (U.RTTuple3 (U.RTLiteralAtom "info") U.RTWildCard (RT.Tuple2 RT.RTWildcard U.RTWildcard))
            (U.RTTuple2 (U.RTLiteralAtom "error") U.RTWildCard)))

We don't tend to do that however, in general the more accurately you describe your expected messages the more useful this library becomes.

Handling the messages
---------------------

When writing a receive block that can be sent these untagged messages, we need to describe to the type system the types of messages we expect to receive.


.. code-block:: haskell

   import Erl.Untagged.Union (Union, type (|$|), type (|+|), Nil)
   import Erl.Untagged.Union as U
    
   type Msg
    = U.Union |$| LegacyMsg |+| Nil


"Msg is an untagged Union that may contain LegacyMsg, as described in the runtimeType typeclass"


.. code-block:: haskell

   msg :: Msg <- receive
   (U.case_ 
    # U.on ( \(legacyMsg :: LegacyMsg) ->
      case legacyMsg of 
        Data pid bin -> ...
        Info from info -> ...
        Error err -> ...
      )) msg
      
Further message types could be added and described and matched as thus

.. code-block:: haskell

   import Erl.Untagged.Union (Union, type (|$|), type (|+|), Nil)
   import Erl.Untagged.Union as U
    
   type Msg
    = U.Union |$| LegacyMsg |+| OtherMsg |+| Nil


with

.. code-block:: haskell

   msg :: Msg <- receive
   (U.case_ 
    # U.on ( \(legacyMsg :: LegacyMsg) ->
      case legacyMsg of 
        Data pid bin -> ...
        Info from info -> ...
        Error err -> ...
      )
    # U.on ( \(otherMsg :: OtherMsg) ->
      case otherMsg of 
        ...
      )
   ) msg
      
In this way, the compiler will let us know if we're not being exhaustive.

Pros and cons..
---------------

- This mechanism is incredibly useful for describing message based APIs with complex message types in cases when we don't want the cost/burden of spinning up an additional proxy process but still want a convenient mechanism for unpacking these message types without having to write error-prone mapping code.
- It is however possible to make mistakes in the description instead, this mechanism just formalises the process somewhat. 
- Once you have made the decision to write a process that receives an untagged union that means all messages need to be described as part of this untagged union - even if they are native Purescript types. 

For the most part therefore, the message router is more convenient. For a good example of an API that uses untagged unions to good effect, have a look at the source code for `erl-gun <https://github.com/id3as/purescript-erl-gun/blob/master/src/Erl/Gun.purs#L408>`_.
