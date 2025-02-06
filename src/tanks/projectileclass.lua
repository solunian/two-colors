local Object = require("lib.object")

local pc = {} -- projectile class

Projectile = Object:extend()

function Projectile:new(x, y, theta)
  self.x, self.y = x, y
  self.r = 10
  self.speed = 350
  self.dx = self.speed * math.cos(theta)
  self.dy = self.speed * math.sin(theta)

  print(self.x, self.y)
end

function Projectile:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

pc = { Projectile = Projectile }

return pc