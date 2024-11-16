local love = require("love")
local table = require("table")

local b = {}

-- playfield is top to bottom, as a 2D table visual representation
-- (3, 3) is top left, (23,23) is bottom right, rows 1-3 are spawn rows
b.pf = {}
b.active = false
b.lines_cleared = 0 -- reset whenever reinit_playfield

-- constant values --

b.ss = 25 -- square size for grid
b.w = 10 -- width
b.h = 20 -- height
b.sh = 3 -- spawn height, playfield must have 3 extra spawn rows
b.ty = { EMPTY = 1, FILLED = 2, ACTIVE = 3, SHADOW = 4 } -- block types


-- helper functions

local is_row_full = function (row)
  for i=1,b.w do
    if b.pf[row][i] ~= b.ty.FILLED then
      return false
    end
  end
  return true
end

--------------------------------------------------------
-- table functions, can be called outside in the game --
--------------------------------------------------------

-- reset and init playfield
b.reinit_playfield = function ()
  b.lines_cleared = 0

  b.pf = {}
  for _=1,b.sh+b.h do
    local curr = {}
    for _=1,b.w do
      table.insert(curr, b.ty.EMPTY);
    end
    table.insert(b.pf, curr);
  end
end

-- debugging
b.print_playfield = function ()
  for i=1,b.sh+b.h do
    for j=1,b.w do
      io.write(b.pf[i][j] .. " ")
    end
    io.write("\n")
  end
end

-- for game over?
b.freeze_active = function ()
  for i=1,b.sh+b.h do
    for j=1,b.w do
      if b.pf[i][j] == b.ty.ACTIVE then
        b.pf[i][j] = b.ty.FILLED
      end
    end
  end
end

-- check if row 2 of spawn height rows has filled
b.is_game_over = function ()
  for i=1,b.w do
    if b.pf[1][i] == b.ty.FILLED or b.pf[2][i] == b.ty.FILLED then
      return true
    end
  end

  return false
end

-- called only at hard_drop
b.clear_rows = function ()
  local checkrow = b.sh + b.h
  -- for loop variable cannot be changed in loop!
  while checkrow >= 1 do
    if is_row_full(checkrow) then
      -- clear full row
      for i=1,b.w do
        if b.pf[checkrow][i] ~= b.ty.ACTIVE then
          b.pf[checkrow][i] = b.ty.EMPTY
        end
      end

      -- move everything down
      for moverow = checkrow - 1, 1, -1 do
        for i=1,b.w do
          if b.pf[moverow][i] == b.ty.FILLED then
            b.pf[moverow + 1][i] = b.pf[moverow][i] -- move row down
            b.pf[moverow][i] = b.ty.EMPTY -- clear old stuff
          end
        end
      end
      -- if cleared one, check the row shifted down
      checkrow = checkrow + 1
      b.lines_cleared = b.lines_cleared + 1
    end
    -- decrement, pushing the check row up the playfield
    checkrow = checkrow - 1
  end
end

b.draw = function ()
  -- draw current board with all the squares
  for row=1,b.sh+b.h do
    for col=1,b.w do
      if b.pf[row][col] == b.ty.FILLED then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", (col - 1) * b.ss, (row - 1) * b.ss, b.ss, b.ss)
      elseif b.pf[row][col] == b.ty.ACTIVE then
        love.graphics.setColor(0, 0, 1, 1);
        love.graphics.rectangle("fill", (col - 1) * b.ss, (row - 1) * b.ss, b.ss, b.ss)
      elseif b.pf[row][col] == b.ty.SHADOW then
        love.graphics.setColor(0, 0, 1, 0.5);
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