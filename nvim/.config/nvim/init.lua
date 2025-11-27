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

-- 设置 leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 自动安装 coc 扩展
-- [包含]: coc-pyright (Python 语言服务)
vim.g.coc_global_extensions = {
    'coc-java',
    'coc-json',
    'coc-lua',
    'coc-vimlsp',
    'coc-sh',
    'coc-yaml',
    'coc-toml',
    'coc-prettier',
    'coc-pyright',  -- Python LSP (补全、定义跳转、类型检查)
    'coc-snippets'
}

require("lazy").setup({
    -- 主题
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        lazy = false, -- 确保在启动时加载，不要延迟
        config = function()
            -- 在这里设置透明选项
            require("tokyonight").setup({
                style = "storm", -- 主题风格，可选 "storm", "moon", "night", "day"
                transparent = true, -- <--- 核心：开启透明背景
                styles = {
                    sidebars = "transparent", -- 文件树等侧边栏透明
                    floats = "transparent",   -- 浮动窗口透明
                },
            })
            -- 在配置完成后直接加载主题
            vim.cmd("colorscheme tokyonight")
        end,
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
                -- [包含]: python
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query", "java",
                    "json", "bash", "yaml", "toml", "markdown", "markdown_inline",
                    "python", -- Python 语法高亮
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
                    file_ignore_patterns = { "%.git/", "__pycache__" }, -- 忽略 Python 缓存
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

                map("n", "<leader>gp", gs.preview_hunk, { desc = "Git: Preview Hunk" })
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame Line" })
            end,
        },
    },
    -- LazyGit
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Git: LazyGit" }
        }
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
    -- 自动括号插件
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                map_cr = false -- 禁止它接管回车键，交给 Coc 处理
            })
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

    -- ==================== COC.NVIM ====================
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            local keyset = vim.keymap.set
            local opts = { silent = true, noremap = true, expr = true, replace_keycodes = true }

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

            -- [重命名] 标准化为 <leader>rn
            keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true, desc = "LSP: Rename" })

            -- [代码操作] 标准化为 <leader>ca
            keyset("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", { silent = true, desc = "LSP: Code Action" })
            keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true, desc = "LSP: Code Action (Selected)" })

            -- [格式化] 标准化为 <leader>cf
            keyset("n", "<leader>cf", "<Plug>(coc-format)", { silent = true, desc = "Code: Format File" })

            -- [诊断]
            keyset("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true, desc = "Diagnostic: Prev" })
            keyset("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true, desc = "Diagnostic: Next" })
            keyset("n", "<leader>e", ":CocList diagnostics<CR>", { silent = true, desc = "LSP: Show Diagnostics List" })

            -- [组织导入] 标准化为 <leader>ci
            keyset("n", "<leader>ci", ":call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>", { silent = true, desc = "Code: Organize Imports" })
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
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"

-- ==================== 基础快捷键 ====================
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Motion: Move down visual" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Motion: Move up visual" })

-- [恢复] 强制禁用方向键 (Hard Mode)
vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

-- Telescope 搜索 (标准化 Leader 前缀: f=File/Find)
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, { desc = "Find: Files" })
vim.keymap.set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find: Buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Find: Text (Grep)" })
vim.keymap.set("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find: Help" })

-- UI Toggle
vim.keymap.set("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "UI: Toggle Wrap" })

-- [恢复] 自定义 M/Q 映射
vim.keymap.set("n", "M", "daw", { desc = "Edit: Delete Word" })
vim.keymap.set("n", "Q", "ciw", { desc = "Edit: Change Word" })

