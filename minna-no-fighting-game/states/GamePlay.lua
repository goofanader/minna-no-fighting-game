local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

function GamePlay:enter()
  player1 = Player(50,'assets/sprites/animal.png')
  enemy1 = Enemy(100,'assets/sprites/animal.png')
end

function GamePlay:draw()
  love.graphics.print("You're playing a game!", 10, 10)
  player1:draw()
  enemy1:draw()
end

function GamePlay:update(dt)
  player1:update(dt)
  enemy1:update(dt)
end

function GamePlay:keyreleased(key, code)
  if key == 'return' then
    Gamestate.switch(MainMenu)
  else
    player1:keyreleased(key, isrepeat)
  end
end

function GamePlay:keypressed(key, isrepeat)
  player1:keypressed(key, isrepeat)
end
