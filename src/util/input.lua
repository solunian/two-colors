local love = require("love")
local push = require("lib.push")

local i = {}

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

---@return integer, integer
i.get_mouse = function ()
  local x, y = love.mouse.getX(), love.mouse.getY()
  local gx, gy = push:toGame(x, y)

  -- nasty edge case for fullscreen off game window mouse positions (that return nil), so just setting it to 0 or max value (width/height)
  if gx == nil then
    if x < push:getWidth() - x then
      x = 0
    else
      x = push:getWidth()
    end
  end
  if gy == nil then
    if y < push:getHeight() - y then
      y = 0
    else
      y = push:getHeight()
    end
  end

  return (gx or x), (gy or y)
end

return i