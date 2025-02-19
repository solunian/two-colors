local love = require("love")
local push = require("lib.push")
local switch = require("color.switch")

local constants = require("util.constants")
local input = require("util.input")
local picker = require("color.picker")
local tetra = require("tetra.tetra")
local tanks = require("tanks.tanks")
local gamestate = require("util.gamestate")


-- all game_states must have functions: load(), update(dt), keypressed(key, scancode, isrepeat), draw()
local game_states = { picker, tetra, tanks }
local state = 3
local num_states = 3 -- for dev purposes
local time_to_switch_colors = 5 -- color switch threshold time


local change_game = function (game_val)
  state = game_val
  game_states[state].load()
end

function love.resize(w, h)
  return push:resize(w, h)
end


-- love functions!

function love.load()
  push:setupScreen(constants.window_width, constants.window_height, constants.window_width, constants.window_height,
    {
      fullscreen = false,
      resizable = true,
      highdpi = true,
    }
  )

  game_states[state].load()
end

function love.update(dt)
  if not gamestate.is_paused then
    game_states[state].update(dt)

    -- switch timer
    if game_states[state] ~= picker then
      switch.update_switch_color(dt, time_to_switch_colors)
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  -- for dev stuff!
  if input.anykeyequal(key, {"return"}) then -- switching game states
    change_game(state % num_states + 1) -- should be % by the number of states
    switch.reset_elapsed_time()
  end
  if input.anykeyequal(key, {"escape"}) then
    gamestate.is_paused = not gamestate.is_paused
  end

  if not gamestate.is_paused then
    game_states[state].keypressed(key, scancode, isrepeat)
  end
end

function love.draw()
  push:start()

  game_states[state].draw()

  -- for keeping track of bounding box for game window size
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", 0, 0, constants.window_width, constants.window_height)

  push:finish()
end
