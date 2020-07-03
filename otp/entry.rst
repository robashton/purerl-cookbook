OTP Entry Point
===============

As part of configuration for an Erlang application, an *.app.src* is provided which gets compiled into a *.app* and is then used to determine how to start an application and what need starting before that occurs (amongst various other settings).

There is no Purerl wrapper around this because it has (so far) been seen as a low value thing to abstract, the demo_ps project therefore has a file directly written at '*./src/demo_ps.app.src*' which is entirely Erlang specific and dealt with when we run *rebar3 compile*

.. literalinclude:: /demo-ps/src/demo_ps.app.src
  :language: erlang
  :linenos:

The most important part of this file as far as we're concerned here is the line that specifies which module is the entry point to our application. In this case that's *bookApp@ps*. This corresponds to the file '*./server/src/BookApp.Purs*' and this instantly tells us something.

When we compile the *.purs*, the module created is camelCased and the suffix '@ps' is added to it. (@ is a valid character in module names that nobody seems to use so we're unlikely to get collisions).

What does this module look like?

