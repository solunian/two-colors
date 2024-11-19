local love = require("love")

local input = require("util.input")

local tankclass = require("tanks.tankclass")

local t = {}

local tanks = {}
local projectiles = {}
local mines = {}


t.load = function ()
  local tank = tankclass.PlayerTank:new()
  tank:set_inputs() -- part of only PlayerTank class
  tank:update() -- part of super Tank class
end

t.update = function (dt)
  -- check all tables for updates
  -- check positions
end

t.keypressed = function (key, scancode, isrepeat)
end

t.draw = function ()
  -- loop through tables to draw all of them

  love.graphics.setColor(0, 1, 1, 1)
  love.graphics.rectangle("fill", 0, 0, 200, 200)
end

return t