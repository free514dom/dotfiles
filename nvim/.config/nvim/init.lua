-- nvim/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

require("lazy").setup({
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        opts = {
            on_colors = function(colors)
                colors.bg = "#000000"
            end,
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "json", "bash", "yaml", "toml", "markdown", "markdown_inline",
                    "java", -- [新增] 添加 java 语法高亮支持
                },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                },
            })
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = { "%.git/" },
                },
            })
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- 导航
                map("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Git: Next Hunk" })

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Git: Prev Hunk" })

                map("n", "<leader>p", gs.preview_hunk, { desc = "Git: Preview Hunk" })
                map("n", "<leader>l", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame Line" })
            end,
        },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = { lua = { "stylua" }, markdown = { "prettier" } },
            format_on_save = nil,
        },
    },
    { "tpope/vim-repeat" },
    { "pocco81/auto-save.nvim", event = "VeryLazy", opts = {} },
    {
        "ggandor/leap.nvim",
        event = "VeryLazy",
        dependencies = { "tpope/vim-repeat" },
        config = function()
            local leap = require("leap")
            leap.opts.preview = function(ch0, ch1, ch2)
                return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
            end
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Motion: Leap forward" })
            vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Motion: Leap windows" })
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        dependencies = {
            -- [新增] nvim-java 必须作为依赖引入
            { "nvim-java/nvim-java" },
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "L3MON4D3/LuaSnip" },
            { "windwp/nvim-autopairs" },
        },
        config = function()
            -- [关键修改] nvim-java 要求在 lspconfig 设置之前进行 setup
            require('java').setup()

            local lsp_zero = require("lsp-zero")
            lsp_zero.on_attach(function(client, bufnr)
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(
                        mode,
                        lhs,
                        rhs,
                        { buffer = bufnr, noremap = true, silent = true, desc = desc }
                    )
                end
                map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
                map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
                map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
                map("n", "gr", vim.lsp.buf.references, "Goto References")

                map("n", "<leader>a", vim.lsp.buf.code_action, "LSP: Code Action")
                map("n", "<leader>r", vim.lsp.buf.rename, "LSP: Rename Symbol")
                map({ "n", "v" }, "<leader>e", vim.diagnostic.open_float, "LSP: Show Diagnostics")
                
                -- [新增] 仅在 Java 文件中绑定的快捷键
                if client.name == "jdtls" then
                   -- 你可以在这里添加 nvim-java 专属的快捷键，例如:
                   -- map("n", "<leader>tm", require('java').test.run_current_method, "Java: Test Method")
                   -- map("n", "<leader>tc", require('java').test.run_current_class, "Java: Test Class")
                end
            end)

            require("mason").setup({})
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "jsonls",
                    "bashls",
                    "yamlls",
                    "taplo",
                    "lua_ls",
                    "jdtls", -- [新增] 确保安装 Java 语言服务器
                },
                automatic_installation = true,
                handlers = {
                    lsp_zero.default_setup,
                    -- 注意：lsp-zero 的默认处理器会自动调用 require('lspconfig').jdtls.setup({})
                    -- 这正是 nvim-java 所需要的（在 java.setup() 之后调用）。
                },
            })

            local cmp = require("cmp")
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            cmp.setup({
                sources = { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" } },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
            })
        end,
    },
})

-- ==================== 基础选项 ====================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
vim.opt.mouse = "a"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undofile = true
vim.o.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==================== 基础快捷键 ====================
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Motion: Move down visual" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Motion: Move up visual" })
vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

vim.keymap.set("n", "<leader>f", function() require("telescope.builtin").find_files({ hidden = true }) end,
    { desc = "Find: Files" })
vim.keymap.set("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find: Buffers" })
vim.keymap.set("n", "<leader>g", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Find: Text (Grep)" })
vim.keymap.set("n", "<leader>h", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find: Help" })

vim.keymap.set({ "n", "v" }, "<leader>m", function() require("conform").format({ async = true, lsp_fallback = true }) end,
    { desc = "Code: Format File" })

vim.keymap.set("n", "<leader>w", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "UI: Toggle Wrap" })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostic: Prev" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostic: Next" })

vim.keymap.set("n", "M", "daw", { desc = "Edit: Delete Word" })
vim.keymap.set("n", "Q", "ciw", { desc = "Edit: Change Word" })

vim.cmd("colorscheme tokyonight")
