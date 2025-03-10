local Object = require("lib.object")
local constants = require("util.constants")
local misc      = require("util.misc")

local pc = {} -- projectile class

Projectile = Object:extend()

function Projectile:new(x, y, direction, parent)
  self.x, self.y = x, y
  self.r = 8
  self.speed = 400
  self.direction = direction
  self.dx = self.speed * math.cos(direction)
  self.dy = self.speed * math.sin(direction)
  self.bounces = 0
  self.bounces_to_destroy = 2

  -- for not killing parent on fire
  self.is_live_round = false
  self.parent = parent
end

function Projectile:update(dt)
  -- make it follow turrent when being fired out, close enough
  if not self.is_live_round then
    self.dx = self.speed * math.cos(self.parent.rotation)
    self.dy = self.speed * math.sin(self.parent.rotation)
  end

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
  self.direction = math.atan2(self.dy, self.dx)
end

function Projectile:has_collided(other)
  -- check if the distance between two circles is less than the distance from two of the radii
  -- squared both sides to not use slow sqrt function
  return math.pow(self.x - other.x, 2) + math.pow(self.y - other.y, 2) <= math.pow(self.r + other.r, 2)
end

pc = { Projectile = Projectile }

return pc