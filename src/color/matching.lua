local love = require("love")

local math = require("math")

local input = require("util.input")
local picker = require("color.picker")

local m = {}

local is_adjusting_left = true

m.load = function ()
  picker.load()
end

m.update = function (dt)
  picker.update(dt)
end

m.keypressed = function (key, scancode, isrepeat)
  if input.anykeyequal(key, {"space"}) then
    is_adjusting_left = not is_adjusting_left
  end
end

m.draw = function ()
  picker.draw()
end

return m