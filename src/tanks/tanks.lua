local love = require("love")
local picker = require("color.picker")
local misc  = require("util.misc")

local input = require("util.input")

local tankclass = require("tanks.tankclass")
local projectileclass = require("tanks.projectileclass")

local t = {}

local mines = {}


t.load = function ()
  tankclass.tanktable = {}
  projectileclass.projectiles = {}
  mines = {}
  tankclass.PlayerTank()
end

t.update = function (dt)
  for _,tank in pairs(tankclass.tanks) do
    tank:update(dt)
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
  for _,tank in pairs(tankclass.tanks) do
    if tank.tank_type == tankclass.TANK_TYPES.P1 then
      tank:check_inputspressed(key)
    end
  end
end

t.draw = function ()
  -- loop through tables to draw all of them
  for _,tank in pairs(tankclass.tanks) do
    -- no mouse?
    -- love.mouse.setVisible(false)
    local mousex, mousey = input.get_mouse()

    -- tank aim line, aim crosshair
    if tank.tank_type == tankclass.TANK_TYPES.P1 then
      -- tank
      love.graphics.setColor(picker.lens_lcolor)
      misc.round_rectangle(tank.x, tank.y, tank.w, tank.h, 10)

      love.graphics.setColor(1, 1, 1, 0.8)
      love.graphics.setLineWidth(1)
      love.graphics.line(tank.x + tank.w / 2, tank.y + tank.h / 2, mousex, mousey)

      love.graphics.rectangle("fill", mousex - 10, mousey - 2, 20, 4)
      love.graphics.rectangle("fill", mousex - 2, mousey - 10, 4, 20)
    end

    for _,proj in pairs(tank.projectiles) do
      love.graphics.setColor(picker.lens_lcolor)
      love.graphics.circle("fill", proj.x, proj.y, proj.r)
    end
  end
end

return t