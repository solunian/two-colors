local love = require("love")
local table = require("table")
local math = require("math")

local misc = {}

-- Converts HSL to RGB. (input and output range: 0 - 1)
misc.hsla_to_rgba = function(h, s, l, a)
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

misc.round_rectangle = function(x, y, width, height, radius)
	--RECTANGLES
	love.graphics.rectangle("fill", x + radius, y + radius, width - (radius * 2), height - radius * 2)
	love.graphics.rectangle("fill", x + radius, y, width - (radius * 2), radius)
	love.graphics.rectangle("fill", x + radius, y + height - radius, width - (radius * 2), radius)
	love.graphics.rectangle("fill", x, y + radius, radius, height - (radius * 2))
	love.graphics.rectangle("fill", x + (width - radius), y + radius, radius, height - (radius * 2))

	--ARCS
	love.graphics.arc("fill", x + radius, y + radius, radius, math.rad(-180), math.rad(-90))
	love.graphics.arc("fill", x + width - radius , y + radius, radius, math.rad(-90), math.rad(0))
	love.graphics.arc("fill", x + radius, y + height - radius, radius, math.rad(-180), math.rad(-270))
	love.graphics.arc("fill", x + width - radius , y + height - radius, radius, math.rad(0), math.rad(90))
end

-- inclusive check
misc.within = function(val, min, max)
  return min <= val and val <= max
end

-- merges a variable number of tables into one
misc.merge_tables = function (...)
  local ktables = {...}
  local newtable = {}
  for _,ktable in pairs(ktables) do
    for _,val in pairs(ktable) do
      table.insert(newtable, val)
    end
  end

  return newtable
end

return misc