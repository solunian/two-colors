local math = require("math")
local os = require("os")
local table = require("table")

local board = require("tetra.board")

local m = {}

-- mino types
m.ty = { I = 1, J = 2, L = 3, O = 4, S = 5, T = 6, Z = 7 }
-- mino orientations
m.ori = { U = 1, R = 2, D = 3, L = 4 }

m.rot_ty = { EMPTY = 0, FILLED = 1 }

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
m.type = m.ty.I
m.orientation = m.ori.U


-- helper / local (private) functions

-- tests position after movement change to x,y! undo behavior if not working
-- playfield not updated before run!
local does_pos_work = function ()
  local rotation = m.rots[m.type][m.orientation]

  for row=1,4 do
    for col=1,4 do
      local spot = rotation[(row - 1) * 4 + col]
      if spot == m.rot_ty.FILLED then
        local uni_x = m.x + col
        local uni_y = m.y + row

        -- check playfield bounds
        if uni_x < 1 or uni_x > board.w or uni_y < 1 or uni_y > board.sh + board.h then
          return false
        end

        -- check filled pieces
        if board.pf[uni_y][uni_x] == board.ty.FILLED then
          return false
        end
      end
    end
  end

  return true
end

local update_playfield = function ()
  -- clear old active blocks
  for row=1,board.sh+board.h do
    for col=1,board.w do
      if board.pf[row][col] == board.ty.ACTIVE then
        board.pf[row][col] = board.ty.EMPTY
      end
    end
  end

  -- replace with "updated" active blocks
  for row=1,4 do
    for col=1,4 do
      if m.rots[m.type][m.orientation][(row - 1) * 4 + col] == 1 then
        board.pf[row + m.y][col + m.x] = board.ty.ACTIVE
      end
    end
  end
end

local bag = {}

local bag_append_random_seven = function (n) -- n = # of bags to be appended
  math.randomseed(os.time())

  local new_bag = {}
  for _=1,n do
    for ty=1,7 do
      table.insert(new_bag, ty)
    end
  end

  -- Fisher–Yates shuffle / Durstenfield shuffle? / Algorithm P?
  -- basically emplace randomize array
  -- for i=1,7*n-1 do
  --   local pick = math.random(i, 7 * n)
  --   new_bag[i], new_bag[pick] = new_bag[pick], new_bag[i] -- swap
  -- end

  -- insert all of new_bag into `bag`
  -- for i=1,7*n do
  --   table.insert(bag, new_bag[i])
  -- end

  -- shuffle and insertion at the same time
  for i=1,7*n-1 do
    local pick = math.random(i, 7 * n)
    table.insert(bag, new_bag[pick])
    new_bag[pick] = new_bag[i]
  end
end

local bag_pop = function ()
  if #bag < 7 then
    bag_append_random_seven(3)
  end
  return table.remove(bag, 1)
end

local peek_bag = function (n)
end


-- instance functions, uses instance variables (also board variables)

m.spawn = function ()
  local type = bag_pop()

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

  update_playfield()
end

-- direct board pf manipulation
m.lock = function ()
  for row=1,4 do
    for col=1,4 do
      if m.rots[m.type][m.orientation][(row - 1) * 4 + col] == 1 then
        board.pf[row + m.y][col + m.x] = board.ty.FILLED
      end
    end
  end

  board.active = false
end

m.lateral_move = function (dx)
  if not board.active then
    return
  end

  m.x = m.x + dx
  -- test pos
  if not does_pos_work() then
    m.x = m.x - dx
  end
  update_playfield()
end

m.drop = function ()
  if not board.active then
    return
  end

  m.y = m.y + 1
  -- test pos
  if not does_pos_work() then
    m.y = m.y - 1
  end
  update_playfield()
end

m.hard_drop = function ()
  repeat
    m.y = m.y + 1
    -- test pos
  until not does_pos_work()
  m.y = m.y - 1 -- push back one pos when pos fails

  update_playfield()

  m.lock()
end

m.rotate = function (s_ori, e_ori)
  if not board.active then
    return
  end

  m.orientation = e_ori
  if not does_pos_work() then
    m.orientation = s_ori
  end

  local is_rotation_90 = math.abs((e_ori % 4) - (s_ori % 4)) == 0

  if is_rotation_90 then -- test 90 kicks
    if m.type ~= m.ty.I then
      -- test position, then kicks_i
    elseif m.type ~= m.ty.O then
      -- test position, then kicks_jlstz
    end
  else -- test 180 kicks
    if m.type ~= m.ty.I then
      -- test position, then kicks_i
    elseif m.type ~= m.ty.O then
      -- test position, then kicks_jlstz
    end
  end

  update_playfield()
end

m.reinit = function ()
  bag_append_random_seven(1) -- single shuffled 7-bag appended by default
end

return m