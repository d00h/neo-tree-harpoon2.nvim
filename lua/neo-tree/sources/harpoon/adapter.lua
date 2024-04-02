local highlights = require("neo-tree.ui.highlights")
local renderer = require("neo-tree.ui.renderer")
local harpoon = require("harpoon")

local function list_harpoon_items()
  local cwd = vim.fn.getcwd()
  local harpoon_items = harpoon:list()
  local children_items = {}
  for idx, favorite in ipairs(harpoon_items.items) do
    local value
    if type(favorite) == "string" then
      value = favorite
    elseif type(favorite) == "table" then
      value = favorite.value
    end
    if value == nil then
      goto continue
    end
    if value:sub(0, #cwd) == cwd then
      value = value:sub(#cwd + 2, #value)
    end
    local context = favorite.context or {}
    local path = vim.fn.fnamemodify(favorite.value, ":p")
    table.insert(
      children_items, --
      {
        id = path,
        path = path,
        name = string.format("%d: %s", idx, value),
        type = "file",
        extra = { pos = idx, col = context.col, row = context.row },
      }
    )
    ::continue::
  end
  return children_items
end

local function exist_item(filename)
  for _, item in ipairs(list_harpoon_items()) do
    if item.id == filename then
      return true
    end
  end
  return false
end

local function list_items(path)
  local home = vim.loop.os_homedir()
  if string.sub(path, 0, #home) == home then
    path = "~" .. string.sub(path, #home + 1, #path)
  end
  local root = { --
    id = -1,
    name = string.format("Harpoon in %s", path),
    type = "directory",
    children = list_harpoon_items(),
  }
  return { root }
end

local function copy(state, path_to_reveal)
  local items = list_items(vim.fn.getcwd())
  renderer.show_nodes(items, state)
  if path_to_reveal then
    renderer.position.set(state, path_to_reveal)
  end
end

local function append(filename)
  local items = harpoon:list()
  if filename ~= nil then
    items:append({ value = filename, context = {} })
  end
end

return { --
  list_items = list_items,
  exist_item = exist_item,
  append = append,
  copy = copy,
  last_bufname = nil,
}
