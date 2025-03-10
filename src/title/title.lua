local love = require("love")
local constants = require("util.constants")

local title = {}

local title_img

local r = 150
local v = 500
local ball1 = {} -- red ball = x, y, r, dx, dy
local ball2 = {} -- blue ball
local intersection_pixels = {}

title.load = function ()
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  title_img = love.graphics.newImage("assets/title.png")

  math.randomseed(os.clock())
  local rot1, rot2 = math.random() * 2 * math.pi, math.random() * 2 * math.pi
  ball1 = {
    x = math.random(r, constants.window_width - r),
    y = math.random(r, constants.window_height - r),
    r = r,
    dx = v * math.cos(rot1),
    dy = v * math.sin(rot1),
  }
  ball2 = {
    x = math.random(r, constants.window_width - r),
    y = math.random(r, constants.window_height - r),
    r = r,
    dx = v * math.cos(rot2),
    dy = v * math.sin(rot2)
  }
end

title.keypressed = function (key, scancode, isrepeat)
end

title.update = function (dt)
  ball1.x = ball1.x + ball1.dx * dt
  ball1.y = ball1.y + ball1.dy * dt

  ball2.x = ball2.x + ball2.dx * dt
  ball2.y = ball2.y + ball2.dy * dt

  for _,b in pairs({ball1, ball2}) do
    if b.x - b.r <= 0 then
      b.x = b.r
      b.dx = math.abs(b.dx)
    elseif b.x + b.r >= constants.window_width then
      b.x = constants.window_width - b.r
      b.dx = -math.abs(b.dx)
    end

    if b.y - b.r <= 0 then
      b.y = b.r
      b.dy = math.abs(b.dy)
    elseif b.y + b.r >= constants.window_height then
      b.y = constants.window_height - b.r
      b.dy = -math.abs(b.dy)
    end
  end

  intersection_pixels = {}
  for x = ball1.x - ball1.r, ball1.x + r do
    for y = ball1.y - math.sqrt(ball1.r^2 - (x - ball1.x)^2), ball1.y + math.sqrt(ball1.r^2 - (x - ball1.x)^2) do
      if math.pow(x - ball2.x, 2) + math.pow(y - ball2.y, 2) <= ball2.r^2 then
        table.insert(intersection_pixels, {x, y})
      end
    end
  end
end

title.draw = function ()
  -- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", ball1.x, ball1.y, ball1.r)

  love.graphics.setColor(0, 0, 1)
  love.graphics.circle("fill", ball2.x, ball2.y, ball2.r)

  love.graphics.setColor(0, 1, 0)
  for _,p in pairs(intersection_pixels) do
    love.graphics.points(p[1], p[2])
  end

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(title_img, constants.window_width / 2 - title_img:getWidth() / 2, constants.window_height / 2 - title_img:getHeight() * 2 / 3)
end


return title