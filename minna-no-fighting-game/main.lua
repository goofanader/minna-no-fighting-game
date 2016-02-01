local Gamestate = require "libraries/hump.gamestate"
local Class = require "libraries/hump.class"

vector = require "libraries/hump.vector"
HC = require "libraries/HC" --collision detection
loveframes = require("libraries.LoveFrames")

require "constants"
require "states/MainMenu"
require "states/CharacterSelect"

function love.load()
  WINDOW_WIDTH = love.graphics.getWidth()
  WINDOW_HEIGHT = love.graphics.getHeight()
  scale = 1
  translation = vector(0, 0)
  isFullscreen = true

  love.graphics.setDefaultFilter("nearest", "nearest")

  Gamestate.registerEvents()
  Gamestate.switch(MainMenu)
  --Gamestate.switch(CharacterSelect)
end

function love.draw()
end

function love.update(dt)
end

function love.keypressed(key, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end

function love.resize(w, h)
  -- determine whether we scale on the height or width of the image
  local scaledHeight = ORIG_HEIGHT * w / (ORIG_WIDTH * 1.0)
  local scaledWidth = ORIG_WIDTH * h / (ORIG_HEIGHT * 1.0)

  if scaledWidth <= w then -- scale on height
    scale = scaledWidth / (ORIG_WIDTH * 1.0)
  else
    scale = scaledHeight / (ORIG_HEIGHT * 1.0)
  end

  --scale = scale - math.fmod(scale, 2)

  -- get the translation to center the game
  translation.x = (w - (scale * ORIG_WIDTH)) - ((w - scale * ORIG_WIDTH) / 2)
  translation.y = (h - (scale * ORIG_HEIGHT)) - ((h - scale * ORIG_HEIGHT) / 2)

  WINDOW_WIDTH = w
  WINDOW_HEIGHT = h
end
