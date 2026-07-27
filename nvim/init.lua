-- =========================================================
-- Asyraf Neovim Config
-- VSCode-like workflow + Vim-native power
-- Neovim 0.11+
-- =========================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Multi-cursor VSCode-like
-- VSCode Ctrl+D ~= Neovim Ctrl+D with vim-visual-multi
vim.g.VM_maps = {
	["Find Under"] = "<C-d>",
	["Find Subword Under"] = "<C-d>",
}

-- =========================================================
-- Basic options
-- =========================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.timeoutlen = 300

vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

-- Blade file detection
vim.filetype.add({
	pattern = {
		[".*%.blade%.php"] = "blade",
	},
})

-- =========================================================
-- Bootstrap lazy.nvim
-- =========================================================
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- Plugins
-- =========================================================
require("lazy").setup({
	-- Theme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	-- Icons
	{ "nvim-tree/nvim-web-devicons" },

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "tokyonight",
				globalstatus = true,
			},
		},
	},

	-- Buffer tabs
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				separator_style = "thin",
				show_buffer_close_icons = true,
				show_close_icon = false,
			},
		},
	},

	-- Dashboard
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				[[                                            ]],
				[[  __ _ ___ _   _ _ __ __ _  / _| ___| (_)   ]],
				[[ / _` / __| | | | '__/ _` || |_ / __| | |   ]],
				[[| (_| \__ \ |_| | | | (_| ||  _| (__| | |   ]],
				[[ \__,_|___/\__, |_|  \__,_||_|  \___|_|_|   ]],
				[[           |___/                            ]],
				[[                                            ]],
				[[         ASYRAFCLI - ARCH NEOVIM            ]],
			}

			dashboard.section.buttons.val = {
				dashboard.button("f", "Find file", ":Telescope find_files<CR>"),
				dashboard.button("g", "Search text", ":Telescope live_grep<CR>"),
				dashboard.button("e", "Explorer", ":NvimTreeToggle<CR>"),
				dashboard.button("n", "New file", ":ene <BAR> startinsert<CR>"),
				dashboard.button("q", "Quit", ":qa<CR>"),
			}

			alpha.setup(dashboard.config)
		end,
	},

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				disable_netrw = true,
				hijack_netrw = true,
				view = {
					width = 34,
					side = "left",
				},
				filters = {
					dotfiles = false,
				},
				git = {
					ignore = false,
				},
				renderer = {
					group_empty = true,
					highlight_git = true,
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
					},
				},
				actions = {
					open_file = {
						quit_on_open = false,
					},
				},
			})
		end,
	},

	-- Fuzzy finder / search
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				defaults = {
					file_ignore_patterns = {
						"node_modules/",
						".git/",
						"vendor/",
						"storage/framework/",
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
				},
			})

			-- VSCode-like
			vim.keymap.set("n", "<C-p>", function()
				builtin.find_files({ hidden = true })
			end, { desc = "Find files like VSCode Ctrl+P" })

			vim.keymap.set("n", "<C-f>", builtin.current_buffer_fuzzy_find, {
				desc = "Find in current file like VSCode Ctrl+F",
			})

			vim.keymap.set("n", "<C-S-f>", builtin.live_grep, {
				desc = "Search in project like VSCode Ctrl+Shift+F",
			})

			-- Vim-style fallback
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({ hidden = true })
			end, { desc = "Find files" })

			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })

			vim.keymap.set("n", "<leader>fw", function()
				builtin.grep_string({ search = vim.fn.expand("<cword>") })
			end, { desc = "Search word under cursor in project" })
		end,
	},

	-- Terminal inside Neovim
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 15,
				open_mapping = [[<C-\>]],
				direction = "horizontal",
				shade_terminals = true,
				start_in_insert = true,
			})
		end,
	},

	-- Multi-cursor like VSCode Ctrl+D
	{
		"mg979/vim-visual-multi",
		branch = "master",
	},

	-- Better syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				prefer_git = true,
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"php",
					"html",
					"css",
					"javascript",
					"typescript",
					"json",
					"go",
					"bash",
				},
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
				},
			})
		end,
	},

	-- Comments: gcc / gc
	{
		"numToStr/Comment.nvim",
		opts = {},
	},

	-- Auto pairs: (), {}, [], "", ''
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Git signs like VSCode gutter
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				php = { "pint" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				lua = { "stylua" },
			},
			format_on_save = function(bufnr)
				local ft = vim.bo[bufnr].filetype
				local enabled = {
					php = true,
					javascript = true,
					typescript = true,
					javascriptreact = true,
					typescriptreact = true,
					html = true,
					css = true,
					json = true,
					lua = true,
				}

				if enabled[ft] then
					return {
						timeout_ms = 3000,
						lsp_format = "fallback",
					}
				end
			end,
		},
	},

	-- Mason
	{ "mason-org/mason.nvim", opts = {} },

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				"gopls",
				"intelephense",
				"lua_ls",
				"ts_ls",
				"html",
				"cssls",
				"jsonls",
				"emmet_language_server",
			},
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"prettier",
				"stylua",
			},
		},
	},

	-- Completion
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "L3MON4D3/LuaSnip" },
	{ "saadparwaiz1/cmp_luasnip" },
	{ "rafamadriz/friendly-snippets" },

	-- LSP configs
	{ "neovim/nvim-lspconfig" },
}, {
	ui = {
		border = "rounded",
	},
})

-- =========================================================
-- Keymaps: VSCode-like
-- =========================================================

-- Save
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
vim.keymap.set("v", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file" })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Copy / Cut / Paste with system clipboard
vim.keymap.set("n", "<C-c>", '"+yy', { desc = "Copy line" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection" })

vim.keymap.set("n", "<C-x>", '"+dd', { desc = "Cut line" })
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut selection" })

vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste" })
vim.keymap.set("v", "<C-v>", '"+p', { desc = "Paste over selection" })

-- Since Ctrl+V is paste now, use Ctrl+Q for visual block mode
vim.keymap.set("n", "<C-q>", "<C-v>", { desc = "Visual block mode" })

-- Undo / Redo
vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
vim.keymap.set("i", "<C-z>", "<C-o>u", { desc = "Undo" })

vim.keymap.set("n", "<C-y>", "<C-r>", { desc = "Redo" })
vim.keymap.set("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })

-- Comment like VSCode Ctrl+/
-- Most terminals send Ctrl+/ as Ctrl+_
vim.keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment selection" })

-- Explorer
vim.keymap.set("n", "<C-e>", "<cmd>NvimTreeToggle<CR>", {
	silent = true,
	desc = "Toggle file explorer",
})

-- Buffers like tabs
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Indent selected lines
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent selection" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })

-- Terminal
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "Vertical terminal" })
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Floating terminal" })

-- Split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])

-- Replace word under cursor with confirmation
vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]], {
	desc = "Replace word under cursor",
})

-- =========================================================
-- Auto-save
-- =========================================================
local autosave_group = vim.api.nvim_create_augroup("AutoSave", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	group = autosave_group,
	callback = function()
		if vim.bo.buftype ~= "" then
			return
		end
		if vim.bo.readonly or not vim.bo.modifiable then
			return
		end
		if not vim.bo.modified then
			return
		end

		local name = vim.fn.expand("%:p")
		if name == "" then
			return
		end

		local ft = vim.bo.filetype
		if ft == "NvimTree" or ft == "alpha" then
			return
		end

		pcall(vim.cmd, "silent! write")
	end,
})

-- =========================================================
-- nvim-cmp autocomplete
-- =========================================================
local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),

		["<CR>"] = cmp.mapping.confirm({
			select = true,
		}),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}),
})

-- Autopairs + cmp integration
pcall(function()
	local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end)

-- =========================================================
-- LSP
-- =========================================================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function on_attach(_, bufnr)
	local opts = { buffer = bufnr, silent = true }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

	vim.keymap.set("n", "<leader>fm", function()
		require("conform").format({
			async = false,
			timeout_ms = 3000,
			lsp_format = "fallback",
		})
	end, { buffer = bufnr, desc = "Format file" })
end

local servers = {
	gopls = {
		settings = {
			gopls = {
				gofumpt = true,
				staticcheck = true,
				analyses = {
					unusedparams = true,
					nilness = true,
					shadow = true,
				},
			},
		},
	},

	intelephense = {
		settings = {
			intelephense = {
				files = {
					maxSize = 5000000,
				},
			},
		},
	},

	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},

	ts_ls = {},

	html = {
		filetypes = { "html", "blade" },
	},

	cssls = {},

	jsonls = {},

	emmet_language_server = {
		filetypes = {
			"html",
			"css",
			"php",
			"blade",
			"javascriptreact",
			"typescriptreact",
		},
	},
}

for name, config in pairs(servers) do
	config.capabilities = capabilities
	config.on_attach = on_attach

	pcall(vim.lsp.config, name, config)
	pcall(vim.lsp.enable, name)
end

-- Go format on save
vim.g.go_format_on_save = true

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		if not vim.g.go_format_on_save then
			return
		end
		pcall(vim.lsp.buf.format, { async = false })
	end,
})

-- Diagnostics
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, {
	desc = "Show diagnostic under cursor",
})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
	desc = "Previous diagnostic",
})

vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
	desc = "Next diagnostic",
})

vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, {
	desc = "Diagnostics to loclist",
})

-- ============================================================
-- File path shortcuts
-- ============================================================

local function notify_path(label, value)
	vim.notify(label .. ": " .. value)
end

vim.keymap.set("n", "<leader>fp", function()
	notify_path("Relative path", vim.fn.expand("%"))
end, { desc = "Show relative file path" })

vim.keymap.set("n", "<leader>fP", function()
	notify_path("Full path", vim.fn.expand("%:p"))
end, { desc = "Show full file path" })

vim.keymap.set("n", "<leader>fc", function()
	local path = vim.fn.expand("%")
	vim.fn.setreg("+", path)
	notify_path("Copied relative path", path)
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>fC", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	notify_path("Copied full path", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>fd", function()
	notify_path("File directory", vim.fn.expand("%:p:h"))
end, { desc = "Show file directory" })

vim.keymap.set("n", "<leader>fD", function()
	local path = vim.fn.expand("%:p:h")
	vim.fn.setreg("+", path)
	notify_path("Copied file directory", path)
end, { desc = "Copy file directory" })
