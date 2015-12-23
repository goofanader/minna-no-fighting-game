local Gamestate = require "libraries/hump.gamestate"

require "states/ButtonSelect"

MainMenu = {}

local main = {"Start Game","Options","Credits"}
local length = 3
local font_height = 15
local selection
local lastPressed

function MainMenu:enter()
  selection = 1
end

function MainMenu:draw()
  --Styupid Main Menu text
  local numbah = (love.math.random()-0.5)*10
  local numbar = (love.math.random()-0.5)*10
  love.graphics.print("MAIN MENUUUU!!!!!!!", WINDOW_WIDTH/2-120+numbah, WINDOW_HEIGHT/6+numbar, 0, 2, 2)
  
  --List of selections, with a simple square selector for now
  for i=1, length do
    love.graphics.print(main[i], WINDOW_WIDTH/2, WINDOW_HEIGHT/2+(i-length)*font_height)
    if i == selection then
      love.graphics.rectangle('fill', WINDOW_WIDTH/2-(font_height+5), WINDOW_HEIGHT/2+(i-length)*font_height, font_height, font_height)
    end
  end
end

function MainMenu:update(dt)
end

function MainMenu:keypressed(key, code)
  if key == 'return' then
    lastPressed = 'return'
  elseif key == 'up' and selection > 1 then
    selection = selection - 1
  elseif key == 'down' and selection < length then
    selection = selection + 1
  end
  lastPressed = key
end

function MainMenu:keyreleased(key, code)
  if key == 'return' and lastPressed == 'return' then
    if selection == 1 then
      Gamestate.switch(ButtonSelect)
    end
  end
end
