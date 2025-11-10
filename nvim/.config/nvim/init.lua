local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- 如果 lazy.nvim 未安装，则从 GitHub 克隆
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- 使用 stable 分支
        lazypath,
    })
end
-- 将 lazy.nvim 添加到运行时路径 (runtimepath) 的头部
vim.opt.rtp:prepend(lazypath)
-- 使用 lazy.nvim 设置并加载插件
require("lazy").setup({
    -- 主题方案
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        opts = {
            on_colors = function(colors)
                colors.bg = "#000000"
            end,
        },
    },

    -- nvim-treesitter
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

    -- 基础插件
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
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
        event = "VeryLazy", -- 延迟加载，提高启动速度
        dependencies = { "tpope/vim-repeat" },
        config = function()
            local leap = require("leap")

            -- [强烈推荐] 来自官方文档的优化：减少预览时的视觉噪音。
            -- 这会让界面更清爽，但你仍然可以跳转到任何位置。
            leap.opts.preview = function(ch0, ch1, ch2)
                return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
            end

            -- 设置核心快捷键 (官方文档推荐)
            -- s      -> 在当前窗口内瞬移
            -- S      -> 在所有可见窗口之间瞬移
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap: 瞬移到2字符" })
            vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Leap: 跨窗口瞬移" })
            -- 解释：原生的 s (cl) 和 S (cc) 都有替代命令，
            -- 而 leap 是一个超高频操作，用 s 键位非常舒适且高效。
        end,
    },
    -- LSP (语言服务器协议) 快速配置: lsp-zero
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
                map("n", "<leader>ca", vim.lsp.buf.code_action, "代码操作")
                map("n", "<leader>rn", vim.lsp.buf.rename, "重命名符号")
                map({ "n", "v" }, "<leader>df", vim.diagnostic.open_float, "显示诊断信息")
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

-- =============================================================================
-- 2. 通用编辑器选项
-- =============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- 自动换行设置 (默认关闭)
vim.opt.wrap = false -- 默认关闭自动换行
vim.opt.linebreak = true -- 当开启换行时，不在单词中间断行
vim.opt.showbreak = "↪ " -- 当开启换行时，在行首显示标记

vim.opt.mouse = "a"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undofile = true
vim.o.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- =============================================================================
-- 3. 全局变量与快捷键映射
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 让 j 和 k 按照可视行移动，这对于处理自动换行的文本非常重要
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down by visual line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up by visual line" })

vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

vim.keymap.set("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", { desc = "查找文件" })
vim.keymap.set(
    "n",
    "<leader>fg",
    "<cmd>lua require('telescope.builtin').live_grep()<cr>",
    { desc = "全局文本搜索" }
)
vim.keymap.set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "查找缓冲区" })
vim.keymap.set(
    "n",
    "<leader>fh",
    "<cmd>lua require('telescope.builtin').help_tags()<cr>",
    { desc = "查找帮助文档" }
)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "跳转到上一个诊断" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "下一个诊断" })
vim.keymap.set({ "n", "v" }, "<leader>fm", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "格式化文件" })

-- 用于切换自动换行的快捷键
vim.keymap.set("n", "<leader>w", function()
    vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "切换自动换行" })

vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "移动到左侧窗口" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "移动到右侧窗口" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "移动到上方窗口" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "移动到下方窗口" })
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "垂直分割窗口" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "水平分割窗口" })

-- =============================================================================
-- 4. 应用主题方案
-- =============================================================================
vim.cmd("colorscheme tokyonight")
