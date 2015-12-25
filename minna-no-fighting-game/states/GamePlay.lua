local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

function GamePlay:enter()
  --player1 = Player(50,'assets/sprites/animal.png')
  enemies = {}
  numberOfEnemies = 12
  for i=1,numberOfEnemies do
    enemies[i] = Enemy(30*i,'assets/sprites/animal.png')
  end
end

function GamePlay:draw()
  love.graphics.print("You're playing a game!\nPress x for hitstun, selected buttons for punch, and left & right to move!", 10, 10)
  for i=1,numberOfPlayers do
    players[i]:draw()
  end
  for i=1,numberOfEnemies do
    enemies[i]:draw()
  end
end

function GamePlay:update(dt)
  for i=1,numberOfPlayers do
    players[i]:update(dt)
  end
  for i=1,numberOfEnemies do
    enemies[i]:update(dt)
  end
end

function GamePlay:keyreleased(key, code)
  if key == 'return' then
    Gamestate.switch(MainMenu)
    players = {}
    enemies = {}
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
