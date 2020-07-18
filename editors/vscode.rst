VSCode
======

VSCode is probably the simplest IDE to get up and running with, as there is simply a couple of extensions installable by the built-in extension manager.

* `purescript-language-server <https://github.com/nwolverson/purescript-language-server>`_: The language server
* `vscode-language-purescript <https://github.com/nwolverson/vscode-language-purescript>`_
* `vscode-ide-purescript <https://github.com/nwolverson/vscode-ide-purescript>`_

The first vscode extension *should* be automatically installed by the secone one so is only there for completeness. The above being a complete package in a single place also means little documentation is required here cos it exists over there..

For the demo project, a spago setup is useful; That just means setting the following values in your *settings.json*

.. code-block:: json

  {
    "purescript.codegenTargets": [ "corefn" ],
    "purescript.addSpagoSources": true,
    "purescript.buildCommand": "spago build --purs-args --json-errors"
  }

To get this to work effectively, you'll want to open the *server* and *client* code as 'folders' separately.
