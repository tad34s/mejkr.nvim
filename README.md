`mejkr.nvim` is a Neovim plugin for quickly executing and building code. It lets you easily define short scripts and run them from Neovim. You can also configure these scripts per file extension and per project.

## Usage

To define the commands you wish to run, use `:MejkrEdit` or the default keybind `<leader>mc`. This opens a dedicated buffer for writing your instructions, which can then be executed with `:MejkrRun` or `<leader>mx`. Output appears in a separate buffer for easy yanking. Toggle this output pane with `:MejkrToggleOutput` or `<leader>M`.

For convenience, default configurations (some included) can be set in your config based on file type. Use `:MejkrRunFile` or `<leader>mr` to launch the appropriate instruction set for your current file.

If no new instructions are written via `:MejkrEdit`, then `:MejkrRun` will repeat the last execution. This allows you to rerun a file without switching back to it.

You can also save your setups per project. After writing them with `:MejkrEdit`, run `:MejkrSave` or `<leader>ms` to store the command list in a file named for your working directory. Reopening the project will pre-load these saved instructions. Manage your stored presets with `:MejkrManageSavedCommands` or `<leader>mm`.


## Installation

To install with `lazy` add this to your configuration.

```lua
return {
  "tad34s/mejkr.nvim",
  opts = {},
}
```

## Configuration

Here is how you can configure `mejkr`:

```lua
return {
  "tad34s/mejkr.nvim",
  opts = {
    -- you can add run configurations like so
    run_configs = {
      -- here is a configuration for typst (.typ)
      -- the function takes in the file path of the current file and returns a table of strings (commands).
      typ = function(fp)
        local dir = vim.fn.fnamemodify(fp, ":h")
        local filename_no_ext = vim.fn.fnamemodify(fp, ":t:r")
        local outpath = dir .. "/" .. filename_no_ext

        return { "typst watch " .. fp .. " & zathura " .. filename_no_ext .. ".pdf" }
      end,
      -- another example
      cpp = function(fp)
        local dir = vim.fn.fnamemodify(fp, ":h")
        local filename_no_ext = vim.fn.fnamemodify(fp, ":t:r")
        local outpath = dir .. "/" .. filename_no_ext

        local compile_cmd = string.format(
          "g++ -std=c++20 -Wall -pedantic -Wno-long-long -Werror %s -o %s",
          vim.fn.shellescape(fp),
          vim.fn.shellescape(outpath)
        )

        local run_cmd = vim.fn.shellescape(outpath)

        return { compile_cmd, run_cmd }
      end,
    },

    -- you can also modify keymaps like so
    keymaps = {
      edit_commands = "<leader>mc",
      save_commands = "<leader>ms",
      run_commands = "<leader>mx",
      run_file = "<leader>mr",
      toggle_output = "<leader>M",
      manage_saved_commands = "<leader>mm",
    },

    -- if you are using fish you can enable terminal-like completion inside the edit buffer.
    enable_fish_completion = false,

    -- change the height of the buffers
    default_height = 10,
  },
}

```


