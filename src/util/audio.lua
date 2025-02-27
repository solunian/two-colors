local love = require("love")

local audio = {
  tetra_sounds = {
    single = nil,
    double = nil,
    triple = nil,
    quad = nil,
    theme = nil,
  }
}

function audio.load()
  -- these are fired off in board. when clear_rows is called
  audio.tetra_sounds.single = love.audio.newSource("assets/audio/single.wav", "static")
  audio.tetra_sounds.double = love.audio.newSource("assets/audio/double.wav", "static")
  audio.tetra_sounds.triple = love.audio.newSource("assets/audio/triple.wav", "static")
  audio.tetra_sounds.quad = love.audio.newSource("assets/audio/quad.wav", "static")

  -- fired off in 
  audio.tetra_sounds.theme = love.audio.newSource("assets/audio/tetris_theme_hard.mp3", "stream")
end

return audio