local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

function GamePlay:enter()
  --player1 = Player(50,'assets/sprites/animal.png')
  enemy1 = Enemy(50,'assets/sprites/animal.png')
end

function GamePlay:draw()
  love.graphics.print("You're playing a game!", 10, 10)
  for i=1,numberOfPlayers do
    players[i]:draw()
  end
  enemy1:draw()
end

function GamePlay:update(dt)
  for i=1,numberOfPlayers do
    players[i]:update(dt)
  end
  enemy1:update(dt)
end

function GamePlay:keyreleased(key, code)
  if key == 'return' then
    Gamestate.switch(MainMenu)
    players = {}
  else
    for i=1,numberOfPlayers do
      players[i]:keyreleased(key, isrepeat)
    end
  end
end

function GamePlay:keypressed(key, isrepeat)
  for i=1,numberOfPlayers do
      players[i]:keypressed(key, isrepeat)
  end
end
