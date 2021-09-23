Emacs
=====

Obviously the short answer to this page is use :doc:`vim <vim>` but if you're already set in your ways then you can carry on reading this page.

The majority of our team are using the language server protocol, although PSC-IDE does exist. 


With Language Server
********************

The `purescript-language-server <https://github.com/nwolverson/purescript-language-server>`_ needs installing somewhere, and the following packages need to be present in emacs (again, all available in Melpa).

* `lsp-mode <https://github.com/emacs-lsp/lsp-mode>`_
* `dhall-mode <https://github.com/psibi/dhall-mode>`_

lsp-mode has support for Purescript built in, and just needs spinning up for purescript-mode

.. code-block:: elisp

  (add-hook 'purescript-mode-hook #'lsp)

`Further docs for this are worth reading <https://emacs-lsp.github.io/lsp-mode/page/installation/>`_, I'm not an Emacs user so YMMV.

Feel free to send me a pull request for this page if you have a good Emacs set up based on either of the above, as I find both of these default setups to be distinctly lacking and don't know enough about Emacs to fix it.

Example configs
***************

* `Steve Strong <https://github.com/srstrong/nix-env/tree/master/common/steve/files/doom>`_
