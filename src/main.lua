local love = require("love")

local tetra = require("tetra.tetra")

local games = { TETRA = 1 }
local current_game = 0


local change_game = function (game_val)
  if game_val == games.TETRA then
    tetra.load()
    current_game = games.TETRA
  end
end


-- love functions!

function love.load()
end

function love.update(dt)
  if current_game == games.TETRA then
    tetra.update(dt)
  end
end

function love.keypressed(key, scancode, isrepeat)
  -- for dev stuff!
  if key == "return" then
    change_game(games.TETRA)
  end

  if current_game == games.TETRA then
    tetra.keypressed(key, scancode, isrepeat)
  end
end

function love.draw()
  if current_game == games.TETRA then
    tetra.draw()
  end
end
