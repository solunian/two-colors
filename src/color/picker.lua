local love = require("love")
local misc = require("util.misc")
local constants = require("util.constants")
local input = require("util.input")

local scale = 1 -- lol

-- VARIABLES FOR ACTUAL COLOR PICKER THING --
local w = 500 * scale -- just spectrum w
local h = w / 2 -- just spectrum h
local component_offset = 10
local colorbar_w_ratio_denom = 6
local slider_h_ratio_denom = 12

-- directly centered, then y pushed to 5 / 3 times
local x = (constants.window_width - w - (w / colorbar_w_ratio_denom) - component_offset) / 2
local y = ((constants.window_height - h - (h / slider_h_ratio_denom) - component_offset) / 2) * 3 / 2

local px, py = x, y -- pointer position for picker

local colorbar_w = w / colorbar_w_ratio_denom

local slider_offset = 1 -- percentage of slider thing of the slider width
local sx = x + w -- slider x
local slider_w = w
local slider_h = w / slider_h_ratio_denom
--------------------------------------------

-- MOUSE VARIABLES --
local mousex, mousey = 0, 0
---------------------

-- LENS VARIABLES --
local lx, ly = constants.window_width / 2, constants.window_height / 6 -- from the center anchor
local lw, lh = w / 2, w / 4
local lens_lcolor, lens_rcolor = {0, 0, 1, 1}, {1, 0, 0, 1}
local loffset = w / 15 -- individual offset from the center anchor xy
local is_left_selected = true
local rounding_radius = w / 30
--------------------


-- calculates the rgba from the coordinate positions
local function xy_to_rgb()
  return misc.hsla_to_rgba(slider_offset, (px - x) / w, 1 - ((py - y) / h), 1)
end

local function set_xy_from_rgb(r, g, b)
  local hue, sat, lig = misc.rgb_to_hsl(r, g, b)
  px = x + sat * w
  py = y + (1 - lig) * h
  slider_offset = hue
  sx = x + hue * slider_w
  -- print(hue, sat, lig)
end

local p = {}

p.load = function ()
  if is_left_selected then
    set_xy_from_rgb(unpack(lens_lcolor))
  else
    set_xy_from_rgb(unpack(lens_rcolor))
  end
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

    if misc.within(mousex, lx - lw - loffset, lx - loffset) and misc.within(mousey, ly, ly + lh) then
      is_left_selected = true
      set_xy_from_rgb(unpack(lens_lcolor))
    elseif misc.within(mousex, lx + loffset, lx + lw + loffset) and misc.within(mousey, ly, ly + lh) then
      is_left_selected = false
      set_xy_from_rgb(unpack(lens_rcolor))
    elseif misc.within(mousex, x, x + w) and misc.within(mousey, y, y + h) then
      px = mousex
      py = mousey
    elseif misc.within(mousex, x, x + w) and misc.within(mousey, y + h + component_offset, y + h + component_offset + slider_h) then
      sx = mousex
    end
  end

  -- bind slider to lens colors
  if is_left_selected then
    lens_lcolor = {xy_to_rgb()}
  else
    lens_rcolor = {xy_to_rgb()}
  end

  -- hsl spectrum
  for row=0,h do
    for col=0,w do
      love.graphics.setColor(misc.hsla_to_rgba(slider_offset, col / w, 1 - (row / h), 1))
      love.graphics.points(x + col, y + row)
    end
  end

  -- color bar
  love.graphics.setColor(xy_to_rgb())
  love.graphics.rectangle("fill", x + w + component_offset, y, colorbar_w, h)

  -- saturation bar
  for dx=0,slider_w do
    love.graphics.setColor(misc.hsla_to_rgba(dx / slider_w, 1, 0.5, 1))
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

  -- lens rectangles
  if is_left_selected then
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle("fill", lx - loffset - lw - 5, ly - 5, lw + 10, lh + 10)
    misc.round_rectangle(lx - loffset - lw - 5, ly - 5, lw + 10, lh + 10, rounding_radius)
  else
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.rectangle("fill", lx + loffset - 5, ly - 5, lw + 10, lh + 10)
    misc.round_rectangle(lx + loffset - 5, ly - 5, lw + 10, lh + 10, rounding_radius)
  end

  love.graphics.setColor(lens_lcolor)
  -- love.graphics.rectangle("fill", lx - loffset - lw, ly, lw, lh)
  misc.round_rectangle(lx - loffset - lw, ly, lw, lh, rounding_radius)

  love.graphics.setColor(lens_rcolor)
  -- love.graphics.rectangle("fill", lx + loffset, ly, lw, lh)
  misc.round_rectangle(lx + loffset, ly, lw, lh, rounding_radius)
end


return p