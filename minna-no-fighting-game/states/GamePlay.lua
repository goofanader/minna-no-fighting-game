local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

function GamePlay:enter()
  --player1 = Player(50,'assets/sprites/animal.png')
  enemies = {}
  numberOfEnemies = 5
  for i=1,numberOfEnemies do
    enemies[i] = Enemy(WINDOW_WIDTH-30*i,'assets/sprites/animal.png')
  end
end

function GamePlay:draw()
  love.graphics.print("You're playing a game! Press each button!\nThe Hitstun animation represents charging.", 10, 10)
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
  end
end

function GamePlay:keypressed(key, isrepeat)
end
