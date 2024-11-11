local math = require("math")
local os = require("os")
local table = require("table")

local board = require("tetra.board")

local m = {}

-- mino types
local ty = { I = 1, J = 2, L = 3, O = 4, S = 5, T = 6, Z = 7 }
-- mino orientations
local ori = { U = 1, R = 2, D = 3, L = 4 }

local rot_ty = { EMPTY = 0, FILLED = 1 }

-- all clockwise rotations. 4x4 with only I spanning 4 technically
local rots = {
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
local kicks_jlstz = {
  {{-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}}, -- 0>>1
  {{ 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}}, -- 1>>0
  {{ 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}}, -- 1>>2
  {{-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}}, -- 2>>1
  {{ 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}}, -- 2>>3
  {{-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}}, -- 3>>2
  {{-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}}, -- 3>>0
  {{ 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}}, -- 0>>3
}

local kicks_i = {
  {{-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}}, -- 0>>1
  {{ 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}}, -- 1>>0
  {{-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}}, -- 1>>2
  {{ 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}}, -- 2>>1
  {{ 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}}, -- 2>>3
  {{-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}}, -- 3>>2
  {{ 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}}, -- 3>>0
  {{-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}}, -- 0>>3
}

local kicks180_jlstz = {
  {{ 1, 0},{ 2, 0},{ 1, 1},{ 2, 1},{-1, 0},{-2, 0},{-1, 1},{-2, 1},{ 0,-1},{ 3, 0},{-3, 0}},  -- 0>>2─┐
  {{ 0, 1},{ 0, 2},{-1, 1},{-1, 2},{ 0,-1},{ 0,-2},{-1,-1},{-1,-2},{ 1, 0},{ 0, 3},{ 0,-3}},  -- 1>>3─┼┐
  {{-1, 0},{-2, 0},{-1,-1},{-2,-1},{ 1, 0},{ 2, 0},{ 1,-1},{ 2,-1},{ 0, 1},{-3, 0},{ 3, 0}},  -- 2>>0─┘│
  {{ 0, 1},{ 0, 2},{ 1, 1},{ 1, 2},{ 0,-1},{ 0,-2},{ 1,-1},{ 1,-2},{-1, 0},{ 0, 3},{ 0,-3}},  -- 3>>1──┘
}

local kicks180_i = {
  {{-1, 0},{-2, 0},{ 1, 0},{ 2, 0},{ 0, 1}},  -- 0>>2─┐
  {{ 0, 1},{ 0, 2},{ 0,-1},{ 0,-2},{-1, 0}},  -- 1>>3─┼┐
  {{ 1, 0},{ 2, 0},{-1, 0},{-2, 0},{ 0,-1}},  -- 2>>0─┘│
  {{ 0, 1},{ 0, 2},{ 0,-1},{ 0,-2},{ 1, 0}},  -- 3>>1──┘
};


-- instance variables for active piece
-- x,y position is of top left corner of 4x4, can be negative!
m.x = 0
m.y = 0
m.type = ty.I
m.orientation = ori.U


-- helper / local (private) functions

-- tests position after movement change to x,y! undo behavior if not working
-- playfield not updated before run!
local does_pos_work = function ()
  local rotation = rots[m.type][m.orientation]

  for row=1,4 do
    for col=1,4 do
      local spot = rotation[(row - 1) * 4 + col]
      if spot == rot_ty.FILLED then
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
      if rots[m.type][m.orientation][(row - 1) * 4 + col] == 1 then
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
    for tys=1,7 do
      table.insert(new_bag, tys)
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

local get_kick = function (type, s_ori, e_ori)
  if type ~= ty.I then
    if s_ori == ori.U and e_ori == ori.R then -- 0>>1
      return kicks_jlstz[1]
    elseif s_ori == ori.R and e_ori == ori.U then -- 1>>0
     return kicks_jlstz[2]
    elseif s_ori == ori.R and e_ori == ori.D then -- 1>>2
      return kicks_jlstz[3]
    elseif s_ori == ori.D and e_ori == ori.R then -- 2>>1
      return kicks_jlstz[4]
    elseif s_ori == ori.D and e_ori == ori.L then -- 2>>3
      return kicks_jlstz[5]
    elseif s_ori == ori.L and e_ori == ori.D then -- 3>>2
      return kicks_jlstz[6]
    elseif s_ori == ori.L and e_ori == ori.U then -- 3>>0
      return kicks_jlstz[7]
    elseif s_ori == ori.U and e_ori == ori.L then -- 0>>3
      return kicks_jlstz[8]
    end
  else
    if s_ori == ori.U and e_ori == ori.R then -- 0>>1
      return kicks_i[1]
    elseif s_ori == ori.R and e_ori == ori.U then -- 1>>0
     return kicks_i[2]
    elseif s_ori == ori.R and e_ori == ori.D then -- 1>>2
      return kicks_i[3]
    elseif s_ori == ori.D and e_ori == ori.R then -- 2>>1
      return kicks_i[4]
    elseif s_ori == ori.D and e_ori == ori.L then -- 2>>3
      return kicks_i[5]
    elseif s_ori == ori.L and e_ori == ori.D then -- 3>>2
      return kicks_i[6]
    elseif s_ori == ori.L and e_ori == ori.U then -- 3>>0
      return kicks_i[7]
    elseif s_ori == ori.U and e_ori == ori.L then -- 0>>3
      return kicks_i[8]
    end
  end
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
  m.orientation = ori.U

  update_playfield()
end

-- direct board pf manipulation
m.lock = function ()
  for row=1,4 do
    for col=1,4 do
      if rots[m.type][m.orientation][(row - 1) * 4 + col] == 1 then
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

  local old_x, old_y = m.x, m.y
  local is_rotation_90 = math.abs((e_ori % 4) - (s_ori % 4)) == 0

  m.orientation = e_ori

  if not does_pos_work() then -- test kicks!
    if is_rotation_90 then -- test 90 kicks
      local kick = get_kick(m.type, s_ori, e_ori)

      for k in kick do
        m.x, m.y = m.x + k[1], m.y + k[2]
        if not does_pos_work() then
          m.x, m.y = m.x - k[1], m.y - k[2]
        else
          break
        end
      end
      -- if m.type ~= m.ty.I then
      --   -- test position, then kicks_i
      -- elseif m.type ~= m.ty.O then
      --   -- test position, then kicks_jlstz
      -- end
    else -- test 180 kicks
      -- if m.type ~= m.ty.I then
      --   -- test position, then kicks_i
      -- elseif m.type ~= m.ty.O then
      --   -- test position, then kicks_jlstz
      -- end
    end
  end

  if not does_pos_work() then
    m.orientation = s_ori
    m.x, m.y = old_x, old_y
  end

  update_playfield()
end

m.reinit = function ()
  bag_append_random_seven(1) -- single shuffled 7-bag appended by default
end

return m