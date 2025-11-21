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
            "nvim-treesitter/nvim-treesitter-textobjects", -- [新增] 文本对象支持
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
                -- [新增] 文本对象配置
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,               -- 自动跳转到下一个文本对象
                        keymaps = {
                            ["af"] = "@function.outer", -- 选中函数(含外围)
                            ["if"] = "@function.inner", -- 选中函数(仅内容)
                            ["ac"] = "@class.outer",    -- 选中类(含外围)
                            ["ic"] = "@class.inner",    -- 选中类(仅内容)
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
    -- 已删除 folke/which-key.nvim 相关的代码块
    {
        "lewis6991/gitsigns.nvim",
        -- [修改] 改用 opts 配置并添加快捷键
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
                end, { expr = true, desc = "跳转到下一处修改" })

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "跳转到上一处修改" })

                -- 常用操作
                map("n", "<leader>hp", gs.preview_hunk, { desc = "预览修改块" })
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "显示行 Blame" })
            end,
        },
    },
    -- 已删除 kdheepak/lazygit.nvim
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = { lua = { "stylua" }, markdown = { "prettier" } },
            -- [修改] 禁用保存时自动格式化，解决撤销回弹问题
            -- 请使用 <leader>9 手动格式化
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
    -- [新增] nvim-surround: 快速增删改成对符号 (ys, ds, cs)
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    -- [新增] indent-blankline: 显示缩进线
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
                map("n", "gd", vim.lsp.buf.definition, "跳转到定义")
                map("n", "gD", vim.lsp.buf.declaration, "跳转到声明")
                map("n", "K", vim.lsp.buf.hover, "显示悬浮文档")
                map("n", "gi", vim.lsp.buf.implementation, "跳转到实现")
                map("n", "gr", vim.lsp.buf.references, "查找引用")
                map("n", "<leader>7", vim.lsp.buf.code_action, "代码操作")
                map("n", "<leader>6", vim.lsp.buf.rename, "重命名符号")
                map({ "n", "v" }, "<leader>8", vim.diagnostic.open_float, "显示诊断信息")
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
vim.opt.wrap = false     -- 默认不换行，配合 linebreak
vim.opt.linebreak = true -- 开启智能断行，仅在开启 wrap 时生效
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

-- Telescope
vim.keymap.set("n", "<leader>2", function() require("telescope.builtin").find_files({ hidden = true }) end,
    { desc = "查找文件 (含隐藏)" })
vim.keymap.set("n", "<leader>3", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "查找缓冲区" })
vim.keymap.set("n", "<leader>4", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "全局文本搜索" })
vim.keymap.set("n", "<leader>5", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "查找帮助文档" })

-- 其他
vim.keymap.set({ "n", "v" }, "<leader>9", function() require("conform").format({ async = true, lsp_fallback = true }) end,
    { desc = "格式化文件" })
vim.keymap.set("n", "<leader>0", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "切换自动换行" })
-- 已删除 Lazygit 快捷键 <leader>1
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "跳转到上一个诊断" })
vim.keymap.set("n", "]", vim.diagnostic.goto_next, { desc = "下一个诊断" })

-- 你自定义的 M/Q
vim.keymap.set("n", "M", "daw", { desc = "删除一个单词 (daw)" })
vim.keymap.set("n", "Q", "ciw", { desc = "修改一个单词 (ciw)" })

vim.cmd("colorscheme tokyonight")
