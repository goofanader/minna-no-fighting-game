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

function ButtonSelect:isButton(otherButton, button, joystick)
  if joystick ~= nil then
    -- it's a joystick
    return otherButton.type == JOYSTICK and otherButton.joystick == joystick and otherButton.button == button
  else
    -- it's a keyboard
    return otherButton.type == KEYBOARD and otherButton.button == button
  end
end

function ButtonSelect:joystickpressed(joystick, button)
  pressFlag = false
  if selection > 1 then
    for i = 1,selection-1 do
      if self:isButton(buttons[i], button, joystick) then
        pressed[i] = true
        pressFlag = true
      end
    end
  end
  if not pressFlag then
    lastPressed = {type = JOYSTICK, button = button, joystick = joystick}
  end
end

function ButtonSelect:joystickreleased(joystick, button)
  pressFlag = false
  if selection > 1 then
    for i = 1,selection-1 do
      if self:isButton(buttons[i], button, joystick) then
        pressed[i] = false
        pressFlag = true
        break
      end
    end
  end
  if selection <= numberOfPlayers and self:isButton(lastPressed, button, joystick) and not pressFlag then
    buttons[selection] = {type = JOYSTICK, button = button, joystick = joystick}
    selection = selection + 1
  end
end

function ButtonSelect:keypressed(key, code)
  pressFlag = false
  if selection > 1 then
    for i = 1,selection-1 do
      if self:isButton(buttons[i], key) then
        pressed[i] = true
        pressFlag = true
      end
    end
  end
  if not pressFlag then
    lastPressed = {type = KEYBOARD, button = key}
  end
end

function ButtonSelect:keyreleased(key, code)
  if key == 'return' then
    if lastPressed.type == KEYBOARD and lastPressed.button == 'return' and selection > 1 then
      numberOfPlayers = selection-1
      for i=1, numberOfPlayers do
        --moved spawn to GamePlay.lua
        --hitbox creation deleted, part of spawn function instead
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
        if self:isButton(buttons[i], key) then
          pressed[i] = false
          pressFlag = true
          break
        end
      end
    end
    if selection <= numberOfPlayers and self:isButton(lastPressed, key) and not pressFlag then
      buttons[selection] = {type = KEYBOARD, button = key}
      selection = selection + 1
    end
  end
end
