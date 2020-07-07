Logger
======

Adding *erl-logger* to *spago.dhall* is all that's required for logger, as the module is bundled with OTP 21.0 by default.

While the API is still quite simplistic, it does at least have the ability for per-module logging to be configured as well as support up-front for structured logging, which means supplying filterable context as well as the inclusion of actual code context (module/function/etc). The API is a little less user-friendly up-front but this serves for a better experience in a production project.

Methods are exposed for the various log levels (info/debug/warning/notice/etc) that take in a metadata with all of the information for the logging call, as well as a report which describes the logging call. It is important to note that metadata is the *primary* purpose of logging and the report is secondary to that.

The underlying logger module is capable of much more than is exposed in the Purerl module and presently only supports the needs of logging styles requested by clients of the code so far. `Pull requests and requests are obviously accepted. <https://github.com/id3as/purescript-erl-logger>`_

.. code-block:: haskell

  let domain = (atom "the_domain" : nil)
      metadata = Logger.traceMetadata domain "This is the message for the log"
      report = {}
   _ <- Logger.info metadata report


This is obviously quite verbose, but in essence we end up with per-project helpers for the various domains present within the project that help us do the logging that we need across them.

.. code-block:: haskell

  domain :: List Atom
  domain = (atom "acme") : (atom "project") : (atom "component") : nil

  logInfo :: report. String -> { | report }-> 
  logInfo = Logger.info <<< Logger.traceMetadata domain

  logWarning :: forall report. String -> { | report }-> 
  logWarning = Logger.warning <<< Logger.traceMetadata domain


The usage of which is then simply

.. code-block:: haskell

  logInfo "Something happened to this stream" { streamId: stream.id, nodeId: node.id }

Now this is actually not quite right, as we're stuffing data into the *report* that might best be in the *metadata*, instead we might want to consider building the custom metadata ourselves.

We can set this globally *per process* so that all logs from a single process will automatically have this metadata applied

.. code-block:: haskell

  -- During process initialisation (for example Gen.Init )
  _ <- Logger.addLoggerContext { streamId: stream.id, nodeId: node.id }

  -- A typical log call elsewhere
  logInfo "Something happened to this stream" {}

Now the metadata will be supplied for every logging call in this process, and it will *be* metadata as opposed to report-data which is the correct place for it to be.

If we need to build our own metadata on a per-call basis, then this is slightly more involved as it needs merging with the underlying pre-filled in metadata (containing domain, type, text). We can either do some row-level magic with Purescript, or just supply all of this information ourselves as part of the logging call.

.. code-block:: haskell
  
  Logger.warning { domain, type: Logger.Trace, text: "Something happened to this stream", streamId: stream.id, nodeId: nodeId  } {}

And now we're back to the start again, calling Logger directly. Obviously it's possible to wrap this up in whatever way it most convenient for the size of the project, but the important thing is that the flexibility and power is there to do proper structured logging all the way down.




