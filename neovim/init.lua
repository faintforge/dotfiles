--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

vim.opt.termguicolors = true

vim.g.c_syntax_for_h = true
vim.opt.winborder = "rounded"
vim.opt.wrap = false

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocallreader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set({"n", "v"}, "<leader>y", "\"+y")
vim.keymap.set({"n", "v"}, "<leader>Y", "\"+y$")
vim.keymap.set({"n", "v"}, "<leader>p", "\"+p")
vim.keymap.set({"n", "v"}, "<leader>P", "\"+P")

vim.keymap.set("n", "<leader>nh", ":noh<CR>")

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww fzftmux<CR>");

--------------------------------------------------------------------------------
-- Commands
--------------------------------------------------------------------------------

-- vim.api.nvim_create_user_command("Now", ':pu=strftime(\'%Y-%m-%d %H:%M:%S\')', {})
vim.api.nvim_create_user_command("Now", function()
    local timestamp = vim.fn.strftime('%Y-%m-%d %H:%M:%S')
    vim.api.nvim_put({timestamp}, 'c', true, true)
end, {})

--------------------------------------------------------------------------------
-- Lazy
--------------------------------------------------------------------------------

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------

require("lazy").setup({
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        lazy = false,
        opts = {},
        config = function ()
            -- Default options:
            require("gruvbox").setup({
                terminal_colors = true, -- add neovim terminal colors
                undercurl = true,
                underline = true,
                bold = true,
                italic = {
                    strings = true,
                    emphasis = true,
                    comments = true,
                    operators = false,
                    folds = true,
                },
                strikethrough = true,
                invert_selection = false,
                invert_signs = false,
                invert_tabline = false,
                inverse = true, -- invert background for search, diffs, statuslines and errors
                contrast = "", -- can be "hard", "soft" or empty string
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                transparent_mode = true,
            })
            vim.cmd("colorscheme gruvbox")
        end
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- optional but recommended
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-file-browser.nvim"
        },
        config = function()
            local telescope = require("telescope") 
            telescope.setup({
                pickers = {
                    find_files = {
                        find_command = { "rg", "-L", "--files", "--hidden", "--glob", "!**/.git/*" }
                    },
                },
                extensions = {
                    file_browser = {
                        hijack_netrw = true,
                        hidden = { file_browser = true, folder_browser = true, },
                        follow_symlinks = true,
                    },
                },
            })
            telescope.load_extension("file_browser")

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>pf", builtin.find_files)
            vim.keymap.set("n", "<leader>ps", function ()
                builtin.live_grep({additional_args = {"-U"}})
            end)
            vim.keymap.set("n", "<leader>pt", builtin.treesitter)
            vim.keymap.set("n", "<leader>pv", telescope.extensions.file_browser.file_browser)
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        version = false,
        branch = "main",
        build = ":TSUpdate",
        opts = {},
        config = function ()
            require("nvim-treesitter").install({ "c", "lua", "luadoc", "vimdoc", "query" })

            vim.api.nvim_create_autocmd('FileType', {
              pattern = { '*' },
              callback = function(args)
                  local ft = vim.bo[args.buf].filetype
                  if ft == "" then
                      return
                  end
                  pcall(function()
                      local lang = vim.treesitter.get_lang(ft) or ft
                      ts.install({lang})
                  end)
                  pcall(vim.treesitter.start, args.buf)
              end,
            })
        end
    },
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with "keys" is recommended in
        -- order to load the plugin when the command is run for the first time
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
        }
    },
    {
        "numToStr/Comment.nvim",
        config = function ()
            require("Comment").setup()
        end
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function ()
            -- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
            vim.keymap.set("n", "gl", vim.diagnostic.open_float);
            vim.keymap.set("n", "[d", function () vim.diagnostic.jump({count=1, float=true}) end)
            vim.keymap.set("n", "]d", function () vim.diagnostic.jump({count=-1, float=true}) end)
            vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }
                    local builtin = require("telescope.builtin")
                    vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>pd", builtin.lsp_document_symbols, opts)
                end,
            })

            require("mason-lspconfig").setup({
                ensure_installed = { "clangd" },
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        require("lspconfig")[server_name].setup(server)
                    end
                },
            })
        end
    },
    {
        "andweeb/presence.nvim",
        lazy = false,
        config = function()
            -- The setup config table shows all available config options with their default values:
            require("presence").setup({
                -- General options
                auto_update         = true,                       -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
                neovim_image_text   = "The One True Text Editor", -- Text displayed when hovered over the Neovim image
                main_image          = "file",                   -- Main image display (either "neovim" or "file")
                -- client_id           = "793271441293967371",       -- Use your own Discord application client id (not recommended)
                log_level           = nil,                        -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
                debounce_timeout    = 10,                         -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
                enable_line_number  = false,                      -- Displays the current line number instead of the current project
                blacklist           = {},                         -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
                buttons             = true,                       -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
                file_assets         = {},                         -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
                show_time           = true,                       -- Show the timer

                -- Rich Presence text options
                editing_text        = "Editing %s",               -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
                file_explorer_text  = "Browsing %s",              -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
                git_commit_text     = "Committing changes",       -- Format string rendered when committing changes in git (either string or function(filename: string): string)
                plugin_manager_text = "Managing plugins",         -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
                reading_text        = "Reading %s",               -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
                workspace_text      = "Working on %s",            -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
                line_number_text    = "Line %s out of %s",        -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
            })
        end
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {}
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",

            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip"
        },
        config = function ()
            -- Set up nvim-cmp.
            local cmp = require"cmp"
            local luasnip = require"luasnip"

            cmp.setup({
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                        -- require("snippy").expand_snippet(args.body) -- For `snippy` users.
                        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

                        -- For `mini.snippets` users:
                        -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
                        -- insert({ body = args.body }) -- Insert at cursor
                        -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
                        -- require("cmp.config").set_onetime({ sources = {} })
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ["<C-f>"] = cmp.mapping(function (fallback)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    ["<C-b>"] = cmp.mapping(function (fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    -- { name = "vsnip" }, -- For vsnip users.
                    { name = "luasnip" }, -- For luasnip users.
                    -- { name = "ultisnips" }, -- For ultisnips users.
                    -- { name = "snippy" }, -- For snippy users.
                }, {
                    { name = "buffer" },
                })
            })

            -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
            -- Set configuration for specific filetype.
            --[[ cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "git" },
                }, {
                    { name = "buffer" },
                })
            })
            require("cmp_git").setup() ]]--

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won"t work anymore).
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" }
                }
            })

            -- Use cmdline & path source for ":" (if you enabled `native_menu`, this won"t work anymore).
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" }
                }, {
                    { name = "cmdline" }
                }),
                matching = { disallow_symbol_nonprefix_matching = false }
            })
        end
    },
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
        config = function ()
            local ls = require("luasnip");

            local s = ls.snippet
            local i = ls.insert_node
            local t = ls.text_node
            local f = ls.function_node

            local function endif_fn(
                args,
                parent,
                user_args
                )
                return "#endif // " .. args[1][1]
            end

            local function user_input(
                args,
                parent,
                user_args
                )
                return args[1][1]
            end

            ls.add_snippets("c", {
                s("ifdef", {
                    t("#ifdef "), i(1),
                    t({"", ""}), i(0),
                    t({"", ""}),
                    i(""), f(endif_fn, {1}, {})
                }),
                s("ifndef", {
                    t("#ifndef "), i(1),
                    t({"", ""}), i(0),
                    t({"", ""}),
                    i(""), f(endif_fn, {1}, {})
                }),
                s("tds", {
                    t("typedef struct "), f(user_input, {1}, {}), t(" "), f(user_input, {1}, {}), t(";"),
                    t({"", "struct "}), i(1), t(" {"),
                    t({"", "    "}), i(0),
                    t({"", "};"})
                }),
                s("tdu", {
                    t("typedef union "), f(user_input, {1}, {}), t(" "), f(user_input, {1}, {}), t(";"),
                    t({"", "union "}), i(1), t(" {"),
                    t({"", "    "}), i(0),
                    t({"", "};"})
                }),
                s("tde", {
                    t("typedef enum "), f(user_input, {1}, {}), t(" {"),
                    t({"", "    "}), i(0),
                    t({"", "} "}), i(1), t(";"),
                }),
            })
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        config = function ()
            require("lualine").setup({
                options = { theme = "auto" }
            })
        end
    },
}, {
    checker = { enabled = true }
})
