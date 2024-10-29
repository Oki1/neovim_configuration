-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.scrolloff= 15
vim.opt.clipboard:append{"unnamedplus", "unnamed"}
vim.opt.showtabline=0
vim.g.mapleader = 'ć'
vim.keymap.set("", "+", function() vim.diagnostic.open_float() end)
vim.keymap.set("", "<c-j>", "}")
vim.keymap.set("", "p", "p <cmd>sil! :%s/\\r//g<cr>")
vim.keymap.set("", "<C-k>", "{")
--lazy setup
local lazy = {}
if(vim.loop.os_uname().sysname=="Windows NT") then
    vim.cmd([[
    set shell=pwsh
    set shellcmdflag=-command
]])
end
function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end
function lazy.setup(plugins)
  if vim.g.plugins_ready then
    return
  end
  lazy.install(lazy.path)

  vim.opt.rtp:prepend(lazy.path)
  require('lazy').setup(plugins, lazy.opts)
  vim.g.plugins_ready = true
end
lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

--plugins
lazy.setup({
{ 'rose-pine/neovim', name = 'rose-pine' },
{'williamboman/mason.nvim'},
{'williamboman/mason-lspconfig.nvim'},
{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
{'neovim/nvim-lspconfig'},
{'hrsh7th/cmp-nvim-lsp'},
{'hrsh7th/nvim-cmp'},
{'L3MON4D3/LuaSnip'},
{'m4xshen/autoclose.nvim'},
{'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }},
{'ms-jpq/chadtree', branch='chad', build='python3 -m chadtree deps'},
{
    'numToStr/Comment.nvim',
    opts = {
        -- add any options here
    },
    lazy = false,
},
--{'numToStr/Navigator.nvim', }
{'lervag/vimtex',
config = function()
    vim.cmd([[
    let g:vimtex_view_method= 'zathura'
    ]])
    end
},
})

require('Comment').setup()
vim.cmd('colorscheme rose-pine-moon')
--require("Navigator").setup()
require("autoclose").setup()
--Navigator
--vim.keymap.set({'n', 't'}, '<A-a>', '<cmd> tes:t')
--vim.keymap.set({'n', 't'}, '<A-d>', '<CMD>NavigatorRight<CR>')
--vim.keymap.set({'n', 't'}, '<A-w>', '<CMD>NavigatorUp<CR>')
--vim.keymap.set({'n', 't'}, '<A-s>', '<CMD>NavigatorDown<CR>')
--tmux

local function vspl()
    vim.cmd("vsplit")
end
local function hspl()
    vim.cmd("split")
end

vim.keymap.set({'n', 't'}, '<C-v>', vspl)
vim.keymap.set({'n', 't'}, '<C-h>', hspl) 
vim.keymap.set({'n', 't'}, '<c-x>', vim.cmd.quit)
local function maximize()
    local ok, _ = pcall(vim.cmd.tabc)
    if ok == false then
        vim.cmd("tab split")
    end
end
vim.keymap.set({'n', 't'}, '<c-z>', maximize)

--Chadtree
local chadtree_settings = {["view.open_direction"] = "right"}
vim.api.nvim_set_var("chadtree_settings", chadtree_settings)
vim.keymap.set({"n", 't'}, "č", vim.cmd.CHADopen)
--theme setup
vim.opt.termguicolors = true

--telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})

--lsp
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
  })
})
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(_client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)
require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here 
  -- with the ones you want to install
  select_beheviour = 'insert',
  ensure_installed = {'lua_ls', 'clangd','pyright', 'yamlls', 'swift_mesonls'},
  handlers = {
    lsp_zero.default_setup,
    },
})
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- delay update diagnostics
    update_in_insert = true,
  }
)
