<h1 align="center">
    autoverilog.nvim
</h1>

<p align="center">
    A <i>neovim</i> plugin to instantiate verilog module automatically.
</p>

![autoinst in action](https://cdn.jsdelivr.net/gh/mingo99/PicBed/img/demo.gif)

## Requirements

- It is best to use [neovim](https://github.com/neovim/neovim) version 0.9 or newer.
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim) in lua

```lua
 {
  "mingo99/verilog-autoinst.nvim",
  event = "VeryLazy",
  cmd = "AutoInst",
  keys = { { "<leader>fv", "<cmd>AutoInst<cr>", desc = "Automatic instantiation for verilog" } },
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {
   cmd = "AutoInst",
  },
 },

```

When you want to instantiate a module, run the command `AutoInst`. And you can map the key to others.

## Features

- Find and select a _verilog_ files in current workspace with telescope.
- Generate instantiation template and write in the position where the cursor is located.
- The template is not formatted and you need to rely on the plug-in you installed for formatting.
- Only support one module in a file.
- The matching pattern follows [verilog-2001](https://ieeexplore.ieee.org/document/954909?arnumber=954909) standard.
