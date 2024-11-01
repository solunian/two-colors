local love = require("love")

local board = require("lib.board")
local minos = require("lib/minos")

function love.load()
  love.window.setTitle("two colors")

  board.reinit_playfield()
  -- board.print_playfield(board.w, board.h)

  minos.spawn(minos.ts.L)
end

function love.update(dt)
end

function love.draw()
  board.draw()
end