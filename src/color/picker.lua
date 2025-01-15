local love = require("love")

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

local x, y = 0, 0
local slider_offset = 0
local scale = 1
local px, py = 0, 0 -- pointer position

local w = 600
local h = 300


local p = {}

p.load = function ()
  
end

p.update = function ()
  
end


-- saturation on x axis
-- lightness on y axis

p.draw = function ()
  for row=0,h do
    for col=0,w do
			love.graphics.setColor(hsl_to_rgba(1, col / w, 1 - (row / h), 1))
			love.graphics.points(x + col, y + row)
    end
  end
end


return p