Interop
#######

Whether writing Purescript green-field, or writing against legacy code - the nature of the platform is that eventually you will need to write some Erlang. There are a lot of popular modules in Erlang that don't have maintained bindings yet and swathes of core Erlang code that aren't exposed in Purescript.

In general this gets done ad-hoc as required in modules internal to our projects and once there is sufficient coverage these get promoted to actual modules in the package set. It is wise to avoid writing Erlang *as much as possible* when committing to Purerl no matter how tempting it may be to "just drop into Erlang for this module", that'll be where you'll get crashes for the next couple of days.

The best practise is to write *thin* bindings that exactly represent the underlying types and functions and then use that from more Purescript that exposes that in a nicer way. It is often tempting to skip that step and go straight to 'exposed in a nice way' but this is usually a mistake.

* :doc:`FFI <ffi>`
* :doc:`Effects <effects>`
* :doc:`Errors <errors>`
* :doc:`Messaging <messaging>`

.. toctree::
   :hidden:
   :titlesonly:

   ffi
   effects
   errors
   messaging
   messaging-routing
   messaging-untagged

