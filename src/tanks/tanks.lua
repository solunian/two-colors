local love = require("love")
local picker = require("color.picker")
local tankclass = require("tanks.tankclass")
local MinHeap = require("lib.minheap")
local constants = require("util.constants")

local t = {}

local player
local tanks = {} -- all pointers to tanks
local projectiles = {} -- all pointers to projectiles, each tank also points to projectiles, so must remove those pointers to drop to garbage
local mines = {}
local enemy_spawn_count = 1 -- level essentially

local function reset_level()
  tanks = {}
  projectiles = {}
  mines = {}
end

-- before leveling up and spawn_enemies
local function remove_enemies()
  -- remove all enemy tanks
  local i = #tanks
  while i > 0 do
    if tanks[i].tank_type == tankclass.TANK_TYPES.E1 then
      table.remove(tanks, i)
    end
    i = i - 1
  end
end

local function spawn_enemies()
  -- x, y doesnt matter cuz i coded it to be rondom now...
  for _=1,enemy_spawn_count do
    table.insert(tanks, tankclass.EnemyTank(0, 0, projectiles))
  end
end

local function spawn_player()
  player = tankclass.PlayerTank(constants.window_width / 2, constants.window_height / 2, projectiles)
  table.insert(tanks, player)
end


t.load = function ()
  reset_level()
  spawn_enemies()
  spawn_player()
end

t.update = function (dt)
  local only_player_active = player.is_active
  for _,v in pairs(tanks) do
    if v.tank_type ~= tankclass.TANK_TYPES.P1 and v.is_active then
      only_player_active = false
      break
    end
  end

  if only_player_active then -- either player is active and other tanks are not
    -- increase difficulty level
    enemy_spawn_count = enemy_spawn_count + 1
    remove_enemies()
    spawn_enemies()

  elseif not player.is_active then -- player is not active

    -- decrease difficulty level
    if enemy_spawn_count > 1 then
      enemy_spawn_count = enemy_spawn_count - 1
    end

    reset_level()
    spawn_enemies()
    spawn_player()
  end

  for _,tank in pairs(tanks) do
    if tank.is_active then -- only update if is_active

      -- enemy movement predictions trying to avoid projectiles
      -- naive solution: make movement perpendicular to projectile direction, pick movement based on closest one
      if tank.tank_type == tankclass.TANK_TYPES.E1 then
        tank.rotation = math.atan2((player.y + player.h / 2) - (tank.y + tank.h / 2), (player.x + player.w / 2) - (tank.x + tank.w / 2))

        -- push all projectiles into a priority queue based on their distance away from tank. closer projectiles are checked first (min distance)
        local closest_projs = MinHeap.new()
        for _,proj in pairs(projectiles) do
          closest_projs:push(proj, tank:distance(proj))
        end

        while not closest_projs:isempty() do
          local curr = closest_projs:peek()
          if tank:check_intercept(curr) then
            break
          else
            closest_projs:pop()
          end

        end

        -- should only move if has incoming projectiles. it would have all popped out of binheap
        if closest_projs:isempty() then
          tank.should_move = false
        else
          tank.should_move = true
        end
      end

      tank:update(dt)
      tank:check_collisions_with_projectile()

    end
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
end

t.keypressed = function (key, scancode, isrepeat)
  if key == "r" then
    print("=====")
    enemy_spawn_count = 1
    reset_level()
    spawn_enemies()
    spawn_player()
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