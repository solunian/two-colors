local love = require("love")

local board = require("tetra.board")
local minos = require("tetra.minos")


local restart_tetra = function()
  board.reinit_playfield()
  minos.reinit()
  minos.spawn()
  board.active = true
end


-- love functions --

function love.load()
  love.window.setTitle("two colors")

  restart_tetra()
end

local delta_time = 0
local gravity_time = 1 -- in seconds
function love.update(dt)
  -- movement
  if love.keyboard.isDown("right") then
    minos.lateral_move(1)
  elseif love.keyboard.isDown("left") then
    minos.lateral_move(-1)
  elseif love.keyboard.isDown("down") then
    minos.drop()
  end

  -- gravity???
  delta_time = delta_time + dt
  if delta_time >= gravity_time then
    minos.drop()
    delta_time = 0
  end
end

function love.keypressed(key, scancode, isrepeat)

  -- game inputs

  if key == "r" then -- reset / start game
    restart_tetra()
  end

  -- movement inputs!

  if key == "space" then -- lock
    minos.hard_drop()
  end

  -- rotations
  if key == "x" or key == "up" then -- clockwise
    minos.rotate(minos.orientation, (minos.orientation - 1 + 1) % 4 + 1) -- (ori -1 to 0-index, +1 for to right) % 4 for overflow, +1 for 1-index
  elseif key == "z" then -- counter
    minos.rotate(minos.orientation, (minos.orientation - 1 + 3) % 4 + 1)
  elseif key == "a" then -- 180
    minos.rotate(minos.orientation, (minos.orientation - 1 + 2) % 4 + 1)
  end
end

function love.draw()
  board.draw()
end