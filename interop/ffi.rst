FFI
###

Module names
============

A module **MyModule.purs** with the below definition will compile to the Erlang module **myModule@ps**. Note the camelCasing and the suffix of @ps added to the module name. 

.. code-block:: haskell

  module MyModule where

A module **MyModule.purs** with the below definition will compile to **acmeCorp_myModule@ps**. Note the underscore between namespaces, as well as the camelCasing per namespace and the eventual suffix of @ps.

.. code-block:: haskell

  module AcmeCorp.MyModule where

These details are important when writing foreign function imports in Erlang, the means of doing so being to create an Erlang module next to the Purescript module, with the same name but with a .erl suffix. **MyModule.purs** therefore would have a corresponding **MyModule.erl** if we wanted to do FFI.

The name of the compiled module comes into play, as the Erlang module requires an appropriate name to go with it.

* **MyModule.purs** with **module MyModule** in Purescript would have a foreign import module of **MyModule.erl** containing **-module(myModule@foreign)** in Erlang
* **MyModule.purs** with **module AcmeCorp.MyModule** in Purescript would have a foreign import module of **MyModule.erl** containing  **-module(acmeCorp_myModule@foreign)** in Erlang

Foreign Function Imports
========================

Having defined a Purescript module with an appropriately named Erlang module side by side, the next thing would be to define a function in Erlang that we can call from Purescript.

.. code-block:: erlang

  -module(myModule@foreign).

  -export([ add/2 ]).

  add(X,Y) -> X + Y.


To create a function that's callable from Purescript, we need to import this as a foreign function in our Purescript module. This can be exported from the module just like any other function at that point.

.. code-block:: haskell
  
  module MyModule ( add ) 
    where

  foreign import add :: Int -> Int -> Int

In general where we have legacy Erlang of the form *my_module:do_stuff*, we'd be creating *MyModule.purs* and *MyModule.erl* and defining functions that map onto that legacy API, and thus we can interact with our existing code in a reasonably safe manner.

