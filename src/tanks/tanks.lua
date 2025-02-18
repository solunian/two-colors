local love = require("love")
local picker = require("color.picker")
local tankclass = require("tanks.tankclass")

local t = {}

local tanks = {} -- all tanks
local mines = {}

local function reset_level()
  tanks = {}
  mines = {}
end

local function level1()
  table.insert(tanks, tankclass.EnemyTank(200, 300))
  table.insert(tanks, tankclass.EnemyTank(400, 500))
  table.insert(tanks, tankclass.EnemyTank(700, 400))
  table.insert(tanks, tankclass.PlayerTank())
end


t.load = function ()
  reset_level()
  level1()
end

t.update = function (dt)
  for _,tank in pairs(tanks) do
    tank:update(dt)
    tank:check_projectile_collisions(tanks)

    for _,proj in pairs(tank.projectiles) do
      proj:update(dt)
    end
  end

  -- check all tables for updates
  -- check positions
end

t.keypressed = function (key, scancode, isrepeat)
  if key == "r" then
    reset_level()
    level1()
  end

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
      if tank.tank_type == tankclass.TANK_TYPES.P1 then
        love.graphics.setColor(picker.lens_lcolor)
      else
        love.graphics.setColor(picker.lens_rcolor)
      end
      love.graphics.circle("fill", proj.x, proj.y, proj.r)
    end
  end
end

return t