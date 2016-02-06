local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

local spawnTimer
local WINDOW_WIDTH = ORIG_WIDTH
local WINDOW_HEIGHT = ORIG_HEIGHT
--local players

local backgrounds

function GamePlay:init(prevState, playerList)
  local backgroundsFolder = BACKGROUNDS_FOLDER .. "/Subway/"
  backgrounds = {}

  backgrounds["bg"] = love.graphics.newImage(backgroundsFolder .. "/bg.png")
  backgrounds["fg"] = {}
  backgrounds["fg"]["benches"] = love.graphics.newImage(backgroundsFolder.."/fg_benches.png")
  backgrounds["fg"]["trees"] = {}
  backgrounds["fg"]["trees"]["left"] = love.graphics.newImage(backgroundsFolder.."/fg_tree_left.png")
  backgrounds["fg"]["trees"]["right"] = love.graphics.newImage(backgroundsFolder.."/fg_tree_right.png")
end

function GamePlay:enter(prevState, playerList)
  players = playerList
  numberOfPlayers = #players
  enemies = {}
  numberOfEnemies = numberOfPlayers
  for i=1,numberOfPlayers do
    players[i]:spawn(vector(25 * i, Y_POS + i))
  end

  Bosses = {Phyllis(numberOfEnemies),AndrewLee(numberOfEnemies)}
  BossNumber = 1
  CurrentBoss = Bosses[BossNumber]

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
  --love.graphics.print("You're playing a game! Press your button!", 10, 10)

  love.graphics.push()
  love.graphics.translate(translation.x, translation.y)
  love.graphics.scale(scale)

  love.graphics.draw(backgrounds["bg"])

  for i=1,numberOfPlayers do
    players[i]:draw()
  end
  if CurrentBoss then
    CurrentBoss:draw()
  end

  love.graphics.draw(backgrounds["fg"]["benches"])
  love.graphics.draw(backgrounds["fg"]["trees"]["left"])
  love.graphics.draw(backgrounds["fg"]["trees"]["right"])

  love.graphics.pop()
end

function GamePlay:update(dt)
  for i=1,numberOfPlayers do
    players[i]:update(dt)
  end
  if CurrentBoss then
    CurrentBoss:update(dt)
  end
  if CurrentBoss:isDefeated() then
    if BossNumber < #Bosses then
      BossNumber = BossNumber + 1
      CurrentBoss = Bosses[BossNumber]
    else
      --TODO: Win Screen!
      Gamestate.switch(MainMenu)
      players = {}
      enemies = {}
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
