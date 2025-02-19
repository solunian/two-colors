local math = require("math")
local constants = require("util.constants")

local input = require("util.input")
local misc = require("util.misc")

local board = require("tetra.board")
local minos = require("tetra.minos")
local display = require("tetra.display")

local tetra = {}

local is_gravity_on = true
local DEFAULT_GRAVITY_RATE = 0.75
local gravity_rate = DEFAULT_GRAVITY_RATE -- seconds until gravity drop, should not be 0 which is instant drop

local is_lock_on = true
local lock_delay = 0.5 -- seconds until lock when on the ground???

-- custom features
local ARR = 0.017 * .5 -- automatic repeat rate (seconds)
local DAS = 0.017 * 7 -- delayed auto shift (seconds)
local DCD = 0.017 * 0 -- DAS cut delay (seconds)
local SDF = 20 -- soft drop factor, increments the gravity_duration by sdf * 4 to trigger gravity faster

-- custom key controls
-- no input conflicts allowed!!! or else undefined behavior
local resetk = { "r" }
local pausek = { "p" }
local rightk = { "right" }
local leftk = { "left" }
local softdropk = { "down" }
local harddropk = { "space" }
local holdk = { "c" }
local cw_rotk = { "x", "up" }
local ccw_rotk = { "z" }
local deg180_rotk = { "a" }

-- tracking for time
local gravity_duration = 0

local arr_duration = 0
local das_duration = 0
local is_das_started = false
local dcd_duration = DCD -- defaults to no dcd
local is_dcd_done = true -- defaults to no dcd

local dt_factor = 1 -- for soft drop

local lock_duration = 0 -- for locking!!!
local touched_ground = false
local lock_move_count = 0

local LOCK_MOVE_LIMIT = 15 -- total number of rotations and movement until locks on ground after has touched ground

-- inputs
local INPUTS = { NIL = 0, R = 1, L = 2 }
local last_input = INPUTS.NIL


-- helper functions
local reset_durations = function ()
  gravity_duration = 0

  arr_duration = 0
  das_duration = 0
  last_input = INPUTS.NIL
  is_das_started = false

  dcd_duration = DCD
  is_dcd_done = true
end

local reset_locking = function ()
  lock_duration = 0
  touched_ground = false
  lock_move_count = 0
end

local start_dcd = function ()
  dcd_duration = 0
  is_dcd_done = false
end

local restart_tetra = function()
  reset_durations()
  reset_locking()

  board.reinit_playfield()
  minos.reinit()
  board.active = true

  -- can only spawn when board is active
  minos.spawn()
end


-- love functions --

tetra.load = function ()
  restart_tetra()
end

tetra.update = function (dt)
  if board.is_game_over() then
    board.active = false
    board.freeze_active()
  end

  minos.update_playfield() -- update mino position on board

  -- repeated movement
  if das_duration >= DAS and is_dcd_done then -- repeated movement only when dcd is done and das was triggered
    if input.anykeysdown(rightk) and last_input == INPUTS.R then
      arr_duration = arr_duration + dt
      if arr_duration >= ARR then

        local moves = minos.lateral_move(math.floor(arr_duration / (ARR + 1e-8))) -- in case of arr = 0
        if touched_ground then -- check moves for locking
          lock_move_count = lock_move_count + moves
        end
        if moves > 0 then lock_duration = 0 end -- reset duration on working move

        last_input = INPUTS.R
        arr_duration = arr_duration % (ARR + 1e-8)
      end
    elseif input.anykeysdown(leftk) and last_input == INPUTS.L then
      arr_duration = arr_duration + dt
      if arr_duration >= ARR then

        local moves = minos.lateral_move(-math.floor(arr_duration / (ARR + 1e-8))) -- in case of arr = 0
        if touched_ground then -- check moves for locking
          lock_move_count = lock_move_count + moves
        end
        if moves > 0 then lock_duration = 0 end -- reset duration on working move

        last_input = INPUTS.L
        arr_duration = arr_duration % (ARR + 1e-8)
      end
    end
  end

  -- reset variables on keyrelease, or no lateral movement condition
  -- reset variables if r is not down and r is last_input
  -- same with l
  if (not input.anykeysdown(leftk) and not input.anykeysdown(rightk) and last_input ~= INPUTS.NIL) or
  (input.anykeysdown(leftk) and not input.anykeysdown(rightk) and last_input == INPUTS.R) or
  (not input.anykeysdown(leftk) and input.anykeysdown(rightk) and last_input == INPUTS.L) then
    reset_durations()
  end

  -- start movement, non-repeat
  if is_dcd_done then
    if das_duration == 0 and not is_das_started then
      if input.anykeysdown(rightk) and last_input == INPUTS.NIL then
        last_input = INPUTS.R

        local moves = minos.lateral_move(1)
        if touched_ground then -- check moves for locking
          lock_move_count = lock_move_count + moves
        end
        if moves > 0 then lock_duration = 0 end -- reset duration on working move

        is_das_started = true
      elseif input.anykeysdown(leftk) and last_input == INPUTS.NIL then
        last_input = INPUTS.L

        local moves = minos.lateral_move(-1)
        if touched_ground then -- check moves for locking
          lock_move_count = lock_move_count + moves
        end
        if moves > 0 then lock_duration = 0 end -- reset duration on working move

        is_das_started = true
      end
    end
  end

  -- das counting up
  if is_das_started and das_duration < DAS then
    das_duration = das_duration + dt
  end
  -- das counting stop
  if is_das_started and das_duration >= DAS then
    is_das_started = false
  end

  -- dcd counting up
  if not is_dcd_done and dcd_duration < DCD then
    dcd_duration = dcd_duration + dt
    -- print("tick " .. dcd_duration) -- shows all the dcd ticks, waiting to reach DCD
  end
  -- dcd counting stop
  if not is_dcd_done and dcd_duration >= DCD then
    -- print("dcd done") -- when dcd_duration reaches DCD value
    is_dcd_done = true
  end

  -- soft drop
  dt_factor = 1
  if input.anykeysdown(softdropk) then
    dt_factor = SDF * 3 -- times 3 to approximate tetrio's sdf

    -- allow soft drop when gravity is off
    if not is_gravity_on then
      gravity_duration = gravity_duration + dt * dt_factor
      if gravity_duration >= DEFAULT_GRAVITY_RATE then
        minos.drop(math.floor(gravity_duration / DEFAULT_GRAVITY_RATE))
        gravity_duration = 0
      end
    end
  end

  -- gravity???
  if is_gravity_on then
    gravity_duration = gravity_duration + dt * dt_factor
    if gravity_duration >= gravity_rate then
      minos.drop(math.floor(gravity_duration / (gravity_rate + 1e-8))) -- in case of gravity rate of 0, sanity check to avoid crash
      gravity_duration = 0
    end
  end


  -- locking logic
  if is_lock_on then
    -- check lock, if piece is not moveable
    -- reset lock_duration if any lateral move or rotation
    if lock_duration >= lock_delay then
      reset_locking()
      minos.hard_drop()
    end
    if minos.is_on_ground() then
      lock_duration = lock_duration + dt

      -- if first time touching ground
      if not touched_ground then
        touched_ground = true
      end

      -- if touched ground and lock move count too high! lock!
      if touched_ground and lock_move_count >= LOCK_MOVE_LIMIT then
        reset_locking()
        minos.hard_drop()
      end
    end
  end

end

tetra.keypressed = function (key, scancode, isrepeat)

  -- game setting inputs

  -- global pause instead
  -- if input.anykeyequal(key, pausek) then -- pause / play game
  --   board.active = not board.active
  -- end

  if input.anykeyequal(key, resetk) then -- reset / start game
    restart_tetra()
  end

  -- movement / playing inputs!

  if input.anykeyequal(key, holdk) then
    minos.hold()
  end

  -- trigger dcd, only hard drop and rotations if on edge???
  -- rotations if holding left and is on the left side, delay after kick, same on right
  if input.anykeyequal(key, harddropk) or
  (input.anykeyequal(key, misc.merge_tables(cw_rotk, ccw_rotk)) and
  ((minos.x <= 1 and input.anykeysdown(leftk)) or (minos.x >= board.w - 4 and input.anykeysdown(rightk)))) then
    reset_durations()
    start_dcd()
  end

  if input.anykeyequal(key, harddropk) then -- hard drop / spawn new piece
    reset_locking()
    minos.hard_drop()
  end

  -- rotations
  if input.anykeyequal(key, cw_rotk) then -- clockwise
    local moves = minos.rotate(minos.orientation, (minos.orientation - 1 + 1) % 4 + 1) -- (ori -1 to 0-index, +1 for to right) % 4 for overflow, +1 for 1-index
    if touched_ground then -- check moves for locking
      lock_move_count = lock_move_count + moves
    end
    if moves > 0 then lock_duration = 0 end -- reset duration on working move
  elseif input.anykeyequal(key, ccw_rotk) then -- counter
    local moves = minos.rotate(minos.orientation, (minos.orientation - 1 + 3) % 4 + 1)
    if touched_ground then -- check moves for locking
      lock_move_count = lock_move_count + moves
    end
    if moves > 0 then lock_duration = 0 end -- reset duration on working move
  elseif input.anykeyequal(key, deg180_rotk) then -- 180
    local moves = minos.rotate(minos.orientation, (minos.orientation - 1 + 2) % 4 + 1)
    if touched_ground then -- check moves for locking
      lock_move_count = lock_move_count + moves
    end
    if moves > 0 then lock_duration = 0 end -- reset duration on working move
  end
end

tetra.draw = function ()
  -- top left corner of board
  local cenx, ceny = (constants.window_width - board.ss * (board.w)) / 2, (constants.window_height - board.ss * (board.h + board.sh)) / 2
  board.draw(cenx, ceny)
  display.draw(cenx, ceny)
end

return tetra