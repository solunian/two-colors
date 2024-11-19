local love = require("love")

local input = require("util.input")
local matching = require("color.matching")
local tetra = require("tetra.tetra")
local tanks = require("tanks.tanks")

local game_states = { MENU = 1, MATCHING = 2, TETRA = 3, TANKS = 4 }
local state = game_states.TANKS
local num_states = 4 -- for dev purposes


local change_game = function (game_val)
  if game_val == game_states.MATCHING then
    matching.load()
  elseif game_val == game_states.TETRA then
    tetra.load()
  elseif game_val == game_states.TANKS then
    tanks.load()
  end

  state = game_val
end


-- love functions!

function love.load()
  if state == game_states.MATCHING then
    matching.load()
  elseif state == game_states.TETRA then
    tetra.load()
  elseif state == game_states.TANKS then
    tanks.load()
  end
end

function love.update(dt)
  if state == game_states.MATCHING then
    matching.update(dt)
  elseif state == game_states.TETRA then
    tetra.update(dt)
  elseif state == game_states.TANKS then
    tanks.update(dt)
  end
end

function love.keypressed(key, scancode, isrepeat)
  -- for dev stuff!
  if input.anykeyequal(key, {"return"}) then
    change_game(state % num_states + 1) -- should be % by the number of states
  end

  if state == game_states.MATCHING then
    matching.keypressed(key, scancode, isrepeat)
  elseif state == game_states.TETRA then
    tetra.keypressed(key, scancode, isrepeat)
  elseif state == game_states.TANKS then
    tanks.keypressed(key, scancode, isrepeat)
  end
end

function love.draw()
  if state == game_states.MATCHING then
    matching.draw()
  elseif state == game_states.TETRA then
    tetra.draw()
  elseif state == game_states.TANKS then
    tanks.draw()
  end
end
