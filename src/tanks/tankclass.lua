local tc = {} -- tank class

local TANK_TYPES = {
  P1 = 1, P2 = 2, P3 = 3, P4 = 4,
  E1 = 5, E2 = 6 -- https://nintendo.fandom.com/wiki/Tanks!
}

----------------
-- class Tank --
----------------
local Tank = { x = 0, y = 0, speed = 0, direction = 0, rotation_speed = 0 }

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

Tank.update = function (self)
  print("update tank " .. self.x .. " " .. self.y)
end

Tank.draw = function (self)
end

----------------------
-- class PlayerTank --
----------------------
local PlayerTank = Tank:new()
PlayerTank.new = function (self) -- polymorphism in the constructor???
  local obj = Tank:new()
  setmetatable(obj, self)
  self.__index = self
  -- set inputs??
  return obj
end

PlayerTank.set_inputs = function(self)
  print("setting inputs")
  self:set_pos(3, 5)
end

---------------------
-- class EnemyTank -- 
---------------------
local EnemyTank = Tank:new()

tc = { TANK_TYPES = TANK_TYPES, PlayerTank = PlayerTank, EnemyTank = EnemyTank }

return tc