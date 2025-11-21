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
                end, { expr = true, desc = "下一处修改" })

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "上一处修改" })

                -- [修改] Git 操作单字符映射
                map("n", "<leader>p", gs.preview_hunk, { desc = "Git: 预览修改块 (Preview)" })
                map("n", "<leader>B", function() gs.blame_line({ full = true }) end, { desc = "Git: 显示行 Blame" })
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
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap: 瞬移到2字符" })
            vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Leap: 跨窗口瞬移" })
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
            local lsp_zero = require("lsp-zero")
            lsp_zero.on_attach(function(client, bufnr)
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(
                        mode,
                        lhs,
                        rhs,
                        { buffer = bufnr, noremap = true, silent = true, desc = "LSP: " .. desc }
                    )
                end
                -- [保持] 基础 LSP 导航
                map("n", "gd", vim.lsp.buf.definition, "跳转到定义")
                map("n", "gD", vim.lsp.buf.declaration, "跳转到声明")
                map("n", "K", vim.lsp.buf.hover, "显示悬浮文档")
                map("n", "gi", vim.lsp.buf.implementation, "跳转到实现")
                map("n", "gr", vim.lsp.buf.references, "查找引用")

                -- [修改] 使用单字符助记符
                map("n", "<leader>a", vim.lsp.buf.code_action, "代码操作 (Action)")
                map("n", "<leader>r", vim.lsp.buf.rename, "重命名符号 (Rename)")
                map({ "n", "v" }, "<leader>e", vim.diagnostic.open_float, "显示诊断信息 (Error)")
            end)

            require("mason").setup({})
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "jsonls",
                    "bashls",
                    "yamlls",
                    "taplo",
                    "lua_ls",
                },
                automatic_installation = true,
                handlers = {
                    lsp_zero.default_setup,
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
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down by visual line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up by visual line" })
vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

-- [修改] Telescope 单字符映射
vim.keymap.set("n", "<leader>f", function() require("telescope.builtin").find_files({ hidden = true }) end,
    { desc = "查找文件 (Files)" })
vim.keymap.set("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "查找缓冲区 (Buffers)" })
vim.keymap.set("n", "<leader>g", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "全局文本搜索 (Grep)" })
vim.keymap.set("n", "<leader>h", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "查找帮助文档 (Help)" })

-- [修改] 功能性单字符映射
vim.keymap.set({ "n", "v" }, "<leader>F", function() require("conform").format({ async = true, lsp_fallback = true }) end,
    { desc = "格式化文件 (Format)" })
vim.keymap.set("n", "<leader>w", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "切换自动换行 (Wrap)" })

-- 诊断跳转
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "跳转到上一个诊断" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "下一个诊断" })

-- 自定义 M/Q
vim.keymap.set("n", "M", "daw", { desc = "删除一个单词 (daw)" })
vim.keymap.set("n", "Q", "ciw", { desc = "修改一个单词 (ciw)" })

vim.cmd("colorscheme tokyonight")
