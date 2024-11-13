local love = require("love")
local table = require("table")

local b = {}

-- constant values --

b.ss = 25 -- square size for grid
b.w = 10 -- width
b.h = 20 -- height
b.sh = 3 -- spawn height, playfield must have 3 extra spawn rows
b.ty = { EMPTY = 1, FILLED = 2, ACTIVE = 3 } -- block types


-- playfield is upside down!
-- (3, 3) is top left, (23,23) is bottom right, rows 1-3 are spawn rows
b.pf = {}
b.active = false

-- reset and init playfield
b.reinit_playfield = function ()
  b.pf = {}
  for _=1,b.sh+b.h do
    local curr = {}
    for _=1,b.w do
      table.insert(curr, b.ty.EMPTY);
    end
    table.insert(b.pf, curr);
  end
end

b.print_playfield = function (w, h)
  for i=1,h do
    for j=1,w do
      io.write(b.pf[i][j] .. " ")
    end
    io.write("\n")
  end
end

local is_row_full = function (row)
  for i=1,b.w do
    if b.pf[row][i] ~= b.ty.FILLED then
      return false
    end
  end
  return true
end

b.clear_rows = function ()
  for checkrow=b.sh+b.h, b.sh - 1, -1 do
    if is_row_full(checkrow) then
      -- push all rows down
      for row=checkrow, b.sh - 1, -1 do
        -- clear current row
        for i=1,b.w do
          if b.pf[row][i] ~= b.ty.ACTIVE then
            b.pf[row][i] = b.ty.EMPTY
          end
        end
        -- push down all filled pieces
        for i=1,b.w do
          if b.pf[row - 1][i] == b.ty.FILLED then
            b.pf[row][i] = b.pf[row - 1][i]
          end
        end
        -- clean next row
        for i=1,b.w do
          if b.pf[row - 1][i] == b.ty.FILLED then
            b.pf[row - 1][i] = b.ty.EMPTY
          end
        end
      end
    end
  end
end

b.draw = function ()
    -- draw current board with all the squares
    for row=1,b.sh+b.h do
      for col=1,b.w do
        if b.pf[row][col] == b.ty.FILLED then
          love.graphics.setColor(love.math.colorFromBytes(255, ((row * 10) % 255), ((col * 10) % 255)))
          love.graphics.rectangle("fill", (col - 1) * b.ss, (row - 1) * b.ss, b.ss, b.ss);
        elseif b.pf[row][col] == b.ty.ACTIVE then
          love.graphics.setColor(0, 1, 0, 1);
          love.graphics.rectangle("fill", (col - 1) * b.ss, (row - 1) * b.ss, b.ss, b.ss);
        end
      end
    end

  -- draw grid lines
  for row=b.sh,b.sh+b.h do -- extra one for bottom border
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.line(0, row * b.ss, b.w * b.ss, row * b.ss)
  end
  for col=0,b.w do -- extra one for bottom border
    love.graphics.line(col * b.ss, 0, col * b.ss, (b.h + b.sh) * b.ss)
  end
end

return b