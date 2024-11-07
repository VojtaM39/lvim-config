-- Keymaps
vim.keymap.set('i', 'kj', '<Esc>', {})
vim.keymap.set('i', 'jk', '<Esc>', {})
vim.cmd 'command! L LazyGit'
vim.cmd("command! C execute '%bd|e#' | bdelete #")

lvim.keys.normal_mode['gt'] = ':BufferLineCycleNext<CR>'
lvim.keys.normal_mode['gT'] = ':BufferLineCyclePrev<CR>'

-- Options
vim.wo.relativenumber = true
vim.opt.foldcolumn = '1'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.shiftwidth = 4


-- Plugins
lvim.plugins = {
    { 'rebelot/kanagawa.nvim' },
    { 'kdheepak/lazygit.nvim' },
    { 'nvim-telescope/telescope.nvim',   version = '0.1.1' },
    { 'kevinhwang91/nvim-ufo',           dependencies = 'kevinhwang91/promise-async' },
    { 'preservim/nerdtree' },
    { 'neovim/nvim-lspconfig' },
    { 'jose-elias-alvarez/null-ls.nvim' },
    { 'MunifTanjim/eslint.nvim' },
    { 'github/copilot.vim' },
    { 'marilari88/twoslash-queries.nvim' },
    { 'kkoomen/vim-doge' },
    {
        'Wansmer/treesj',
        dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
        config = function()
            require('treesj').setup({
                use_default_keymaps = false
            })
        end,
    }
}

-- Colorscheme
lvim.colorscheme = 'kanagawa'
lvim.transparent_window = false
vim.api.nvim_command [[
  autocmd ColorScheme * highlight Folded guibg=none ctermbg=none
]]
require('kanagawa').setup({
    compile = false,  -- enable compiling the colorscheme
    undercurl = true, -- enable undercurls
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true },
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,   -- do not set background color
    dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
    terminalColors = true, -- define vim.g.terminal_color_{0,17}
    colors = {
        -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors) -- add/modify highlights
        return {}
    end,
    theme = 'wave', -- Load 'wave' theme when 'background' option is not set
    background = {
        -- map the value of 'background' option to a theme
        dark = 'wave', -- try 'dragon' !
        light = 'lotus'
    },
})


-- Telescope
local builtin = require('telescope.builtin')
lvim.builtin.telescope.defaults = {
    path_display = { 'absolute' },
    wrap_results = true
}
lvim.keys.normal_mode['<leader>o'] = builtin.lsp_references
lvim.keys.normal_mode['<leader>j'] = builtin.find_files
lvim.keys.normal_mode['<leader>k'] = builtin.live_grep
vim.api.nvim_set_keymap('n', '<C-k>',
    ":lua require('telescope.builtin').live_grep({ default_text = vim.fn.expand('<cword>') })<CR>", { silent = true })


-- UFO
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}
local language_servers = require('lspconfig').util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
for _, ls in ipairs(language_servers) do
    require('lspconfig')[ls].setup({
        capabilities = capabilities
        -- you can add other fields for setting up lsp server in this table
    })
end
require('ufo').setup()

-- Copilot
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ''
vim.api.nvim_set_keymap('i', '<C-e>', "copilot#Accept('')", { expr = true, silent = true })

-- Linters + Formatters
local linters = require 'lvim.lsp.null-ls.linters'
local formatters = require 'lvim.lsp.null-ls.formatters'
lvim.builtin.which_key.mappings['l']['f'] = {
    function()
        require('lvim.lsp.utils').format { timeout_ms = 5000 }
    end,
    'Format',
}

formatters.setup({
    { command = 'prettierd', filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'json' } },
})
linters.setup({
    { command = 'eslint_d', filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } },
})

-- NerdTree
vim.g.NERDTreeHijackNetrw = 1
vim.g.NERDTreeWinSize = 60

-- TwoSlash
require('lspconfig')['tsserver'].setup({
    on_attach = function(client, bufnr)
        require('twoslash-queries').attach(client, bufnr)
    end,
})

-- TreeSitter
lvim.builtin.treesitter.ensure_installed = {
    'javascript',
    'typescript',
    'tsx',
    'json',
    'html',
    'css',
    'yaml'
}

-- LSP
local lspconfig = require('lspconfig')
lspconfig.tsserver.setup({
    on_attach = function(client, bufnr)
        -- Disable tsserver formatting if using something like prettier
        client.server_capabilities.documentFormattingProvider = false
        require('lvim.lsp').common_on_attach(client, bufnr)
    end,
})
