local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

local spawnTimer

function GamePlay:enter()
  enemies = {}
  numberOfEnemies = 12
  for i=1,numberOfEnemies do
    enemies[i] = Enemy(vector(WINDOW_WIDTH-30*i,Y_POS+love.math.random(12)),'assets/sprites/animal.png')
  end
  spawnTimer = 3
  
  topHitbox = HC.rectangle(0,-32,WINDOW_WIDTH,32)
  topHitbox.class = 'wall'
  bottomHitbox = HC.rectangle(0,WINDOW_HEIGHT,WINDOW_WIDTH,32)
  bottomHitbox.class = 'wall'
  leftHitbox = HC.rectangle(-32,0,32,WINDOW_HEIGHT)
  leftHitbox.class = 'wall'
  rightHitbox = HC.rectangle(WINDOW_WIDTH,0,32,WINDOW_HEIGHT)
  rightHitbox.class = 'wall'
  
end

function GamePlay:draw()
  love.graphics.print("You're playing a game! Press each button!\nThe Hitstun animation represents charging.", 10, 10)
  
  for i=1,numberOfEnemies do
    enemies[i]:draw()
    love.graphics.print(i,enemies[i].pos.x,Y_POS+SPRITE_SIZE)
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
          enemies[i]:spawn(vector(WINDOW_WIDTH-SPRITE_SIZE,Y_POS+love.math.random(12)))
        else
          enemies[i]:spawn(vector(0,Y_POS))
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
