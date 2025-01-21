local love = require("love")
local push = require("lib.push")
local constants = require("util.constants")
local input     = require("util.input")

-- Converts HSL to RGB. (input and output range: 0 - 1)
local function hsl_to_rgba(h, s, l, a)
  if s<=0 then return l,l,l,a end
  h, s, l = h*6, s, l
  local c = (1-math.abs(2*l-1))*s
  local x = (1-math.abs(h%2-1))*c
  local m,r,g,b = (l-.5*c), 0,0,0
  if h < 1     then r,g,b = c,x,0
  elseif h < 2 then r,g,b = x,c,0
  elseif h < 3 then r,g,b = 0,c,x
  elseif h < 4 then r,g,b = 0,x,c
  elseif h < 5 then r,g,b = x,0,c
  else              r,g,b = c,0,x
  end return r+m, g+m, b+m, a
end

local scale = 1 -- ?? wut

local w = 600 * scale
local h = 300 * scale
local component_offset = 10
local colorbar_w_ratio_denom = 6
local slider_h_ratio_denom = 12

-- directly centered
local x = (constants.window_width - w - (w / colorbar_w_ratio_denom) - component_offset) / 2
local y = (constants.window_height - h - (h / slider_h_ratio_denom) - component_offset) / 2



local colorbar_w = w / colorbar_w_ratio_denom

local slider_offset = 1 -- percentage of slider thing of the slider width
local sx = x + w -- slider x
local slider_w = w
local slider_h = w / slider_h_ratio_denom

local mousex, mousey = 0, 0
local px, py = x, y -- pointer position for picker



local function xy_to_rgb()
  return hsl_to_rgba(slider_offset, (px - x) / w, 1 - ((py - y) / h), 1)
end

local p = {}

p.load = function ()
  
end

p.update = function (dt)
end

p.keypressed = function (key, scancode, isrepeat)
end

-- saturation on x axis
-- lightness on y axis
p.draw = function ()
  slider_offset = (sx - x) / w

  if love.mouse.isDown(1) then
    mousex, mousey = input.get_mouse()
  end

  if x <= mousex and mousex <= x + w and y <= mousey and mousey <= y + h then
    px = mousex
    py = mousey
  end

  if x <= mousex and mousex <= x + w and y + h + component_offset <= mousey and mousey <= y + h + component_offset + slider_h then
    sx = mousex
  end

  -- hsl spectrum
  for row=0,h do
    for col=0,w do
      love.graphics.setColor(hsl_to_rgba(slider_offset, col / w, 1 - (row / h), 1))
      love.graphics.points(x + col, y + row)
    end
  end

  -- color bar
  love.graphics.setColor(xy_to_rgb())
  love.graphics.rectangle("fill", x + w + component_offset, y, colorbar_w, h)

  -- saturation bar
  for dx=0,slider_w do
    love.graphics.setColor(hsl_to_rgba(dx / slider_w, 1, 0.5, 1))
    love.graphics.rectangle("fill", x + dx, y + h + component_offset, 1, slider_h)
  end

  -- saturation bar line
  local barline_w = 10
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("line", sx - barline_w / 2, y + h + component_offset, barline_w, slider_h)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("line", sx - barline_w / 4, y + h + component_offset, barline_w / 2, slider_h)

  -- spectrum circle
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.circle("line", px, py, 4)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.circle("line", px, py, 5)
end


return p