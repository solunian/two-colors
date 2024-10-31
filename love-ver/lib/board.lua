local love = require("love")
local table = require("table")
local io = require("io")


local b = {}

-- constant values --

b.ss = 25 -- square size for grid
b.w = 10 -- width
b.h = 20 -- height
b.sh = 3 -- spawn height, playfield must have 3 extra spawn rows
b.type = { EMPTY = 1, FILLED = 2}


-- playfield is upside down!
-- (1,1) is bottom left, (20,20) is top right, rows 21-23 are spawn rows
b.pf = {}

-- reset and init playfield
b.reinit_playfield = function ()
  for _=1,b.h+b.sh do
    local curr = {}
    for _=1,b.w do
      table.insert(curr, b.type.EMPTY);
    end
    table.insert(b.pf, curr);
  end
end

b.print_playfield = function (w, h)
  for i=h,1,-1 do
    for j=1,w do
      io.write(b.pf[i][j] .. " ")
    end
    io.write("\n")
  end
end



b.draw = function ()
    -- draw current board with all the squares
    for row=b.h+b.sh,1,-1 do
      for col=1,b.w do
        if b.pf[row][col] == b.type.FILLED then
          love.graphics.setColor(love.math.colorFromBytes(255, ((row * 10) % 255), ((col * 10) % 255)))
          love.graphics.rectangle("fill", (col - 1) * b.ss, (row - 1) * b.ss, b.ss, b.ss);
        end
      end
    end

  -- draw grid lines
  for row=b.sh,b.h+b.sh do -- extra one for bottom border
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.line(0, row * b.ss, b.w * b.ss, row * b.ss)
  end

  for col=0,b.w do -- extra one for bottom border
    love.graphics.line(col * b.ss, 0, col * b.ss, (b.h + b.sh) * b.ss)
  end
end


return b