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

-- 设置 leader 键 (必须在 lazy setup 之前)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 自动安装 coc 扩展
vim.g.coc_global_extensions = {
    'coc-java',
    'coc-json',
    'coc-lua',
    'coc-vimlsp',
    'coc-sh',
    'coc-yaml',
    'coc-toml',
    'coc-prettier' -- 用于 markdown 等格式化
}

require("lazy").setup({
    -- 主题
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        opts = {
            on_colors = function(colors)
                colors.bg = "#000000"
            end,
        },
    },
    -- Treesitter (语法高亮)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query", "java", -- 确保安装 java
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
    -- Telescope (模糊搜索)
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
    -- Which Key (按键提示)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },
    -- Gitsigns (Git 集成)
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
    -- 基础工具插件
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

    -- ==================== COC.NVIM (替换 LSP-Zero/Mason) ====================
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            -- Coc 配置使用 Vimscript 风格的按键映射较为方便，这里用 lua 封装

            local keyset = vim.keymap.set
            local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }

            -- Tab 键补全选择
            keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
            keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

            -- 回车确认补全
            keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

            -- 辅助函数：检查退格
            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- [LSP 导航]
            keyset("n", "gd", "<Plug>(coc-definition)", { silent = true, desc = "LSP: Definition" })
            keyset("n", "gD", "<Plug>(coc-declaration)", { silent = true, desc = "LSP: Declaration" })
            keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true, desc = "LSP: Implementation" })
            keyset("n", "gr", "<Plug>(coc-references)", { silent = true, desc = "LSP: References" })

            -- [K] 显示文档
            function _G.show_docs()
                local cw = vim.fn.expand('<cword>')
                if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
                    vim.api.nvim_command('h ' .. cw)
                elseif vim.api.nvim_eval('coc#rpc#ready()') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
                end
            end
            keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true, desc = "LSP: Hover" })

            -- [重命名]
            keyset("n", "<leader>r", "<Plug>(coc-rename)", { silent = true, desc = "LSP: Rename" })

            -- [代码操作] (Code Action)
            keyset("n", "<leader>a", "<Plug>(coc-codeaction-cursor)", { silent = true, desc = "LSP: Code Action" })
            keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", { silent = true, desc = "LSP: Code Action (Selected)" })

            -- [格式化] 使用 <leader>m
            keyset("n", "<leader>m", "<Plug>(coc-format)", { silent = true, desc = "Code: Format File" })

            -- [诊断]
            keyset("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true, desc = "Diagnostic: Prev" })
            keyset("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true, desc = "Diagnostic: Next" })
            keyset("n", "<leader>e", ":CocList diagnostics<CR>", { silent = true, desc = "LSP: Show Diagnostics List" })

            -- [Coc 特定功能]
            -- 组织导入 (Java常用)
            keyset("n", "<leader>o", ":call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>", { silent = true, desc = "Code: Organize Imports" })
        end
    }
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
vim.opt.updatetime = 300 -- Coc 推荐设置
vim.opt.signcolumn = "yes"

-- ==================== 基础快捷键 ====================
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Motion: Move down visual" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Motion: Move up visual" })
vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

-- Telescope 搜索
vim.keymap.set("n", "<leader>f", function() require("telescope.builtin").find_files({ hidden = true }) end, { desc = "Find: Files" })
vim.keymap.set("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find: Buffers" })
vim.keymap.set("n", "<leader>g", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Find: Text (Grep)" })
vim.keymap.set("n", "<leader>h", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find: Help" })

vim.keymap.set("n", "<leader>w", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "UI: Toggle Wrap" })

-- 自定义 M/Q
vim.keymap.set("n", "M", "daw", { desc = "Edit: Delete Word" })
vim.keymap.set("n", "Q", "ciw", { desc = "Edit: Change Word" })

vim.cmd("colorscheme tokyonight")
