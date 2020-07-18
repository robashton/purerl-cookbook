VSCode
===

VSCode is probably the simplest IDE to get up and running with, as there is simply a couple of extensions installable by the built-in extension manager.

* `vscode-language-purescript <https://github.com/nwolverson/vscode-language-purescript>`_
* `vscode-ide-purescript <https://github.com/nwolverson/vscode-ide-purescript>`_

The former *should* be automatically installed by the latter so is only here for completeness. The above being a complete package in a single place also means little documentation is required here.

For the demo project, a spago setup is useful; That just means setting the following values in your *settings.json*

.. code-block:: json

  {
    "purescript.codegenTargets": [ "corefn" ],
    "purescript.addSpagoSources": true,
    "purescript.buildCommand": "spago build --purs-args --json-errors"
  }
