-- This file should contain all commands meant to be used by mappings.
local vim = vim
local cc = require("neo-tree.sources.common.commands")
local utils = require("neo-tree.utils")
local manager = require("neo-tree.sources.manager")

local harpoon_adapter = require("neo-tree.sources.harpoon.adapter")
local renderer = require("neo-tree.ui.renderer")
local redraw = utils.wrap(manager.redraw, "harpoon")
local refresh = utils.wrap(manager.refresh, "harpoon")

local utils = require("neo-tree.utils")

local M = {}

local harpoon = require("harpoon")

local function safe(fn, ...)
  local success, ret = pcall(fn, ...)
  if not success then
    vim.api.nvim_echo({ { ret, "ErrorMsg" } }, true, {})
  end
end

M.add = function(state, toggle_directory)
  harpoon_adapter.append(harpoon_adapter.last_bufname)
  harpoon_adapter.copy(state)
  refresh(state)
end

M.open = function(state, toggle_directory)
  local node = state.tree:get_node()
  local pos = node.extra.pos
  if pos ~= nil then
    safe(function(pos)
      -- local neotree_command = require("neo-tree.command")
      -- neotree_command.execute({action = "close"})
      local harpoon_items = harpoon:list()
      pcall(function()
        harpoon_items:select(pos)
      end)
      -- neotree_command.execute({ --
      --     action = "show",
      --     source = "harpoon",
      --     path_to_reveal = node.id,
      -- })
    end, pos)
  end
end

M.delete = function(state, toggle_directory)
  local node = state.tree:get_node()
  local pos = node.extra.pos
  if pos ~= nil then
    safe(function(pos)
      local harpoon_items = harpoon:list()
      harpoon_items:remove_at(pos)
    end, pos)
    harpoon_adapter.copy(state)
  end
end

local function restore_cursor(old_row, new_row)
  local win = vim.api.nvim_get_current_win()
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  if row == old_row then
    pcall(vim.api.nvim_win_set_cursor, win, { new_row, col })
  end
end

M.swap_prev = function(state, toggle_directory)
  local node = state.tree:get_node()
  local pos = node.extra.pos
  if pos ~= nil then
    safe(function(old_pos)
      local items = harpoon:list().items
      local new_pos = old_pos - 1
      local old_item, new_item = items[old_pos], items[new_pos]
      if old_item ~= nil and new_item ~= nil then
        items[old_pos], items[new_pos] = new_item, old_item
        harpoon_adapter.copy(state)
        restore_cursor(old_pos + 1, new_pos + 1)
      end
    end, pos)
  end
end

M.swap_next = function(state, toggle_directory)
  local node = state.tree:get_node()
  local pos = node.extra.pos
  if pos ~= nil then
    safe(function(old_pos)
      local items = harpoon:list().items
      local new_pos = old_pos + 1
      local old_item, new_item = items[old_pos], items[new_pos]
      if old_item ~= nil and new_item ~= nil then
        items[old_pos], items[new_pos] = new_item, old_item
        harpoon_adapter.copy(state)
        restore_cursor(old_pos + 1, new_pos + 1)
      end
    end, pos)
  end
end

M.refresh = refresh
M.close_window = cc.close_window
-- cc._add_common_commands(M)

return M
