Vim/Neovim
==========

Language server support is available for Purescript, therefore it is available for Purerl too.

Neo-vim 0.5
***********

Neovim 0.5 comes with a built in language server protocol implementation - all that is left is configuring it for use. 

Some extra plug-ins can be installed for then implementing additional functionality on top of that, such as auto-completion.

The list of plug-ins currently in use in my config is

- purescript-vim (*syntax highlighting*)
- neovim/nvim-lspconfig (*common configs for the built-in lsp*)
- nvim-lua/lsp_extensions.nvim (*extensions on top of the lsp*)

And then

- hrsh7th/nvim-cmp  (*auto-completion engine for nvim*)
- hrsh7th/cmp-nvim-lsp (*lsp source for the auto-completion engine*)
- hrsh7th/cmp-vsnip (*etc etc etc*)
- hrsh7th/cmp-path
- hrsh7th/cmp-buffer
- hrsh7th/vim-vsnip

With the following setup in init.lua


.. code-block:: lua

   local nvim_lsp = require 'lspconfig'

   local on_attach = function(client, bufnr)
     local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
     local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

      -- Mappings.
     local opts = { noremap=true, silent=true }

     buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
     buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
     buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
     buf_set_keymap('n', 'g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
     buf_set_keymap('n', 'g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
     buf_set_keymap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
     buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
     buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
     buf_set_keymap('n', '<space>i', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
     buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
   end

   -- Configure Purescript
   nvim_lsp['purescriptls'].setup {
     on_attach = on_attach,
     settings = {
       purescript = {
         formatter = "pose",
         codegenTargets = { "corefn" },
         addSpagoSources = true,
       },
     },
     flags = {
       debounce_text_changes = 150,
     }
   }

   -- Disable the annoying LSP virtual text
   vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
     vim.lsp.diagnostic.on_publish_diagnostics, {
       virtual_text = false,
       underline = true,
       signs = true,
     }
   )

   -- Setup the cmp plugin for auto completion
   local cmp = require 'cmp'
   cmp.setup({
     snippet = {
       expand = function(args)
           vim.fn["vsnip#anonymous"](args.body)
       end,
     },
     mapping = {
       ['<C-p>'] = cmp.mapping.select_prev_item(),
       ['<C-n>'] = cmp.mapping.select_next_item(),
       -- Add tab support
       ['<S-Tab>'] = cmp.mapping.select_prev_item(),
       ['<Tab>'] = cmp.mapping.select_next_item(),
       ['<C-d>'] = cmp.mapping.scroll_docs(-4),
       ['<C-f>'] = cmp.mapping.scroll_docs(4),
       ['<C-Space>'] = cmp.mapping.complete(),
       ['<C-e>'] = cmp.mapping.close(),
       ['<CR>'] = cmp.mapping.confirm({
         behavior = cmp.ConfirmBehavior.Insert,
         select = true,
       })
     },

     -- Installed sources for 'cmp'
     sources = {
       { name = 'nvim_lsp' },
       { name = 'vsnip' },
       { name = 'path' },
       { name = 'buffer' },
     },
   })



additionally in init.vim

.. code-block:: vim

    " Set completeopt to have a better completion experience
    set completeopt=menuone,noinsert,noselect

    " Avoid showing message extra message when using completion
    set shortmess+=c

    " Reserve space for the errors
    set signcolumn=yes

With vim-coc
************

Add this to the config, using :CocConfig

.. code-block:: json

  "languageserver": {
    "purescript": {
      "command": "purescript-language-server",
      "args": ["--stdio"],
      "filetypes": ["purescript"],
      "rootPatterns": ["bower.json", "psc-package.json", "spago.dhall"],
      "settings": {
        "purescript": {
          "addSpagoSources": true
        }
      }
    }
  }

With vim-lsp
************

*Note: This might be out of date, as the author hasn't used vim-lsp in over a year.*

What we need is

* `vim-lsp <https://github.com/prabirshrestha/vim-lsp>`_: An arbitrarily chosen LSP plugin for VIM
* `purescript-language-server <https://github.com/nwolverson/purescript-language-server>`_: The language server
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

In this default state, the editor will need restarting between editing client/server projects, with the use of local config this could probably be obliviated (separate ports for the language server, etc)

Code updates should generally be reflected much more responsively, so this makes for a much smoother experience than the direct psc-ide integration.

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
