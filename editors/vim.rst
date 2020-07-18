Vim
===

Two possible solutions for working with Purerl are outlined below, the first without using LSP and the latter with. That's because your erstwhile author been working without it for two years and whilst writing this document switched to using the LSP because it seems inherently better.

Without Language Server
***********************

Without the LSP, support for Purescript/Purerl can be gained by the installation of two plugins

* `vim-psc-ide <https://github.com/FrigoEU/psc-ide-vim>`_:  Integration to 'purs ide'
* `vim-purescript <https://github.com/purescript-contrib/purescript-vim>`_: Syntax highlighting

Functionality gained

- syntax highlighting
- purs ide started in background automatically
- compilation on file-save
- module import checking
- auto module imports
- function type checking

Caveats

- In the default state, :Pload will need to be ran a lot, or the purs ide will be out of sync with module changes
- Switching between client-side code and server-side code will mean an editor restart (multiple projects, two servers needed)

That said, I worked like this for two years without updating once so that's nice.

With Language Server
********************

This is now my preferred way to set up my editor, as projects targetting LSP are far likely to be maintained as they're agnostic to underlying technology choices. (Relying on random Github repos with vim script in for uncommon language integration is asking for trouble).

What we need is

* `vim-lsp <https://github.com/prabirshrestha/vim-lsp>`_: An arbitrarily chosen LSP plugin for VIM
*  `purescript-language-server <https://github.com/nwolverson/purescript-language-server>`_: The language server
* `vim-purescript <https://github.com/purescript-contrib/purescript-vim>`_: Syntax highlighting (still)

The bare minimum config for getting this up and running is 

.. code-block:: bash

  if executable('purescript-language-server')
      au User lsp_setup call lsp#register_server({
        \ 'name': 'purescript-language-server',
        \ 'cmd': {server_info-> ['purescript-language-server', '--stdio']},
        \ 'allowlist': ['purescript']
        \ })
  endif


But it's  a bit better if you at least set the rootUri based on the manifest location, as that's rarely going to be the root of the Git repo in a Purerl project.

.. code-block:: bash

  if executable('purescript-language-server')
      au User lsp_setup call lsp#register_server({
        \ 'name': 'purescript-language-server',
        \ 'cmd': {server_info-> ['purescript-language-server', '--stdio']},
        \ 'root_uri':{server_info->
        \ lsp#utils#path_to_uri(
        \	lsp#utils#find_nearest_parent_file_directory(
        \		lsp#utils#get_buffer_path(), ['spago.dhall']
        \	))},
        \ 'allowlist': ['purescript']
        \ })
  endif

Obviously it can then be configured further, and extra keybindings can be added when a buffer is opened in this mode

.. code-block:: bash

  function! s:on_lsp_buffer_enabled() abort
      setlocal omnifunc=lsp#complete
      setlocal signcolumn=yes
      if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  endfunction

  augroup lsp_install
      au!
      autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  augroup END


This is quite a basic setup, config can be passed to the language server to make it more aware of spago/psc-package/etc, all of that is documented in the relevant projects.

The functionality is *rich* compared to the plain psc-ide experience, and is more fully documented on the vim-lsp github page. 

In this default state, the editor will need restarting between editing client/server projects, with the use of local config this could probably be obliviated (separate ports for the language server, etc).

