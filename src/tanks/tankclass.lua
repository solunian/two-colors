local Object = require("lib.object")
local input = require("util.input")

local tc = {} -- tank class

local TANK_TYPES = {
  NIL = 0,
  P1 = 1, P2 = 2, P3 = 3, P4 = 4,
  E1 = 5, E2 = 6 -- https://nintendo.fandom.com/wiki/Tanks!
}

----------------
-- class Tank --
----------------
local Tank = Object:extend()

function Tank:new()
  self.tank_type = TANK_TYPES.NIL
  self.x, self.y = 0, 0
  self.w, self.h = 20, 20
  self.rotation = 0
  self.speed = 0
  self.rotation_speed = 0
end

function Tank:set_pos(x, y)
  self.x = x
  self.y = y
end

function Tank:change_x(dx)
  self.x = self.x + dx
end

function Tank:change_y(dy)
  self.y = self.y + dy
end

function Tank:fire()
  print("fire!")
end

function Tank:plant_mine()
  print("plant mine!")
end

-- collider table must have x, y, w, h, rotation
function Tank:has_collided(collider)
end

function Tank:draw()
end

----------------------
-- class PlayerTank --
----------------------
local PlayerTank = Tank:extend() -- inherit Tank

function PlayerTank:new()
  PlayerTank.super.new(self)
  -- set inputs??
  self.tank_type = TANK_TYPES.P1
  self.speed = 1
  -- up, left, down, right, fire, plant mine
  self.inputs = {
    up = {"w"},
    left = {"a"},
    down = {"s"},
    right = {"d"},
    fire = {"space"},
    mine = {"lshift"}
  }
end

function PlayerTank:set_inputs(inputs)
  self.inputs = {
    up = inputs.up or self.inputs.up,
    left = inputs.left or self.inputs.left,
    down = inputs.down or self.inputs.down,
    right = inputs.right or self.inputs.right,
    fire = inputs.fire or self.inputs.fire,
    mine = inputs.mine or self.inputs.mine
  }
end

function PlayerTank:check_inputsdown()
  if input.anykeysdown(self.inputs.up) then
    self:change_y(-1)
  end
  if input.anykeysdown(self.inputs.down) then
    self:change_y(1)
  end

  if input.anykeysdown(self.inputs.left) then
    self:change_x(-1)
  end
  if input.anykeysdown(self.inputs.right) then
    self:change_x(1)
  end
end

function PlayerTank:check_inputspressed(key)
  if input.anykeyequal(key, self.inputs.fire) then
    self:fire()
  end
  if input.anykeyequal(key, self.inputs.mine) then
    self:plant_mine()
  end
end

function PlayerTank:update()
  PlayerTank.super.update(self)
  -- input movement

  -- check movement collisions
end

---------------------
-- class EnemyTank -- 
---------------------
local EnemyTank = Tank:extend() -- inherit Tank


tc = { TANK_TYPES = TANK_TYPES, PlayerTank = PlayerTank, EnemyTank = EnemyTank }

return tc