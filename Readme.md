<div align="center">

<h1>verilog-autoinst.nvim</h1>

A <i>neovim</i> plugin to instantiate verilog module automatically.

[Getting Started](#getting-started) | [Requirements](#requirements) | [Installation](#installation) | [Features](#features)

</div>

## Getting Started

1. With Telescope

    Run `:AutoInst` to instantiate.
    ![autoinst with telescope](https://cdn.jsdelivr.net/gh/mingo99/PicBed/img/autoinst-1.gif)

2. With File Path

    Run `:AutoInst <file_path>` to instantiate.

    Absolute path:
    ![autoinst with relative path](https://cdn.jsdelivr.net/gh/mingo99/PicBed/img/autoinst-2.gif)

    Relative path to the root directory of the current workspace:
    ![autoinst with absolute path](https://cdn.jsdelivr.net/gh/mingo99/PicBed/img/autoinst-3.gif)

## Requirements

- It is best to use [neovim](https://github.com/neovim/neovim) version 0.9 or newer.
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim) in lua

```lua
 {
  "mingo99/verilog-autoinst.nvim",
  cmd = "AutoInst",
  keys = { { "<leader>fv", "<cmd>AutoInst<cr>", desc = "Automatic instantiation for verilog" } },
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {}
 },

```

You can set `cmd` to change the command name, but you need to change the key mapping accordingly.
And you can set `fmt` to format the instantiation template.

```lua
 {
  opts = {
   cmd = "UserComamndName",
   fmt = true    -- format the instantiation template
  },
 },

```

## Features

- Generate instantiation template and write in the position where the cursor is located.
- Only support one module in a file.
- The matching pattern follows [verilog-2001](https://ieeexplore.ieee.org/document/954909?arnumber=954909) standard.
