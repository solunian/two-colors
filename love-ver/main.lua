local love = require("love")
local math = require("math")

local board = require("tetra.board")
local minos = require("tetra.minos")


local ARR = 0.017 * 1 -- automatic repeat rate (seconds)
local DAS = 0.017 * 8 -- delayed auto shift (seconds)
local DCD = 0.017 * 7 -- DAS cut delay (seconds)
local SDF = 0 -- soft drop factor

local arr_duration = 0
local das_duration = 0
local is_das_started = false
local dcd_duration = DCD -- defaults to no dcd
local is_dcd_done = true -- defaults to no dcd

local INPUTS = { NIL = 0, R = 1, L = 2 }
local last_input = INPUTS.NIL

local reset_arr_das_dcd_durations = function ()
  arr_duration = 0
  das_duration = 0
  last_input = INPUTS.NIL
  is_das_started = false

  dcd_duration = DCD
  is_dcd_done = true
end

local start_dcd = function ()
  dcd_duration = 0
  is_dcd_done = false
end

local restart_tetra = function()
  reset_arr_das_dcd_durations()

  board.reinit_playfield()
  minos.reinit()
  minos.spawn()
  board.active = true
end


-- love functions --

function love.load()
  love.window.setTitle("two colors")

  restart_tetra()
end

function love.update(dt)
  board.clear_rows()
  minos.update_playfield()

  -- repeated movement
  if das_duration >= DAS and is_dcd_done then -- repeated movement only when dcd is done and das was triggered
    if love.keyboard.isDown("right") and last_input == INPUTS.R then
      arr_duration = arr_duration + dt

      if arr_duration >= ARR then
        minos.lateral_move(math.floor(arr_duration / (ARR + 1e-8))) -- in case of arr = 0
        last_input = INPUTS.R
        arr_duration = arr_duration - ARR
      end
    elseif love.keyboard.isDown("left") and last_input == INPUTS.L then
      arr_duration = arr_duration + dt

      if arr_duration >= ARR then
        minos.lateral_move(-math.floor(arr_duration / (ARR + 1e-8)))  -- in case of arr = 0
        last_input = INPUTS.L
        arr_duration = arr_duration - ARR
      end
    end
  end

  -- reset variables on keyrelease, or no lateral movement condition
  -- reset variables if r is not down and r is last_input
  -- same with l
  if (not love.keyboard.isDown("right") and not love.keyboard.isDown("left") and last_input ~= INPUTS.NIL) or
  (love.keyboard.isDown("left") and not love.keyboard.isDown("right") and last_input == INPUTS.R) or
  (not love.keyboard.isDown("left") and love.keyboard.isDown("right") and last_input == INPUTS.L) then
    reset_arr_das_dcd_durations()
  end

  -- start movement, non-repeat
  if is_dcd_done then
    if das_duration == 0 and not is_das_started then
      if love.keyboard.isDown("right") and last_input == INPUTS.NIL then
        last_input = INPUTS.R
        minos.lateral_move(1)
        is_das_started = true
      elseif love.keyboard.isDown("left") and last_input == INPUTS.NIL then
        last_input = INPUTS.L
        minos.lateral_move(-1)
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
  if love.keyboard.isDown("down") then
    minos.drop()
  end

  -- gravity???
  -- delta_time = delta_time + dt
  -- if delta_time >= gravity_time then
  --   minos.drop()
  --   delta_time = 0
  -- end
end

function love.keypressed(key, scancode, isrepeat)

  -- game inputs

  if key == "r" then -- reset / start game
    restart_tetra()
  end

  if key == "p" then -- pause / play game
    board.active = not board.active
  end

  -- movement inputs!

  -- trigger dcd, only hard drop and rotations??
  if key == "space" or key == "z" or key == "x" or key == "up" or key == "a" then
    start_dcd()
  end

  if key == "space" then -- hard drop / spawn new piece
    minos.hard_drop()
    minos.spawn()
  end

  -- rotations
  if key == "x" or key == "up" then -- clockwise
    minos.rotate(minos.orientation, (minos.orientation - 1 + 1) % 4 + 1) -- (ori -1 to 0-index, +1 for to right) % 4 for overflow, +1 for 1-index
  elseif key == "z" then -- counter
    minos.rotate(minos.orientation, (minos.orientation - 1 + 3) % 4 + 1)
  elseif key == "a" then -- 180
    minos.rotate(minos.orientation, (minos.orientation - 1 + 2) % 4 + 1)
  end
end

function love.draw()
  board.draw()
end