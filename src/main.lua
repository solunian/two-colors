local love = require("love")

local input = require("util.input")
local matching = require("color.matching")
local tetra = require("tetra.tetra")
local tanks = require("tanks.tanks")

local game_states = { matching, tetra, tanks }
local state = 1
local num_states = 3 -- for dev purposes


local change_game = function (game_val)
  state = game_val
  game_states[state].load()
end


-- love functions!

function love.load()
  game_states[state].load()
end

function love.update(dt)
  game_states[state].update(dt)
end

function love.keypressed(key, scancode, isrepeat)
  -- for dev stuff!
  if input.anykeyequal(key, {"return"}) then
    change_game(state % num_states + 1) -- should be % by the number of states
  end

  game_states[state].keypressed(key, scancode, isrepeat)
end

function love.draw()
  game_states[state].draw()
end
