local math = require("math")

local board = require("lib.board")

local m = {}

-- mino types
m.ts = { I = 1, J = 2, L = 3, O = 4, S = 5, T = 6, Z = 7 }
-- mino orientations
m.ori = { U = 1, R = 2, D = 3, L = 4 }

-- all clockwise rotations. 4x4 with only I spanning 4 technically
m.rots = {
  { -- I
    {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0},
    {0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0},
  },
  { -- J
    {1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0},
  },
  { -- L
    {0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0},
    {1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
  },
  { -- O
    {0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  },
  { -- S
    {0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0},
    {1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
  },
  { -- T
    {0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0},
  },
  { -- Z
    {1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0},
    {0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
  }
}

-- test basic rotations, then 4 kicks (x,y offsets)
m.kicks_jlstz = {
  {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}, -- 0>>1
  { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}, -- 1>>0
  { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}, -- 1>>2
  {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}, -- 2>>1
  { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}, -- 2>>3
  {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}, -- 3>>2
  {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}, -- 3>>0
  { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}, -- 0>>3
}

m.kicks_i = {
  {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}, -- 0>>1
  { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}, -- 1>>0
  {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}, -- 1>>2
  { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}, -- 2>>1
  { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}, -- 2>>3
  {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}, -- 3>>2
  { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}, -- 3>>0
  {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}, -- 0>>3
}

m.kicks180_jlstz = {
  {{ 1, 0},{ 2, 0},{ 1, 1},{ 2, 1},{-1, 0},{-2, 0},{-1, 1},{-2, 1},{ 0,-1},{ 3, 0},{-3, 0}},  -- 0>>2─┐
  {{ 0, 1},{ 0, 2},{-1, 1},{-1, 2},{ 0,-1},{ 0,-2},{-1,-1},{-1,-2},{ 1, 0},{ 0, 3},{ 0,-3}},  -- 1>>3─┼┐
  {{-1, 0},{-2, 0},{-1,-1},{-2,-1},{ 1, 0},{ 2, 0},{ 1,-1},{ 2,-1},{ 0, 1},{-3, 0},{ 3, 0}},  -- 2>>0─┘│
  {{ 0, 1},{ 0, 2},{ 1, 1},{ 1, 2},{ 0,-1},{ 0,-2},{ 1,-1},{ 1,-2},{-1, 0},{ 0, 3},{ 0,-3}},  -- 3>>1──┘
}

m.kicks180_i = {
  {{-1, 0},{-2, 0},{ 1, 0},{ 2, 0},{ 0, 1}},  -- 0>>2─┐
  {{ 0, 1},{ 0, 2},{ 0,-1},{ 0,-2},{-1, 0}},  -- 1>>3─┼┐
  {{ 1, 0},{ 2, 0},{-1, 0},{-2, 0},{ 0,-1}},  -- 2>>0─┘│
  {{ 0, 1},{ 0, 2},{ 0,-1},{ 0,-2},{ 1, 0}},  -- 3>>1──┘
};


-- instance variables for active piece
-- x,y position is of top left corner of 4x4, can be negative!
m.x = 0
m.y = 0
m.type = m.ts.I
m.orientation = m.ori.U


-- helper functions

-- tests position after movement change to x,y! undo behavior if not working
-- playfield not updated before run!
m.does_pos_work = function ()
  return true
end


-- instance functions, uses instance variables (also board variables)

m.update_playfield = function ()
  -- clear old active blocks
  for row=1,board.sh+board.h do
    for col=1,board.w do
      if board.pf[row][col] == board.ts.ACTIVE then
        board.pf[row][col] = board.ts.EMPTY
      end
    end
  end

  -- replace with "updated" active blocks
  for row=1,4 do
    for col=1,4 do
      if m.rots[m.type][m.orientation][(row - 1) * 4 + col] == 1 then
        board.pf[row + m.y][col + m.x] = board.ts.ACTIVE
      end
    end
  end
end

m.spawn = function (type)
  local center_x = 0
  if board.w % 2 ~= 0 then
    center_x = math.floor(board.w / 2) - 1 -- odd offset -1 from middle
  else
    center_x = math.floor(board.w / 2) - 2 -- even offset -2 from the middle
  end

  m.x = center_x
  m.y = 0
  m.type = type
  m.orientation = m.ori.U

  m.update_playfield()
end


m.lock = function ()
end

m.lateral_move = function (dx)
  m.x = m.x + dx
  -- test pos
  if not m.does_pos_work() then
    m.x = m.x - dx
  end
  m.update_playfield()
end

m.drop = function ()
  m.y = m.y + 1
  -- test pos
  if not m.does_pos_work() then
    m.y = m.y - 1
  end
  m.update_playfield()
end

m.rotate = function (s_ori, e_ori)
  m.orientation = e_ori
  local is_rotation_90 = math.abs((e_ori % 4) - (s_ori % 4)) == 0

  if is_rotation_90 then -- test 90 kicks
    if m.type ~= m.ts.I then
      -- test position, then kicks_i
    elseif m.type ~= m.ts.O then
      -- test position, then kicks_jlstz
    end
  else -- test 180 kicks
    if m.type ~= m.ts.I then
      -- test position, then kicks_i
    elseif m.type ~= m.ts.O then
      -- test position, then kicks_jlstz
    end
  end

  m.update_playfield()
end

m.reset = function ()
  
end


return m