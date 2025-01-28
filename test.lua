local math = require("math")

local hsla_to_rgba = function(h, s, l, a)
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

local rgb_to_hsl = function(r, g, b)
  local v = math.max(r, g, b)
  local xmin = math.min(r, g, b)
  local c = v - xmin
  local l = (v + xmin) / 2

  local h = 0
  if c == 0 then
    h = 0
  elseif v == r then
    h = 60 * (((g - b) / c) % 6)
  elseif v == g then
    h = 60 * (((b - r) / c) + 2)
  elseif v == b then
    h = 60 * (((r - g) / c) + 4)
  end

  local s = 0
  if l == 0 or l == 1 then
    s = 0
  else
    s = (v - l) / math.min(l, 1 - l)
  end

  return h / 360, s, l
end


-- main code

local val = { 0.8, 0.61, 0.4, 1 }
local val_in_rgb = { hsla_to_rgba(unpack(val)) }
for _,v in pairs(val_in_rgb) do
  print(v)
end
local final_val = { rgb_to_hsl(val_in_rgb[1], val_in_rgb[2], val_in_rgb[3]) }
for _,v in pairs(final_val) do
  print(v)
end

-- print("--- rgb to hsl ---")

-- local val_rgb = { 40 / 360, 164 / 360, 164 / 360 }
-- local val_in_hsl = { rgb_to_hsl(unpack(val_rgb)) }
-- for _,v in pairs(val_in_hsl) do
--   print(v)
-- end
