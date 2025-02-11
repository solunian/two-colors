local love = require("love")
local picker = require("color.picker")
local misc  = require("util.misc")

local input = require("util.input")

local tankclass = require("tanks.tankclass")
local projectileclass = require("tanks.projectileclass")

local t = {}

local tanks = {} -- all tanks
local mines = {}


t.load = function ()
  tanks = {}
  mines = {}
  table.insert(tanks, tankclass.PlayerTank())
end

t.update = function (dt)
  for _,tank in pairs(tanks) do
    tank:update(dt)
    tank:check_projectile_collisions(tanks)
    -- if tank.tank_type == tankclass.TANK_TYPES.P1 then
    -- end

    for _,proj in pairs(tank.projectiles) do
      proj:update(dt)
    end
  end

  -- check all tables for updates
  -- check positions
end

t.keypressed = function (key, scancode, isrepeat)
  for _,tank in pairs(tanks) do
    if tank.tank_type == tankclass.TANK_TYPES.P1 then
      tank:check_inputspressed(key)
    end
  end
end

t.draw = function ()
  -- loop through tables to draw all of them
  for _,tank in pairs(tanks) do
    -- tank aim line, aim crosshair
    if tank.tank_type == tankclass.TANK_TYPES.P1 then
      tank:draw(picker.lens_lcolor)
    else
      tank:draw(picker.lens_rcolor)
    end

    for _,proj in pairs(tank.projectiles) do
      love.graphics.setColor(picker.lens_lcolor)
      love.graphics.circle("fill", proj.x, proj.y, proj.r)
    end
  end
end

return t