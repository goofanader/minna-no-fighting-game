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

local WINDOW_WIDTH = ORIG_WIDTH
local WINDOW_HEIGHT = ORIG_HEIGHT

function ButtonSelect:enter(prevState, playersInfo)
  selection = 1
  pressed = {}

  players = playersInfo
  numberOfPlayers = #playersInfo

  for i = 1, numberOfPlayers do
    players[i].pos = vector(ORIG_WIDTH/#players*(i-0.5)-SPRITE_SIZE/2 , ORIG_HEIGHT/2)
  end
end

function ButtonSelect:draw()
  
  if selection <= numberOfPlayers then
    love.graphics.printf( players[selection].name..", please press and release your button!", 10, 10, ORIG_WIDTH/2, 'center', 0, 6, 6)
  else
    love.graphics.printf("All Players Joined! Press ENTER to start game!", 10, 10, ORIG_WIDTH/2, 'center', 0, 6, 6)
  end

  love.graphics.push()
  love.graphics.translate(translation.x, translation.y)
  love.graphics.scale(scale)

  for i=1, numberOfPlayers do
    players[i]:draw()
  end
  love.graphics.pop()
end

function ButtonSelect:update(dt)
  for i=1, numberOfPlayers do
    players[i]:update(dt)
  end
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
        players[i]:selected(true)
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
        players[i]:selected(false)
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
        players[i]:selected(true)
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
          players[i]:selected(false)
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
