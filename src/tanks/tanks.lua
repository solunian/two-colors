local love = require("love")
local picker = require("color.picker")
local tankclass = require("tanks.tankclass")

local t = {}

local tanks = {} -- all pointers to tanks
local projectiles = {} -- all pointers to projectiles, each tank also points to projectiles, so must remove those pointers to drop to garbage
local mines = {}

local function reset_level()
  tanks = {}
  projectiles = {}
  mines = {}
end

local function level1()
  table.insert(tanks, tankclass.EnemyTank(200, 300, projectiles))
  table.insert(tanks, tankclass.EnemyTank(400, 100, projectiles))
  table.insert(tanks, tankclass.EnemyTank(500, 400, projectiles))
  table.insert(tanks, tankclass.PlayerTank(100, 100, projectiles))
end


t.load = function ()
  reset_level()
  level1()
end

t.update = function (dt)
  for _,tank in pairs(tanks) do
    tank:update(dt)
    tank:check_collisions_with_projectile()
  end

  for _,proj in pairs(projectiles) do
    proj:update(dt)
  end

  -- check projectile bounce destruction
  local bi = #projectiles -- bounce index
  while bi > 0 do
    if projectiles[bi].bounces >= projectiles[bi].bounces_to_destroy then
      projectiles[bi].parent:remove_projectile(projectiles[bi])
      table.remove(projectiles, bi)
    end
    bi = bi - 1
  end

  -- check all projectile-projectile collisions
  local i = 1
    while i <= #projectiles do
      local j = i + 1
      while j <= #projectiles do
        if projectiles[i] ~= projectiles[j] and projectiles[i]:has_collided(projectiles[j]) then
          projectiles[i].parent:remove_projectile(projectiles[i])
          projectiles[j].parent:remove_projectile(projectiles[j])
          table.remove(projectiles, i)
          table.remove(projectiles, j - 1)

          i = i - 1 -- push back after removing its current value and getting pushed forward at end
          break
        end
        j = j + 1
      end
      i = i + 1
    end

  -- check positions
end

t.keypressed = function (key, scancode, isrepeat)
  if key == "r" then
    print("=====")
    reset_level()
    level1()
  end

  for _,tank in pairs(tanks) do
    if tank.tank_type == tankclass.TANK_TYPES.P1 then
      tank:check_inputspressed(key)
    end
  end
end

t.draw = function ()
  -- loop through tables to draw all of them
  for _,tank in pairs(tanks) do
    -- tank aim line, aim crosshair
    if tank.tank_type == tankclass.TANK_TYPES.P1 then
      tank:draw(picker.lens_lcolor)
    else
      tank:draw(picker.lens_rcolor)
    end

    for _,proj in pairs(tank.projectiles) do
      if tank.tank_type == tankclass.TANK_TYPES.P1 then
        love.graphics.setColor(picker.lens_lcolor)
      else
        love.graphics.setColor(picker.lens_rcolor)
      end
      love.graphics.circle("fill", proj.x, proj.y, proj.r)
    end
  end
end

return t