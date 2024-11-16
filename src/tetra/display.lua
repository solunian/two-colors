local love = require("love")

local board = require("tetra.board")
local minos = require("tetra.minos")

local d = {}

local x, y = 300, board.ss

local font_jetbrainsmono = love.graphics.newFont("assets/fonts/JetBrainsMono-Regular.ttf", 64)
local lines_cleared_text = love.graphics.newText(font_jetbrainsmono, board.lines_cleared)

local draw_mino = function (mino, x_offset, y_offset)
  for row=1,4 do
    for col=1,4 do
      if mino[(row - 1) * 4 + col] == minos.rot_ty.FILLED then
        love.graphics.setColor(0, 1, 0, 1);
        love.graphics.rectangle("fill", x + x_offset + (col - 1) * board.ss, y + y_offset + (row - 1) * board.ss, board.ss, board.ss)
      end
    end
  end
end

d.draw = function ()
  local peek = minos.peek_bag(5)

  if minos.hold_type ~= 0 then
    draw_mino(minos.rots[minos.hold_type][minos.ori.U], 0, 0)
  end

  for i,v in ipairs(peek) do
    draw_mino(minos.rots[v][minos.ori.U], board.ss * 4 + board.ss * 2, (i - 1) * board.ss * 4)
  end

  lines_cleared_text:set(board.lines_cleared)
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.draw(lines_cleared_text, x, y + 100)
end


return d