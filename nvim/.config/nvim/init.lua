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
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua",
                    "vim",
                    "vimdoc",
                    "query",
                    "rust",
                    "python",
                    "json",
                    "bash",
                    "yaml",
                    "toml",
                    "markdown",
                    "markdown_inline",
                },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
            })
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    -- 这样即使使用 find 命令, 也会忽略 .git 目录
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
        config = function()
            require("gitsigns").setup()
        end,
    },
    { "kdheepak/lazygit.nvim", cmd = "LazyGit" },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = { lua = { "stylua" }, markdown = { "prettier" } },
            format_on_save = { timeout_ms = 1500, lsp_fallback = true },
        },
    },

    { "tpope/vim-repeat" },

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
                map("n", "gd", vim.lsp.buf.definition, "跳转到定义")
                map("n", "gD", vim.lsp.buf.declaration, "跳转到声明")
                map("n", "K", vim.lsp.buf.hover, "显示悬浮文档")
                map("n", "gi", vim.lsp.buf.implementation, "跳转到实现")
                map("n", "gr", vim.lsp.buf.references, "查找引用")
                -- *** 修改过的LSP快捷键 ***
                map("n", "<leader>7", vim.lsp.buf.code_action, "代码操作") -- (保持不变)
                map("n", "<leader>6", vim.lsp.buf.rename, "重命名符号") -- (保持不变)
                map({ "n", "v" }, "<leader>8", vim.diagnostic.open_float, "显示诊断信息") -- (从 leader+5 移动到 leader+8)
                -- ***********************
            end)

            require("mason").setup({})

            local mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({
                ensure_installed = {
                    "rust_analyzer",
                    "jsonls",
                    "bashls",
                    "yamlls",
                    "taplo",
                    "lua_ls",
                    "pyright",
                },
                handlers = {
                    lsp_zero.default_setup,
                },
            })

            local cmp = require("cmp")
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

vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down by visual line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up by visual line" })

vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

-- =========== 修改后的快捷键 =============
-- Telescope
vim.keymap.set("n", "<leader>2", function()
    require("telescope.builtin").find_files({ hidden = true })
end, { desc = "查找文件 (含隐藏)" })
vim.keymap.set("n", "<leader>3", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "查找缓冲区" })
vim.keymap.set("n", "<leader>4", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "全局文本搜索" })
vim.keymap.set("n", "<leader>5", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "查找帮助文档" })

-- 其他顺移的快捷键
vim.keymap.set({ "n", "v" }, "<leader>9", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "格式化文件" })
vim.keymap.set("n", "<leader>0", function()
    vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "切换自动换行" })
-- =====================================

-- 未发生冲突，保持不变的快捷键
vim.keymap.set("n", "<leader>1", "<cmd>LazyGit<cr>", { desc = "打开 Lazygit" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "跳转到上一个诊断" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "下一个诊断" })


vim.cmd("colorscheme tokyonight")
