Logging
=======

In classic Erlang projects, the de-facto for logging for a very long time has been `lager <https://github.com/erlang-lager/lager>`_ which has served us well for a very long time indeed.

If integrating with legacy code which uses lager extensively then you probably want to stick with it, and for that we have `purescript-erl-lager <https://github.com/erlang-lager/lager>`_.

For new projects, or projects where logging has been wrapped up in a pile of macros anyway (does anybody *not* do this?), switching/starting with the `logger <https://erlang.org/doc/man/logger.html>`_ that ships with Erlang as of OTP 21.0 is a safer bet.

Certainly as we roll forwards with Purerl development, focus and support will typically be given to Logger in preference to lager.

* :doc:`Lager <lager>`
* :doc:`Logger <logger>`

.. toctree::
   :hidden:
   :titlesonly:

   lager
   logger



