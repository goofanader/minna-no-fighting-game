local Gamestate = require "libraries/hump.gamestate"

--require "states/MainMenu"

GameOver = {}

local message

function GameOver:init(prevState)
  message = 'this is a default message'
end

function GameOver:enter(prevState, victory)
  if victory then
    message = 'You have trimphed over the despicable enemy! Congratulations!'
  else
    message = 'GAME OVER'
  end
end

function GameOver:draw()
  love.graphics.printf(message, 10, 10, ORIG_WIDTH/2, 'center')
end

function GameOver:update(dt)
  
end

function GameOver:keyreleased(key, code)
  if key == 'return' then
    Gamestate.switch(MainMenu)
    players = {}
    enemies = {}
  end
end

function GameOver:keypressed(key, isrepeat)
end
