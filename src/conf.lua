local love = require("love")

local constants = require("util.constants")

function love.conf(game)
  game.window.title = "two colors"
  game.window.width = constants.window_width
  game.window.height = constants.window_height
  game.window.msaa = 8 -- multi-sample anti-aliasing
  game.window.highdpi = true

  -- USING PUSH LIB SO DO NOT SET FOLLOWING CONFIG VARS! --
  -- game.window.fullscreen = true
  -- game.window.resizable = true
end
