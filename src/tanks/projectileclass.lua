local Object = require("lib.object")
local constants = require("util.constants")

local pc = {} -- projectile class

Projectile = Object:extend()

function Projectile:new(x, y, theta, parent)
  self.x, self.y = x, y
  self.r = 10
  self.speed = 350
  self.dx = self.speed * math.cos(theta)
  self.dy = self.speed * math.sin(theta)
  self.bounces = 0
  self.bounces_to_destroy = 2

  -- for not killing parent on fire
  self.is_live_round = false
  self.parent = parent
end

function Projectile:update(dt)
  -- for not killing parent on spawn
  if not self.is_live_round and not self.parent:has_collided(self) then
    self.is_live_round = true
  end

  if self.y - self.r < 0 then
    self.dy = math.abs(self.dy)
    self.bounces = self.bounces + 1
  end
  if self.y + self.r > constants.window_height then
    self.dy = -math.abs(self.dy)
    self.bounces = self.bounces + 1
  end
  if self.x - self.r < 0 then
    self.dx = math.abs(self.dx)
    self.bounces = self.bounces + 1
  end
  if self.x + self.r > constants.window_width then
    self.dx = -math.abs(self.dx)
    self.bounces = self.bounces + 1
  end

  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

pc = { Projectile = Projectile }

return pc