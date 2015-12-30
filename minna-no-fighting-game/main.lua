local Gamestate = require "libraries/hump.gamestate"
local Class = require "libraries/hump.class"

vector = require "libraries/hump.vector"
HC = require "libraries/HC" --collision detection

require "states/MainMenu"
require "constants"

function love.load()
  WINDOW_WIDTH = love.graphics.getWidth()
  WINDOW_HEIGHT = love.graphics.getHeight()

  love.graphics.setDefaultFilter("nearest", "nearest")

  Collider = HC(100, on_collide)

  Gamestate.registerEvents()
  Gamestate.switch(MainMenu)
end

function love.draw()
end

function love.update(dt)
  Collider:update(dt)
end

function love.keypressed(key, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end

function on_collide(dt, shape_a, shape_b)
  
end
