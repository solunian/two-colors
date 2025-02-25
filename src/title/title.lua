local love = require("love")
local constants = require("util.constants")

local title = {}

local title_img

local r = 200
local v = 400
local ball1 = {0, 0} -- red ball = x, y, dx, dy
local ball2 = {0, 0} -- blue ball

title.load = function ()
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  title_img = love.graphics.newImage("assets/title.png")

  math.randomseed(os.clock())
  local rot1, rot2 = math.random() * 2 * math.pi, math.random() * 2 * math.pi
  ball1 = { math.random(r, constants.window_width - r), math.random(r, constants.window_height - r), v * math.cos(rot1), v * math.sin(rot1) }
  ball2 = { math.random(r, constants.window_width - r), math.random(r, constants.window_height - r), v * math.cos(rot2), v * math.sin(rot2) }
end

title.keypressed = function (key, scancode, isrepeat)
end

title.update = function (dt)
  ball1[1] = ball1[1] + ball1[3] * dt
  ball1[2] = ball1[2] + ball1[4] * dt

  ball2[1] = ball2[1] + ball2[3] * dt
  ball2[2] = ball2[2] + ball2[4] * dt

  for _,b in pairs({ball1, ball2}) do
    if b[1] - r <= 0 then
      b[1] = r
      b[3] = math.abs(b[3])
    elseif b[1] + r >= constants.window_width then
      b[1] = constants.window_width - r
      b[3] = -math.abs(b[3])
    end

    if b[2] - r <= 0 then
      b[2] = r
      b[4] = math.abs(b[4])
    elseif b[2] + r >= constants.window_height then
      b[2] = constants.window_height - r
      b[4] = -math.abs(b[4])
    end
  end
end

title.draw = function ()
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", ball1[1], ball1[2], r)

  love.graphics.setColor(0, 0, 1)
  love.graphics.circle("fill", ball2[1], ball2[2], r)

  love.graphics.setColor(0, 1, 0)
  local intersection_pixels = {}
  for x = ball1[1] - r, ball1[1] + r,2 do
    for y = ball1[2] - math.sqrt(r * r - math.pow(x - ball1[1], 2)), ball1[2] + math.sqrt(r * r - math.pow(x - ball1[1], 2)),2 do
      if math.pow(x - ball2[1], 2) + math.pow(y - ball2[2], 2) <= r * r then
        table.insert(intersection_pixels, {x, y})
        table.insert(intersection_pixels, {x + 1, y})
        table.insert(intersection_pixels, {x, y + 1})
        table.insert(intersection_pixels, {x + 1, y + 1})
      end
    end
  end
  for _,p in pairs(intersection_pixels) do
    love.graphics.points(p[1], p[2])
  end
  -- local inter1 = {math.sqrt(ball2[1] ^ 2 + ball1[2] ^ 2 - }


  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(title_img, constants.window_width / 2 - title_img:getWidth() / 2, constants.window_height / 2 - title_img:getHeight() * 2 / 3)
end


return title