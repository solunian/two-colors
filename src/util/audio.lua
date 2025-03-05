local love = require("love")

local audio = {
  game_sounds = {
    theme = nil,
  },
  tetra_sounds = {
    single = nil,
    double = nil,
    triple = nil,
    quad = nil,
    theme = nil,
  },
  tanks_sounds = {
    theme = nil,
    fire = nil,
    playerdie = nil,
    enemydie = nil
  }
}

function audio.load()
  -- overall game
  audio.game_sounds.theme = love.audio.newSource("assets/audio/two_colors_theme.mp3", "stream")

  -- these are fired off in board. when clear_rows is called
  audio.tetra_sounds.single = love.audio.newSource("assets/audio/single.wav", "static")
  audio.tetra_sounds.double = love.audio.newSource("assets/audio/double.wav", "static")
  audio.tetra_sounds.triple = love.audio.newSource("assets/audio/triple.wav", "static")
  audio.tetra_sounds.quad = love.audio.newSource("assets/audio/quad.wav", "static")

  -- fired off in main.lua
  audio.tetra_sounds.theme = love.audio.newSource("assets/audio/tetra_theme_hard.mp3", "stream")

  -- tanks
  audio.tanks_sounds.theme = love.audio.newSource("assets/audio/tanks_theme.mp3", "stream")
  audio.tanks_sounds.fire = love.audio.newSource("assets/audio/tankfire.wav", "static")
  audio.tanks_sounds.playerdie = love.audio.newSource("assets/audio/playerdie.wav", "static")
  audio.tanks_sounds.enemydie = love.audio.newSource("assets/audio/enemydie.wav", "static")

end

return audio