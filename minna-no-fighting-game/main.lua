local Gamestate = require "libraries/hump.gamestate"
local Class = require "libraries/hump.class"

require "states/MainMenu"
require "constants"

function love.load()
  WINDOW_WIDTH = love.graphics.getWidth()
  WINDOW_HEIGHT = love.graphics.getHeight()

  love.graphics.setDefaultFilter("nearest", "nearest")

  Gamestate.registerEvents()
  Gamestate.switch(MainMenu)
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
