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
local Tank = {
  tank_type = TANK_TYPES.NIL,
  x = 0, y = 0, w = 20, h = 20,
  rotation = 0, speed = 0, rotation_speed = 0
}

Tank.new = function (self)
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

Tank.set_pos = function (self, x, y)
  self.x = x
  self.y = y
end

Tank.change_x = function (self, dx)
  self.x = self.x + dx
end

Tank.change_y = function (self, dy)
  self.y = self.y + dy
end

Tank.fire = function (self)
  print("fire!")
end

Tank.plant_mine = function (self)
  print("plant mine!")
end

-- collider table must have x, y, w, h, rotation
Tank.has_collided = function (self, collider)
end

Tank.draw = function (self)

end

----------------------
-- class PlayerTank --
----------------------
local PlayerTank = Tank:new() -- inherit Tank
PlayerTank.new = function (self) -- polymorphism in the constructor???
  local obj = Tank:new()
  setmetatable(obj, self)
  self.__index = self

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

  return obj
end

PlayerTank.set_inputs = function(self, inputs)
  self.inputs = {
    up = inputs.up or self.inputs.up,
    left = inputs.left or self.inputs.left,
    down = inputs.down or self.inputs.down,
    right = inputs.right or self.inputs.right,
    fire = inputs.fire or self.inputs.fire,
    mine = inputs.mine or self.inputs.mine
  }
end

PlayerTank.check_inputsdown = function(self)
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

PlayerTank.check_inputspressed = function(self, key)
  if input.anykeyequal(key, self.inputs.fire) then
    self:fire()
  end
  if input.anykeyequal(key, self.inputs.mine) then
    self:plant_mine()
  end
end

PlayerTank.update = function(self)
  Tank.update(self)
  -- input movement

  -- check movement collisions
end

---------------------
-- class EnemyTank -- 
---------------------
local EnemyTank = Tank:new() -- inherit Tank


tc = { TANK_TYPES = TANK_TYPES, PlayerTank = PlayerTank, EnemyTank = EnemyTank }

return tc