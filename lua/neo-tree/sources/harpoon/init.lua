-- This file should have all functions that are in the public api and either set
-- or read the state of this source.
local vim = vim
local utils = require("neo-tree.utils")
local renderer = require("neo-tree.ui.renderer")

local events = require("neo-tree.events")
local manager = require("neo-tree.sources.manager")
local git = require("neo-tree.git")
local harpoon_adapter = require("neo-tree.sources.harpoon.adapter")

local redraw = utils.wrap(manager.redraw, "harpoon")

local M = {name = "harpoon"}

local wrap = function(func)
    return utils.wrap(func, M.name)
end

---Navigate to the given path.
---@param path string Path to navigate to. If empty, will navigate to the cwd.
M.navigate = function(state, path, path_to_reveal)
    state.dirty = false
    harpoon_adapter.copy(state, path_to_reveal)
end

M.follow = function()
    local state = manager.get_state(M.name)
    local window_exists = renderer.window_exists(state)
    local bufnr = vim.api.nvim_get_current_buf()

    if not vim.fn.buflisted(bufnr) then
        return
    end

    local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")

    if buftype == "nofile" or buftype == "terminal" then
        return
    end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local bufexists = harpoon_adapter.exist_item(bufname)
    if window_exists and bufexists then
        harpoon_adapter.copy(state, bufname)
    else
        harpoon_adapter.last_bufname = bufname
    end
end

M.setup = function(config, global_config)
    manager.subscribe(M.name, {event = events.VIM_BUFFER_ENTER, handler = M.follow})
end

return M
