local math = require("math")
local os = require("os")
local table = require("table")

local board = require("tetra.board")

local m = {}

-- mino types
local ty = { I = 1, J = 2, L = 3, O = 4, S = 5, T = 6, Z = 7 }
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

-- IMPORTANT: Y OFFSET IS NEGATIVE, MEANING UPWARDS! THESE ARE TAKEN FROM TETRIS WIKI FOR SRS!!!
-- test basic rotations, then 4 kicks (x,-y offsets)
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
m.orientation = m.ori.U
m.hold_type = 0
local holdable = true

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

local generate_shadow = function ()
  local sy = m.y

  -- does_pos_work for shadow
  local rotation = m.rots[m.type][m.orientation]

  local pos_works = true
  while pos_works do
    sy = sy + 1
    -- check if pos works
    for row=1,4 do
      for col=1,4 do
        local spot = rotation[(row - 1) * 4 + col]
        if spot == m.rot_ty.FILLED then
          local uni_x = m.x + col
          local uni_y = sy + row

          -- check playfield bounds
          if uni_x < 1 or uni_x > board.w or uni_y < 1 or uni_y > board.sh + board.h then
            pos_works = false
            break
          end

          -- check filled pieces
          if board.pf[uni_y][uni_x] == board.ty.FILLED then
            pos_works = false
          end
        end
      end
    end
  end

  -- push back after initial fail
  sy = sy - 1

  -- clear all old shadow pieces on playfield
  for row=1,board.sh+board.h do
    for col=1,board.w do
      if board.pf[row][col] == board.ty.SHADOW then
        board.pf[row][col] = board.ty.EMPTY
      end
    end
  end

  -- draw shadow pieces onto playfield
  for row=1,4 do
    for col=1,4 do
      if m.rots[m.type][m.orientation][(row - 1) * 4 + col] == m.rot_ty.FILLED then
        board.pf[row + sy][col + m.x] = board.ty.SHADOW
      end
    end
  end
end

-- called in all movement and in every update of main game loop
m.update_playfield = function ()
  if not board.active then
    return
  end
  
  -- clear old active blocks and shadow
  for row=1,board.sh+board.h do
    for col=1,board.w do
      if board.pf[row][col] == board.ty.ACTIVE then
        board.pf[row][col] = board.ty.EMPTY
      end
    end
  end

  -- draw on shadow before updated active blocks
  generate_shadow()

  -- replace with "updated" active blocks
  for row=1,4 do
    for col=1,4 do
      if m.rots[m.type][m.orientation][(row - 1) * 4 + col] == m.rot_ty.FILLED then
        board.pf[row + m.y][col + m.x] = board.ty.ACTIVE
      end
    end
  end
end

local bag = {}

local bag_append_random_seven = function (n) -- n = # of bags to be appended
  math.randomseed(os.time() * math.random())

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
  for i=1,7*n do
    local pick = math.random(i, 7 * n)
    table.insert(bag, new_bag[pick])
    new_bag[pick] = new_bag[i]
  end
end

local bag_pop = function ()
  if #bag < 7 then
    bag_append_random_seven(1)
  end
  return table.remove(bag, 1)
end

local get_kick = function (type, s_ori, e_ori)
  local is_rotation_90 = math.abs((e_ori - 1) - (s_ori - 1)) == 1 or math.abs((e_ori - 1) -  (s_ori - 1)) == 3
  if is_rotation_90 then
    if type ~= ty.I then
      if s_ori == m.ori.U and e_ori == m.ori.R then -- 0>>1
        return kicks_jlstz[1]
      elseif s_ori == m.ori.R and e_ori == m.ori.U then -- 1>>0
      return kicks_jlstz[2]
      elseif s_ori == m.ori.R and e_ori == m.ori.D then -- 1>>2
        return kicks_jlstz[3]
      elseif s_ori == m.ori.D and e_ori == m.ori.R then -- 2>>1
        return kicks_jlstz[4]
      elseif s_ori == m.ori.D and e_ori == m.ori.L then -- 2>>3
        return kicks_jlstz[5]
      elseif s_ori == m.ori.L and e_ori == m.ori.D then -- 3>>2
        return kicks_jlstz[6]
      elseif s_ori == m.ori.L and e_ori == m.ori.U then -- 3>>0
        return kicks_jlstz[7]
      elseif s_ori == m.ori.U and e_ori == m.ori.L then -- 0>>3
        return kicks_jlstz[8]
      end
    else
      if s_ori == m.ori.U and e_ori == m.ori.R then -- 0>>1
        return kicks_i[1]
      elseif s_ori == m.ori.R and e_ori == m.ori.U then -- 1>>0
        return kicks_i[2]
      elseif s_ori == m.ori.R and e_ori == m.ori.D then -- 1>>2
        return kicks_i[3]
      elseif s_ori == m.ori.D and e_ori == m.ori.R then -- 2>>1
        return kicks_i[4]
      elseif s_ori == m.ori.D and e_ori == m.ori.L then -- 2>>3
        return kicks_i[5]
      elseif s_ori == m.ori.L and e_ori == m.ori.D then -- 3>>2
        return kicks_i[6]
      elseif s_ori == m.ori.L and e_ori == m.ori.U then -- 3>>0
        return kicks_i[7]
      elseif s_ori == m.ori.U and e_ori == m.ori.L then -- 0>>3
        return kicks_i[8]
      end
    end
  else
    if type ~= ty.I then
      if s_ori == m.ori.U and e_ori == m.ori.D then -- 0>>2
        return kicks180_jlstz[1]
      elseif s_ori == m.ori.R and e_ori == m.ori.L then -- 1>>3
      return kicks180_jlstz[2]
      elseif s_ori == m.ori.D and e_ori == m.ori.U then -- 2>>0
        return kicks180_jlstz[3]
      elseif s_ori == m.ori.L and e_ori == m.ori.R then -- 3>>1
        return kicks180_jlstz[4]
      end
    else
      if s_ori == m.ori.U and e_ori == m.ori.D then -- 0>>2
        return kicks180_i[1]
      elseif s_ori == m.ori.R and e_ori == m.ori.L then -- 1>>3
      return kicks180_i[2]
      elseif s_ori == m.ori.D and e_ori == m.ori.U then -- 2>>0
        return kicks180_i[3]
      elseif s_ori == m.ori.L and e_ori == m.ori.R then -- 3>>1
        return kicks180_i[4]
      end
    end
  end
end

-- direct board pf manipulation
local lock = function ()
  for row=1,4 do
    for col=1,4 do
      if m.rots[m.type][m.orientation][(row - 1) * 4 + col] == m.rot_ty.FILLED then
        board.pf[row + m.y][col + m.x] = board.ty.FILLED
      end
    end
  end
end


-- instance functions, uses instance variables (also board variables)

m.is_on_ground = function ()
  m.y = m.y + 1
  if does_pos_work() then
    m.y = m.y - 1
    return false
  end
  m.y = m.y - 1
  return true
end

m.peek_bag = function (n)
  local peek = {}
  if #bag >= n then
    for i=1,n do
      table.insert(peek, bag[i])
    end
  end
  return peek
end

m.hold = function()
  if not board.active then
    return
  end

  if holdable then
    if m.hold_type == 0 then
      m.hold_type = m.type
      m.spawn()
    else
      m.type, m.hold_type = m.hold_type, m.type

      local center_x = 0
      if board.w % 2 ~= 0 then
        center_x = math.floor(board.w / 2) - 1 -- odd offset -1 from middle
      else
        center_x = math.floor(board.w / 2) - 2 -- even offset -2 from the middle
      end

      m.x = center_x
      m.y = 0
      m.orientation = m.ori.U
    end
    holdable = false
  end

  m.update_playfield()
end

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

  m.update_playfield()
end

----------------------------------------------------------------
--- lateral_move and rotate returns the number of moves made ---
----------------------------------------------------------------

m.lateral_move = function (dx)
  if not board.active then
    return 0
  end

  local move_count = 0

  -- |dx| greater than 1 should push to the very farthest until it is obstructed
  if math.abs(dx) > 0 then
    while math.abs(dx) ~= 0 do
      local dx_dir = dx / math.abs(dx) -- +-1 matches the sign of dx
      m.x = m.x + dx_dir
      dx = dx - dx_dir

      -- increment!
      move_count = move_count + 1

      -- test pos
      if not does_pos_work() then
        m.x = m.x - dx_dir
        move_count = move_count - 1
        break
      end
    end
  end

  m.update_playfield()
  return move_count
end

m.rotate = function (s_ori, e_ori)
  if m.type == ty.O then -- for locking!
    return 1
  end

  if not board.active then
    return 0
  end

  local old_x, old_y = m.x, m.y

  m.orientation = e_ori

  if not does_pos_work() then -- test kicks!
    local kick = get_kick(m.type, s_ori, e_ori)

    for i=1,#kick do
      -- print("test", kick[i][1], kick[i][2]) -- debug kicks stuff
      m.x, m.y = m.x + kick[i][1], m.y - kick[i][2] -- NEGATIVE OFFSET FOR Y
      if not does_pos_work() then
        m.x, m.y = m.x - kick[i][1], m.y + kick[i][2] -- POSITIVE PUTBACK OFFSET FOR Y
      else
        break
      end
    end
  end

  if not does_pos_work() then
    m.orientation = s_ori
    m.x, m.y = old_x, old_y

    m.update_playfield()
    return 0
  end

  m.update_playfield()
  return 1
end

-- dy must be greater than 0
m.drop = function (dy)
  if not board.active then
    return
  end

  while dy > 0 do
    m.y = m.y + 1
    -- test pos
    if not does_pos_work() then
      m.y = m.y - 1
      break
    end

    dy = dy - 1
  end

  m.update_playfield()
end

m.hard_drop = function ()
  repeat
    m.y = m.y + 1
    -- test pos
  until not does_pos_work()
  m.y = m.y - 1 -- push back one pos when pos fails

  m.update_playfield()

  lock()

  board.clear_rows()

  -- hard drop makes hold work again
  holdable = true

  if not board.game_over() then
    m.spawn()
  end
end

m.reinit = function ()
  m.hold_type = 0
  holdable = true
  bag = {}
  bag_append_random_seven(1) -- single shuffled 7-bag appended by default
end

return m