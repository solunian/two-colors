local love = require("love")
local picker = require("color.picker")
local board = require("tetra.board")
local minos = require("tetra.minos")

local d = {}

local font_jetbrainsmono = love.graphics.newFont("assets/fonts/JetBrainsMono-Regular.ttf", 48)
local lines_cleared_text = love.graphics.newText(font_jetbrainsmono, board.lines_cleared)

local draw_mino = function (mino, x_offset, y_offset)
  for row=1,4 do
    for col=1,4 do
      if mino[(row - 1) * 4 + col] == minos.rot_ty.FILLED then
        love.graphics.rectangle("fill", x_offset + (col - 1) * board.ss, y_offset + (row - 1) * board.ss, board.ss, board.ss)
      end
    end
  end
end

d.draw = function (xoffset, yoffset)
  -- calc all colors
  local c1 = picker.lens_rcolor
  local c2 = picker.lens_lcolor
  local inverted_color = {1 - (c1[1] + c2[1]) / 2, 1 - (c1[2] + c2[2]) / 2, 1 - (c1[3] + c2[3]) / 2}
  love.graphics.setColor(inverted_color) -- all set to the same color. inverted?? just for hold, queue

  local peek = minos.peek_bag(5)

  -- hold piece
  if minos.hold_type ~= 0 then
    draw_mino(minos.rots[minos.hold_type][minos.ori.U], xoffset - board.ss * 5, yoffset + board.ss)
  end

  -- next pieces in line
  for i,v in ipairs(peek) do
    draw_mino(minos.rots[v][minos.ori.U], xoffset + board.ss * (board.w + 1), yoffset + (i - 1) * board.ss * 4)
  end

  -- lines cleared text
  lines_cleared_text:set(board.lines_cleared)
  love.graphics.draw(lines_cleared_text, xoffset - board.ss * 4, yoffset + board.ss * board.h)
end


return d