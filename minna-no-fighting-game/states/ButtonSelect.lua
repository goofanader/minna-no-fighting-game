local Gamestate = require "libraries/hump.gamestate"

require "states/GamePlay"
require "classes/Player"

ButtonSelect = {}

local players = {}
numberOfPlayers = 0
local selection
local buttons = {}
local pressed = {}
local pressFlag

function ButtonSelect:enter(prevState, playersInfo)
  selection = 1
  pressed = {}

  players = playersInfo
  numberOfPlayers = #playersInfo
end

function ButtonSelect:draw()
  if selection <= numberOfPlayers then
    love.graphics.print("Player "..selection..", please press and release your button!",10,10)
  else
    love.graphics.print("All Players Joined! Press ENTER to start game!",10,10)
  end

  for i=1, numberOfPlayers do
    if pressed[i] then
      love.graphics.setColor(0,255,0,255)
    elseif selection > i then
      love.graphics.setColor(0,0,255,255)
    end

    love.graphics.rectangle('fill', WINDOW_WIDTH/numberOfPlayers*(i-0.5) , WINDOW_HEIGHT/2 , 10 , 10)
    love.graphics.setColor(255,255,255,255)
  end
end

function ButtonSelect:update(dt)
end

function ButtonSelect:keypressed(key, code)
  pressFlag = false
  if selection > 1 then
    for i = 1,selection-1 do
      if key == buttons[i] then
        pressed[i] = true
        pressFlag = true
      end
    end
  end
  if not pressFlag then
    lastPressed = key
  end
end

function ButtonSelect:keyreleased(key, code)
  if key == 'return' then
    if lastPressed == 'return' and selection > 1 then
      numberOfPlayers = selection-1
      for i=1, numberOfPlayers do
        players[i].pos = vector(25 * i, Y_POS + i)-- = Player(vector(25*i,Y_POS+i),'assets/sprites/animal.png',buttons[i], "Player "..i, i)
        players[i].hitbox = HC.rectangle(players[i].pos.x, players[i].pos.y, SPRITE_SIZE, SPRITE_SIZE)
        players[i].button = buttons[i]
      end
      numberOfPlayers = selection-1
      Gamestate.switch(GamePlay, players)
    end
  elseif key == 'backspace' then
    pressed[selection-1] = false
    if selection > 1 then
      selection = selection - 1
    else
      Gamestate.switch(MainMenu)
    end
  else
    pressFlag = false
    if selection > 1 then
      for i = 1,selection-1 do
        if key == buttons[i] then
          pressed[i] = false
          pressFlag = true
          break
        end
      end
    end
    if selection <= numberOfPlayers and key == lastPressed and not pressFlag then
      buttons[selection] = key
      selection = selection + 1
    end
  end
end
