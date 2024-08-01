-- Colorscheme
vim.cmd("colorscheme default")

-- Leader Key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- [[ OPTIONS ]]
-- UI changes
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 10
vim.opt.cursorline = true

-- Indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.cindent = true

-- Window split direction
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Tabs and Text Repr
vim.opt.textwidth = 120
vim.o.linebreak = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.list = true
vim.opt.listchars = {
	tab = "| ",
	trail = "·",
	extends = "»",
	precedes = "«"
}

-- Completion window
vim.opt.completeopt = "menu,menuone,popup"
vim.opt.pumwidth = 10

-- Add cwd for vim path completion and other commands
vim.opt.path:append({ "**," })

-- Connect to system clipboard
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

-- Smartcase for Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Make sure to use bash when running commands
vim.opt.shell = "/usr/bin/bash"

-- Create a file for undo history
vim.opt.undofile = true

-- [[ KEYMAPS ]]

vim.keymap.set('n', "<Esc>", "<cmd>nohlsearch<cr>")

vim.keymap.set('t', "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Better Escape
vim.keymap.set({ 'i', 't' }, "jk", "<Esc>", { nowait = true, silent = true })
vim.keymap.set({ 'i', 't' }, "jj", "<Esc>", { nowait = true, silent = true })

-- Better marks
vim.keymap.set("n", "'", "`")

-- [[ AUTOCMDS ]]

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('myconfig-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})


-- [[ PLUGINS ]]

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
	local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
	if vim.v.shell_error ~= 0 then
		error('Error cloning lazy.nvim:\n' .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

local plugins = {

	-- Better LSP for Neovim Config
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			}
		},
		enable = false, -- TODO remove this and add lazydev to completion source
	},

	{ "Bilal2453/luvit-meta", lazy = true },

	-- LSP Setup
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Mason: Plugin to Download new Lsp's, formatters, linters and more
			{ "williamboman/mason.nvim", config = true },
			'williamboman/mason-lspconfig.nvim',
			'WhoIsSethDaniel/mason-tool-installer.nvim',

			-- Not using cmp, but maybe someday
			-- 'hrsh7th/cmp-nvim-lsp',
		},

		config = function()
			-- This function runs whenever a lsp attaches to a buffer
			-- You can define the behavoir of the lsp - mappings, cmp, etc.
			vim.api.nvim_create_autocmd("LspAttach", {

				group = vim.api.nvim_create_augroup("UserLspAttach", {clear = true}),
				callback = function(ev)
					-- Waiting for 0.11 for autocmp + snippets
					-- vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {autotrigger = false})
				end
			})

			-- List of servers to keep installed or to configure
			local servers = {
				lua_ls = {},
			}

			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {}) -- table of the keys as strings
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			-- Setup the servers
			require("mason-lspconfig").setup_handlers {
				function(server_name)
					local server = {} or servers[server_name]
					require("lspconfig")[server_name].setup(server)
				end,
			}
		end

	},

	-- TREESITTER
	-- Syntax highlight and other things
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "bash", "c", "lua", "luadoc", "vim", "diff", "html", "markdown", "query", "vimdoc", "markdown_inline" },
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = { enable = true },
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)
		end,
	},

	-- Collection of Quality Of Life Plugins
	{
		'echasnovski/mini.nvim',
		version = false,
		config = function()
			-- TODO: remove some of this plugins. Reason: don't need all
			-- TODO: configure some of this plugins
			require("mini.ai").setup() -- Better textobject movement
			require("mini.pairs").setup() -- Auto pairs
			require("mini.extra").setup() -- Extra features for ai and picker
			require("mini.surround").setup() -- Manipulate surrounding pairs
			require("mini.bracketed").setup() -- Move with brackets
			require("mini.bufremove").setup() -- Brings another buffer properly when another is closed
			require("mini.diff").setup() -- See git diff on files
			require("mini.pick").setup() -- TODO keymaps for this
			require("mini.starter").setup() -- TODO tweak this
			require("mini.statusline").setup()
			require("mini.tabline").setup() -- NOTE: should keep?
			require("mini.notify").setup()
			require("mini.icons").setup()
			require("mini.cursorword").setup()-- NOTE: should keep?
			require("mini.indentscope").setup()
			require("mini.jump2d").setup()-- NOTE: should keep?
			require("mini.jump").setup()
			require("mini.move").setup()

			-- Set completion and a fallback for omnicomp
			require("mini.completion").setup({
				lsp_completon = {
					source_func = "omnifunc",
				},
				fallback_action = "<C-x><C-o>",
			})

			-- Set highlight patterns for color codes and different notes
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
					hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
					todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
					note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

					-- Highlight hex color strings (`#rrggbb`) using that color
					hex_color = hipatterns.gen_highlighter.hex_color(),
				}
			})
			-- Keymapping Clues
			local miniclue = require('mini.clue')
			miniclue.setup({
				triggers = {
					{ mode = 'n', keys = '[' },
					{ mode = 'n', keys = ']' },

					-- Leader triggers
					{ mode = 'n', keys = '<Leader>' },
					{ mode = 'x', keys = '<Leader>' },

					-- Built-in completion
					{ mode = 'i', keys = '<C-x>' },

					-- `g` key
					{ mode = 'n', keys = 'g' },
					{ mode = 'x', keys = 'g' },

					-- Marks
					{ mode = 'n', keys = "'" },
					{ mode = 'n', keys = '`' },
					{ mode = 'x', keys = "'" },
					{ mode = 'x', keys = '`' },

					-- Registers
					{ mode = 'n', keys = '"' },
					{ mode = 'x', keys = '"' },
					{ mode = 'i', keys = '<C-r>' },
					{ mode = 'c', keys = '<C-r>' },

					-- Window commands
					{ mode = 'n', keys = '<C-w>' },

					-- `z` key
					{ mode = 'n', keys = 'z' },
					{ mode = 'x', keys = 'z' },
				},

				clues = {
					-- Enhance this by adding descriptions for <Leader> mapping groups
					miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
				},
			})
		end
	},
}

local conf = {}

require("lazy").setup(plugins, conf)

