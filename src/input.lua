local love = require("love")
local table = require("table")

local i = {}

-- merges a variable number of tables into one
i.merge_tables = function (...)
  local ktables = {...}
  local newtable = {}
  for _,ktable in pairs(ktables) do
    for _,val in pairs(ktable) do
      table.insert(newtable, val)
    end
  end

  return newtable
end

i.anykeyequal = function (keydown, keys)
  for _,val in pairs(keys) do
    if keydown == val then
      return true
    end
  end
  return false
end

i.anykeysdown = function (keys)
  for _,val in pairs(keys) do
    if love.keyboard.isDown(val) then
      return true
    end
  end
  return false
end

i.allkeysdown = function (keys)
  for _,val in pairs(keys) do
    if not love.keyboard.isDown(val) then
      return false
    end
  end
  return true
end


return i