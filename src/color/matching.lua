local love = require("love")

local math = require("math")

local input = require("util.input")
local picker = require("color.picker")

local m = {}

local is_adjusting_left = true
local lr, lg, lb = 255, 0, 0
local rr, rg, rb = 0, 0, 255
local color_adjust_factor = 1

local RADIUS = 100;

m.load = function ()
end

m.update = function (dt)
  if is_adjusting_left then
    if input.anykeysdown({"a"}) then
      lr = lr - color_adjust_factor
    elseif input.anykeysdown({"q"}) then
      lr = lr + color_adjust_factor
    end
    if input.anykeysdown({"s"}) then
      lg = lg - color_adjust_factor
    elseif input.anykeysdown({"w"}) then
      lg = lg + color_adjust_factor
    end
    if input.anykeysdown({"d"}) then
      lb = lb - color_adjust_factor
    elseif input.anykeysdown({"e"}) then
      lb = lb + color_adjust_factor
    end
  else
    if input.anykeysdown({"a"}) then
      rr = rr - color_adjust_factor
    elseif input.anykeysdown({"q"}) then
      rr = rr + color_adjust_factor
    end
    if input.anykeysdown({"s"}) then
      rg = rg - color_adjust_factor
    elseif input.anykeysdown({"w"}) then
      rg = rg + color_adjust_factor
    end
    if input.anykeysdown({"d"}) then
      rb = rb - color_adjust_factor
    elseif input.anykeysdown({"e"}) then
      rb = rb + color_adjust_factor
    end
  end

  if lr < 0 then lr = 0 end
  if lg < 0 then lg = 0 end
  if lb < 0 then lb = 0 end
  if rr < 0 then rr = 0 end
  if rg < 0 then rg = 0 end
  if rb < 0 then rb = 0 end

  if lr > 255 then lr = 255 end
  if lg > 255 then lg = 255 end
  if lb > 255 then lb = 255 end
  if rr > 255 then rr = 255 end
  if rg > 255 then rg = 255 end
  if rb > 255 then rb = 255 end
end

m.keypressed = function (key, scancode, isrepeat)
  if input.anykeyequal(key, {"space"}) then
    is_adjusting_left = not is_adjusting_left
  end

  if input.anykeyequal(key, {"p"}) then
    if is_adjusting_left then
      print(lr .. " " .. lg .. " " .. lb)
    else
      print(rr .. " " .. rg .. " " .. rb)
    end
  end
end

m.draw = function ()
  -- local screen_w, screen_h = love.graphics.getWidth(), love.graphics.getHeight()

  -- if is_adjusting_left then
  --   love.graphics.setColor(love.math.colorFromBytes(lr, lg, lb))
  --   love.graphics.circle("fill", math.floor(screen_w / 3), math.floor(screen_h / 2), RADIUS)
  -- else
  --   love.graphics.setColor(love.math.colorFromBytes(rr, rg, rb))
  --   love.graphics.circle("fill", math.floor(screen_w * 2 / 3), math.floor(screen_h / 2), RADIUS)
  -- end


  picker.draw()
end

return m