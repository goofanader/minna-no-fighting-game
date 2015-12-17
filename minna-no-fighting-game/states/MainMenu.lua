local Gamestate = require "libraries/hump.gamestate"

require "states/GamePlay"

MainMenu = {}

function MainMenu:draw()
  love.graphics.print("Press Enter to continue", 10, 10)
end

function MainMenu:update(dt)
  
end

function MainMenu:keyreleased(key, code)
  if key == 'return' then
    Gamestate.switch(GamePlay)
  end
end