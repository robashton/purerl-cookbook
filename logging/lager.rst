Lager
=====

Adding *erl-lager* to *spago.dhall* and *lager* to *rebar.config* is required for the use of Lager in a Purerl project.

It is a very basic module, with functions for the various levels being exposed in the form

.. code-block:: haskell

  -- lager:info("Something ~p", [ A ]).
  info1 :: forall a. String ->  a -> Effect Unit

  -- lager:info("Something ~p ~p", [ A, B ]).
  info2 :: forall a b. String -> a -> b -> Effect Unit

There are no checks against the format string in play, and are no plans to do anything more fancy than the above; so your mileage may vary. Pull requests will no doubt be accepted or indeed simply forking the project to do something more advanced if you really want to use Lager are both valid options.
