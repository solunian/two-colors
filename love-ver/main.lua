local love = require("love")

local board = require("lib.board")
local minos = require("lib/minos")

function love.load()
  love.window.setTitle("two colors")

  board.reinit_playfield()
  -- board.print_playfield(board.w, board.h)

  minos.spawn(minos.ts.L)
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