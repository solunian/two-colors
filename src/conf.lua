local love = require("love")

function love.conf(game)
  game.window.title = "two colors"
  game.window.width = 1280
  game.window.height = 720
  game.window.msaa = 4 -- multi-sample anti-aliasing
  game.window.highdpi = true
  -- game.window.fullscreen = true
  game.window.resizable = false
end
