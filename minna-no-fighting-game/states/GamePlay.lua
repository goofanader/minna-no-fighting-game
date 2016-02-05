local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"
require "classes/BossClasses/AndrewLee"

GamePlay = {}

local spawnTimer
local WINDOW_WIDTH = ORIG_WIDTH
local WINDOW_HEIGHT = ORIG_HEIGHT
--local players

function GamePlay:enter(prevState, playerList)
  players = playerList
  numberOfPlayers = #players
  enemies = {}
  numberOfEnemies = numberOfPlayers
  for i=1,numberOfPlayers do
    players[i]:spawn(vector(25 * i, Y_POS + i))
  end
  
  CurrentBoss = AndrewLee()
  
  --[[for i=1,numberOfEnemies do
    enemies[i] = Enemy(vector(WINDOW_WIDTH-30*i,Y_POS+love.math.random(12)),'assets/sprites/animal.png')
  end
  spawnTimer = 3]]

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
  love.graphics.print("You're playing a game! Press your button!", 10, 10)

  love.graphics.push()
  love.graphics.translate(translation.x, translation.y)
  love.graphics.scale(scale)
  --[[for i=1,numberOfEnemies do
    enemies[i]:draw()
    love.graphics.print(i,enemies[i].pos.x,Y_POS+SPRITE_SIZE)
  end]]
  for i=1,numberOfPlayers do
    players[i]:draw()
  end
  if CurrentBoss then
    CurrentBoss:draw()
  end
  
  love.graphics.pop()
end

function GamePlay:update(dt)
  --spawnTimer = spawnTimer - dt

  for i=1,numberOfPlayers do
    players[i]:update(dt)
  end
  if CurrentBoss then
    CurrentBoss:update(dt)
  end
  
  --[[for i=1,numberOfEnemies do
    if enemies[i].alive then
      enemies[i]:update(dt)
    else
      spawnTimer = spawnTimer - dt/numberOfEnemies
      if spawnTimer < 0 then
        spawnTimer = 3/numberOfPlayers
        if love.math.random() > 0.25 then
          if love.math.random() > 0.5 then
            enemies[i]:spawn(vector(WINDOW_WIDTH-SPRITE_SIZE,Y_POS+love.math.random(12)))
          else
            enemies[i]:spawn(vector(0,Y_POS))
          end
        end
      end
    end
  end]]

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
