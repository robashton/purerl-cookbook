Emacs
=====

Obviously the short answer to this page is use :doc:`vim <vim>` but if you're already set in your ways then you can carry on reading this page.

The majority of our team is using Emacs with psc-ide integration directly, but seeing as Language Server Protocol is a thing it's unlikely this will be the case for too much longer.

Without Language Server
=======================

The best place to find Emacs configuration is `@philipstears <http://twitter.com/philipstears>`_ `nixos-install <https://github.com/philipstears/nixos-install>`_ repo as that's not only well maintained but in general also well thought out too.

His setup is pretty much a case of installing the following packages (all available in Melpa)

* `purescript-mode <https://github.com/purescript-emacs/purescript-mode>`_
* `psc-ide <https://github.com/purescript-emacs/psc-ide-emacs>`_
* `dhall-mode <https://github.com/psibi/dhall-mode>`_
        
The relevant config in emacs  at that point is

.. code-block:: elisp

    (use-package purescript-mode)
    (use-package psc-ide)
    (use-package dhall-mode)
    
    (add-hook
      'purescript-mode-hook
      (lambda ()
        (psc-ide-mode)
        ;;(flycheck-mode)
        (turn-on-purescript-indentation)))
    
    (add-hook 'psc-ide-mode-hook
    	  (lambda ()
    	    (define-key evil-normal-state-local-map (kbd "C-]") 'psc-ide-goto-definition)
          (define-key evil-insert-state-local-map (kbd "C-]") 'psc-ide-goto-definition)))

With Language Server
====================

The `purescript-language-server <https://github.com/nwolverson/purescript-language-server>`_ needs installing somewhere, and the following packages need to be present in emacs (again, all available in Melpa).

* `lsp-mode <https://github.com/emacs-lsp/lsp-mode>`_
* `dhall-mode <https://github.com/psibi/dhall-mode>`_

lsp-mode has support for Purescript built in, and just needs spinning up for purescript-mode

.. code-block:: elisp

  (add-hook 'purescript-mode-hook #'lsp)

`Further docs for this are worth reading <https://emacs-lsp.github.io/lsp-mode/page/installation/>`_, I'm not an Emacs user so YMMV.
          
