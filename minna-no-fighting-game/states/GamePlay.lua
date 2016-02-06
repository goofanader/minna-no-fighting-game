local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"
require "states/GameOver"

GamePlay = {}

local spawnTimer
local WINDOW_WIDTH = ORIG_WIDTH
local WINDOW_HEIGHT = ORIG_HEIGHT
--local players

local backgrounds
local fightSFX, winSFX

function GamePlay:init(prevState, playerList)
  fightSFX = love.audio.newSource(SOUNDS_FOLDER .. "/announcer_fight.wav", "static")
  winSFX = love.audio.newSource(SOUNDS_FOLDER .. "/announcer_boss_defeated.wav", "static")
end

function GamePlay:enter(prevState, playerList)
  players = playerList
  numberOfPlayers = #players
  enemies = {}
  numberOfEnemies = numberOfPlayers
  for i=1,numberOfPlayers do
    players[i]:spawn(vector(25 * i, Y_POS + i))
  end

  playerHP = 400*numberOfPlayers
  playerMaxHP = playerHP

  Bosses = {
    Isaac(numberOfEnemies),
    Annaliese(numberOfEnemies),
    AndrewLee(numberOfEnemies),
    Phyllis(numberOfEnemies)
    }

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

  CurrentBoss.songAudio:rewind()
  CurrentBoss.songAudio:play()

  fightSFX:play()
end

function GamePlay:draw()
  --love.graphics.print("You're playing a game! Press your button!", 10, 10)

  love.graphics.push()
  love.graphics.translate(translation.x, translation.y)
  love.graphics.scale(scale)

  if CurrentBoss then
    CurrentBoss:drawStageBG()
  end

  for i=1,numberOfPlayers do
    players[i]:draw()
  end
  if CurrentBoss then
    CurrentBoss:draw()
    CurrentBoss:drawStageFG()
  end

  --Player HP Bar
  local EDGE_BUFFER = 15
  local BORDER = 5
  local width = ORIG_WIDTH-EDGE_BUFFER*2
  local height = EDGE_BUFFER*2
  local x = EDGE_BUFFER
  local y = ORIG_HEIGHT-EDGE_BUFFER-height
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle('fill', x, y, width, height)
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle('fill', x+BORDER, y+BORDER, (width-BORDER*2)*playerHP/playerMaxHP, height-BORDER*2)
  love.graphics.setColor(255,255,255)
  love.graphics.print('MINNA', x+EDGE_BUFFER, y+EDGE_BUFFER/2, 0, 1, 1)

  love.graphics.pop()
end

function GamePlay:update(dt)
  if CurrentBoss then
    CurrentBoss:update(dt)
  end
  if CurrentBoss:isDefeated() then
    CurrentBoss.songAudio:stop()
    winSFX:play()

    if BossNumber < #Bosses then
      BossNumber = BossNumber + 1
      CurrentBoss = Bosses[BossNumber]

      CurrentBoss.songAudio:rewind()
      CurrentBoss.songAudio:play()
    else
      Gamestate.switch(GameOver, true) --WIN SCREEN
      players = {}
      enemies = {}
    end
  elseif playerHP <= 0 then
    Gamestate.switch(GameOver, false) --LOSE SCREEN
    players = {}
    enemies = {}
  end

  for i=1,numberOfPlayers do
    if players and players[i] then
      players[i]:update(dt)
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
