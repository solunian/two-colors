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

function Tank:new()
  self.tank_type = TANK_TYPES.NIL
  self.x, self.y = 0, 0
  self.w, self.h = 50, 50
  self.rotation = 0
  self.speed = 0
  self.rotation_speed = 0
  self.projectiles = {}
  self.is_active = false
end

function Tank:set_pos(x, y)
  self.x = x
  self.y = y
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
  if not self.is_active then
    return
  end

  table.insert(self.projectiles, projectileclass.Projectile(self.x + self.w / 2, self.y + self.h / 2, self.rotation))
  print("fire!")
end

function Tank:plant_mine()
  if not self.is_active then
    return
  end

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
    if #self.projectiles < 5 then
      self:fire()
    end
  end
  if input.anykeyequal(key, self.inputs.mine) then
    self:plant_mine()
  end
end

function PlayerTank:update(dt)
  self:check_inputsdown(dt)

  -- input movement
  local mousex, mousey = input.get_mouse()
  local dx, dy = mousex - (self.x + self.w / 2), mousey - (self.y + self.h / 2)
  local rotation = math.atan2(dy, dx)

  self.rotation = rotation

  local proj_idx = #self.projectiles
  while proj_idx > 0 do
    if self.projectiles[proj_idx].bounces >= self.projectiles[proj_idx].bounces_to_destroy then
      table.remove(self.projectiles, proj_idx)
    end
    proj_idx = proj_idx - 1
  end

  -- check movement collisions
end

---------------------
-- class EnemyTank -- 
---------------------
local EnemyTank = Tank:extend() -- inherit Tank


tc = { TANK_TYPES = TANK_TYPES, PlayerTank = PlayerTank, EnemyTank = EnemyTank }

return tc