local love = require("love")
local table = require("table")

local input = require("util.input")

local tankclass = require("tanks.tankclass")

local t = {}

local tanks = {}
local projectiles = {}
local mines = {}


t.load = function ()
  local tank = tankclass.PlayerTank:new()
  table.insert(tanks, tank)
end

t.update = function (dt)
  for _,tank in pairs(tanks) do
    if tank.tank_type == tankclass.TANK_TYPES.P1 then
      tank:check_inputsdown()
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
    love.graphics.setColor(0, 1, 1, 1)
    love.graphics.rectangle("fill", tank.x, tank.y, tank.w, tank.h)
  end
end

return t