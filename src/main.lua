local love = require("love")
local push = require("lib.push")

local constants = require("util.constants")
local input = require("util.input")
local picker = require("color.picker")
local tetra = require("tetra.tetra")
local tanks = require("tanks.tanks")

push:setupScreen(constants.window_width, constants.window_height, constants.window_width, constants.window_height,
  {
    fullscreen = false,
    resizable = true,
    highdpi = true,
  }
)


-- all game_states must have functions: load(), update(dt), keypressed(key, scancode, isrepeat), draw()
local game_states = { picker, tetra, tanks }
local state = 1
local num_states = 3 -- for dev purposes


local change_game = function (game_val)
  state = game_val
  game_states[state].load()
end

function love.resize(w, h)
  return push:resize(w, h)
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
  push:start()

  game_states[state].draw()

  -- for keeping track of bounding box for game window size
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", 0, 0, constants.window_width, constants.window_height)

  push:finish()
end
