local table = require("table")

local m = {}

-- merges a variable number of tables into one
m.merge_tables = function (...)
  local ktables = {...}
  local newtable = {}
  for _,ktable in pairs(ktables) do
    for _,val in pairs(ktable) do
      table.insert(newtable, val)
    end
  end

  return newtable
end

return m