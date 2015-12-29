local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

local spawnTimer

function GamePlay:enter()
  enemies = {}
  numberOfEnemies = 5
  for i=1,numberOfEnemies do
    enemies[i] = Enemy(WINDOW_WIDTH-30*i,'assets/sprites/animal.png')
  end
  spawnTimer = 3
end

function GamePlay:draw()
  love.graphics.print("You're playing a game! Press each button!\nThe Hitstun animation represents charging.", 10, 10)
  
  for i=1,numberOfEnemies do
    enemies[i]:draw()
    love.graphics.print(i,enemies[i].pos,HORIZONTAL_PLANE+SPRITE_SIZE)
  end
  for i=1,numberOfPlayers do
    players[i]:draw()
  end
end

function GamePlay:update(dt)
  spawnTimer = spawnTimer - dt
  
  for i=1,numberOfPlayers do
    players[i]:update(dt)
  end
  for i=1,numberOfEnemies do
    if enemies[i].alive then
      enemies[i]:update(dt)
    elseif spawnTimer < 0 then
      spawnTimer = 3
      if love.math.random() > 0.1 then
        if love.math.random() > 0.5 then
          enemies[i]:spawn(WINDOW_WIDTH-SPRITE_SIZE)--(WINDOW_WIDTH)
        else
          enemies[i]:spawn(0)--(-SPRITE_SIZE)
        end
      end
    end
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
