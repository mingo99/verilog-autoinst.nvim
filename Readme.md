<div align="center">

<h1>verilog-autoinst.nvim</h1>

A <i>neovim</i> plugin to instantiate verilog module automatically.

[Getting Started](#getting-started) | [Requirements](#requirements) | [Installation](#installation) | [Features](#features)

</div>

## Getting Started

![autoinst in action](https://cdn.jsdelivr.net/gh/mingo99/PicBed/img/demo.gif)

1. With Telescope

    Run `:AutoInst` to instantiate.

2. With File Path

    Run `:AutoInst <file_path>` to instantiate.

    Note: The `file_path` can be either an absolute path or a relative path to the root directory of the current workspace.

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
 },

```

You can register command name that you like, but you need to modify command in keymap for lazy-load.

```lua
 {
  opts = {
   cmd = "UserComamndName",
  },
 },

```

## Features

- Generate instantiation template and write in the position where the cursor is located.
- The template is not formatted and you need to rely on the plug-in you installed for formatting.
- Only support one module in a file.
- The matching pattern follows [verilog-2001](https://ieeexplore.ieee.org/document/954909?arnumber=954909) standard.
