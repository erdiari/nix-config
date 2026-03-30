-- Python development configuration
return {
  -- Python debugging support
  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
    },
    config = function()
      local dap_python = require 'dap-python'
      -- Setup debugpy (will be installed by Mason)
      dap_python.setup 'debugpy'
      -- Python-specific keymaps
      vim.keymap.set('n', '<leader>dn', function()
        dap_python.test_method()
      end, { desc = 'Debug: Test Method' })
      vim.keymap.set('n', '<leader>df', function()
        dap_python.test_class()
      end, { desc = 'Debug: Test Class' })
      vim.keymap.set('v', '<leader>ds', function()
        dap_python.debug_selection()
      end, { desc = 'Debug: Selection' })
    end,
  },

  -- Enhanced Python syntax and features
  {
    'linux-cultist/venv-selector.nvim',
    branch = 'regexp',
    dependencies = {
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python',
      { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
    },
    lazy = false,
    opts = {
      settings = {
        search = {
          anaconda_base = {
            command = 'fd -H -I -t d -g "*conda*/envs" ~',
            type = 'anaconda',
          },
          anaconda_envs = {
            command = 'fd -H -I -t d -g "python" ~/anaconda*/envs',
            type = 'anaconda',
          },
          miniconda_envs = {
            command = 'fd -H -I -t d -g "python" ~/miniconda*/envs',
            type = 'miniconda',
          },
          venv = {
            command = 'fd -H -I -t f -g "pyvenv.cfg" ~ --max-depth 4',
            type = 'venv',
          },
          pyenv = {
            command = 'pyenv versions --bare',
            type = 'pyenv',
          },
        },
      },
    },
    keys = {
      { '<leader>vs', '<cmd>VenvSelect<cr>', desc = 'Select Python Virtual Environment' },
      { '<leader>vc', '<cmd>VenvSelectCached<cr>', desc = 'Select Cached Python Virtual Environment' },
    },
  },

  -- Enhanced Python text objects and motions
  {
    'jeetsukumaran/vim-pythonsense',
    ft = 'python',
  },

  -- Python REPL integration
  {
    'jpalardy/vim-slime',
    ft = 'python',
    config = function()
      vim.g.slime_target = 'neovim'
      vim.g.slime_python_ipython = 1
      vim.g.slime_cell_delimiter = '# %%'

      -- Python-specific mappings
      vim.keymap.set('n', '<leader>cc', '<Plug>SlimeSendCell', { desc = 'Send cell to REPL' })
      vim.keymap.set('v', '<leader>cs', '<Plug>SlimeRegionSend', { desc = 'Send selection to REPL' })
      vim.keymap.set('n', '<leader>cl', '<Plug>SlimeLineSend', { desc = 'Send line to REPL' })
    end,
  },

  -- Python docstring generation
  {
    'danymat/neogen',
    ft = 'python',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('neogen').setup {
        languages = {
          python = {
            template = {
              annotation_convention = 'google_docstrings',
            },
          },
        },
      }

      vim.keymap.set('n', '<leader>nf', function()
        require('neogen').generate { type = 'func' }
      end, { desc = 'Generate function docstring' })

      vim.keymap.set('n', '<leader>nc', function()
        require('neogen').generate { type = 'class' }
      end, { desc = 'Generate class docstring' })
    end,
  },

  -- Python testing integration
  {
    'nvim-neotest/neotest',
    ft = 'python',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-python',
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-python' {
            dap = { justMyCode = false },
            runner = 'pytest',
            python = 'python',
          },
        },
      }

      -- Test keymaps
      vim.keymap.set('n', '<leader>tt', function()
        require('neotest').run.run()
      end, { desc = 'Run nearest test' })

      vim.keymap.set('n', '<leader>tf', function()
        require('neotest').run.run(vim.fn.expand '%')
      end, { desc = 'Run current file tests' })

      vim.keymap.set('n', '<leader>td', function()
        require('neotest').run.run { strategy = 'dap' }
      end, { desc = 'Debug nearest test' })

      vim.keymap.set('n', '<leader>ts', function()
        require('neotest').summary.toggle()
      end, { desc = 'Toggle test summary' })

      vim.keymap.set('n', '<leader>to', function()
        require('neotest').output.open { enter = true, auto_close = true }
      end, { desc = 'Show test output' })
    end,
  },

  -- Enhanced folding for Python
  {
    'tmhedberg/SimpylFold',
    ft = 'python',
    config = function()
      vim.g.SimpylFold_docstring_preview = 1
      vim.g.SimpylFold_fold_docstring = 0
    end,
  },

  -- Python-specific snippets
  {
    'rafamadriz/friendly-snippets',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load {
        include = { 'python' },
      }
    end,
  },
}

