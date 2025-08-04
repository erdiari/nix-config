-- Indentation lines configuration
return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = true,
        injected_languages = false,
        highlight = { 'Function', 'Label' },
        priority = 500,
      },
      exclude = {
        filetypes = {
          'help',
          'alpha',
          'dashboard',
          'neo-tree',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
      },
    },
    config = function(_, opts)
      require('ibl').setup(opts)

      -- Toggle indentation lines
      vim.keymap.set('n', '<leader>ti', '<cmd>IBLToggle<cr>', { desc = 'Toggle indentation lines' })

      -- Toggle scope highlighting
      vim.keymap.set('n', '<leader>ts', '<cmd>IBLToggleScope<cr>', { desc = 'Toggle scope highlighting' })
    end,
  },
}
