local love = require("love")
local misc = require("util.misc")
local Object = require("lib.object")
local input = require("util.input")
local projectileclass = require("tanks.projectileclass")
local constants       = require("util.constants")

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

function Tank:new(x, y, allprojectiles)
  self.tank_type = TANK_TYPES.NIL
  self.x, self.y = x, y
  self.w, self.h = 50, 50 -- should be square for collisions
  self.rotation = 0
  self.speed = 0
  self.rotation_speed = 0
  self.allprojectiles = allprojectiles -- reference to allprojectiles in main game
  self.projectiles = {}
  self.is_active = true
  self.projectiles_limit = 5
end

function Tank:remove_projectile(proj)
  for idx,p in pairs(self.projectiles) do
    if p == proj then
      table.remove(self.projectiles, idx)
      return
    end
  end
end

function Tank:change_x(dx)
  if not self.is_active then
    return
  end

  if self.x + dx < 0 then
    self.x = 0
  elseif self.x + dx + self.w > constants.window_width then
    self.x = constants.window_width - self.w
  else
    self.x = self.x + dx
  end
end

function Tank:change_y(dy)
  if not self.is_active then
    return
  end

  if self.y + dy < 0 then
    self.y = 0
  elseif self.y + dy + self.h > constants.window_height then
    self.y = constants.window_height - self.h
  else
    self.y = self.y + dy
  end
end

function Tank:fire()
  if not self.is_active or #self.projectiles >= self.projectiles_limit then
    return
  end

  local newly_fired_proj = projectileclass.Projectile(self.x + self.w / 2, self.y + self.h / 2, self.rotation, self)
  table.insert(self.projectiles, newly_fired_proj)
  table.insert(self.allprojectiles, newly_fired_proj)
  print("fire!")
end

function Tank:plant_mine()
  if not self.is_active then
    return
  end

  print("plant mine!")
end

-- projectile must have x, y, r
function Tank:has_collided(projectile)
  -- give the tank a circle hitbox
  return math.pow((self.x + self.w / 2) - projectile.x, 2) + math.pow((self.y + self.h / 2) - projectile.y, 2) <= math.pow(self.w / 2 + projectile.r, 2)
end

function Tank:check_collisions_with_projectile()
  if not self.is_active then
    return
  end

  -- tank with projectile collision
  for _,proj in pairs(self.allprojectiles) do
    if self:has_collided(proj) and proj.is_live_round then
      print("dead!")
      self.is_active = false
      return
    end
  end
end

function Tank:update(dt)
end

function Tank:draw(color)
  -- tank
  love.graphics.setColor(color)
  misc.round_rectangle(self.x, self.y, self.w, self.h, 10)

  local cenx, ceny = self.x + self.w / 2, self.y + self.h / 2
  love.graphics.setLineWidth(16)
  love.graphics.line(cenx, ceny, cenx + self.w * math.cos(self.rotation), ceny + self.w * math.sin(self.rotation))
  love.graphics.setLineWidth(1)
end

----------------------
-- class PlayerTank --
----------------------
local PlayerTank = Tank:extend() -- inherit Tank

function PlayerTank:new(x, y, allprojectiles)
  PlayerTank.super.new(self, x, y, allprojectiles)
  -- set inputs??
  self.tank_type = TANK_TYPES.P1
  self.speed = 125
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

function PlayerTank:check_inputsdown(dt)
  if input.allkeysdown({self.inputs.up, self.inputs.down, self.inputs.left, self.inputs.right}) then
    return
  end

  if input.allkeysdown({self.inputs.up, self.inputs.left, self.inputs.right}) then -- 3 down, one direction
    self:change_y(-self.speed * dt)
  elseif input.allkeysdown({self.inputs.down, self.inputs.left, self.inputs.right}) then
    self:change_y(self.speed * dt)
  elseif input.allkeysdown({self.inputs.left, self.inputs.up, self.inputs .down}) then
    self:change_x(-self.speed * dt)
  elseif input.allkeysdown({self.inputs.right, self.inputs.up, self.inputs.down}) then
    self:change_x(self.speed * dt)
  elseif input.allkeysdown({self.inputs.up, self.inputs.right}) then -- 2 down, diagonals
    self:change_x(self.speed * math.cos(math.pi / 4) * dt)
    self:change_y(-self.speed * math.sin(math.pi / 4) * dt)
  elseif input.allkeysdown({self.inputs.up, self.inputs.left}) then
    self:change_x(-self.speed * math.cos(math.pi / 4) * dt)
    self:change_y(-self.speed * math.sin(math.pi / 4) * dt)
  elseif input.allkeysdown({self.inputs.down, self.inputs.right}) then
    self:change_x(self.speed * math.cos(math.pi / 4) * dt)
    self:change_y(self.speed * math.sin(math.pi / 4) * dt)
  elseif input.allkeysdown({self.inputs.down, self.inputs.left}) then
    self:change_x(-self.speed * math.cos(math.pi / 4) * dt)
    self:change_y(self.speed * math.sin(math.pi / 4) * dt)
  elseif input.allkeysdown({self.inputs.up}) and not input.allkeysdown({self.inputs.down}) then -- one down, one direction
    self:change_y(-self.speed * dt)
  elseif input.allkeysdown({self.inputs.down}) and not input.allkeysdown({self.inputs.up}) then
    self:change_y(self.speed * dt)
  elseif input.allkeysdown({self.inputs.left}) and not input.allkeysdown({self.inputs.right}) then
    self:change_x(-self.speed * dt)
  elseif input.allkeysdown({self.inputs.right}) and not input.allkeysdown({self.inputs.left}) then
    self:change_x(self.speed * dt)
  end

  -- if input.anykeysdown(self.inputs.left) then
  --   self:change_x(-1)
  -- end
  -- if input.anykeysdown(self.inputs.right) then
  --   self:change_x(1)
  -- end
end

function PlayerTank:check_inputspressed(key)
  if input.anykeyequal(key, self.inputs.fire) then
    self:fire()
  end
  if input.anykeyequal(key, self.inputs.mine) then
    self:plant_mine()
  end
end

function PlayerTank:update(dt)
  if not self.is_active then
    return
  end

  PlayerTank.super.update(self, dt)

  self:check_inputsdown(dt)

  -- input movement
  local mousex, mousey = input.get_mouse()
  local dx, dy = mousex - (self.x + self.w / 2), mousey - (self.y + self.h / 2)
  local rotation = math.atan2(dy, dx)

  self.rotation = rotation


  -- check movement collisions
end


function PlayerTank:draw(color)
  -- no mouse?
  -- love.mouse.setVisible(false)
  if self.is_active then
    local mousex, mousey = input.get_mouse()

    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(1)
    love.graphics.line(self.x + self.w / 2, self.y + self.h / 2, mousex, mousey)

    love.graphics.rectangle("fill", mousex - 10, mousey - 2, 20, 4)
    love.graphics.rectangle("fill", mousex - 2, mousey - 10, 4, 20)
  end

  PlayerTank.super.draw(self, color)
end

---------------------
-- class EnemyTank -- 
---------------------
local EnemyTank = Tank:extend() -- inherit Tank

function EnemyTank:new(x, y, allprojectiles)
  EnemyTank.super.new(self, x, y, allprojectiles)

  self.tank_type = TANK_TYPES.E1
  self.speed = 125

  self.rotation_speed = 1
end

local time_count = 0
local move_threshold_time = 1

function EnemyTank:update(dt)
  EnemyTank.super.update(self, dt)

  if not self.is_active then
    return
  end

  time_count = time_count + dt
  self.rotation = self.rotation + dt * self.rotation_speed

  if time_count >= move_threshold_time then
    time_count = 0
    self:fire()
  end

  self:change_x(self.speed * math.cos(self.rotation) * dt)
  self:change_y(self.speed * math.sin(self.rotation) * dt)
end


tc = { TANK_TYPES = TANK_TYPES, PlayerTank = PlayerTank, EnemyTank = EnemyTank }

return tc