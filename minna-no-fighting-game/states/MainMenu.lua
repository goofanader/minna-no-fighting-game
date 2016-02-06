local Gamestate = require "libraries/hump.gamestate"

require "states/ButtonSelect"
require "states/CharacterSelect"

MainMenu = {}

local main = {"Start Game","Options","Credits"}
local length = 3
local font_height = 15
local selection
local lastPressed
local images
local imageLocation = BACKGROUNDS_FOLDER .. "/MainMenu"
local song

function MainMenu:init()
  -- load up all the images for the main menu
  local chars = {"alucard", "sailor", "shonen", "wolf"}

  images = {
    [1] = love.graphics.newImage(imageLocation.."/bg.png"),
    [2] = {},
    [3] = love.graphics.newImage(imageLocation.."/logo.png")
  }

  for index, name in ipairs(chars) do
    table.insert(images[2], {love.graphics.newImage(imageLocation.."/shadows_"..name..".png"), love.graphics.newImage(imageLocation.."/character_"..name..".png")})
  end

  song = love.audio.newSource(MUSIC_FOLDER .. "/mainmenu.mp3")
  song:setVolume(0.55)
  song:setLooping(true)

  titleCall = love.audio.newSource(SOUNDS_FOLDER .. "/announcer_title_0.wav", 'static')
end

function MainMenu:enter()
  selection = 1
  song:rewind()
  song:play()

  titleCall:play()
end

function MainMenu:draw()
  --[[--Styupid Main Menu text
  local numbah = (love.math.random()-0.5)*10
  local numbar = (love.math.random()-0.5)*10
  love.graphics.print("MAIN MENUUUU!!!!!!!", WINDOW_WIDTH/2-120+numbah, WINDOW_HEIGHT/6+numbar, 0, 2, 2)

  --List of selections, with a simple square selector for now
  for i=1, length do
    love.graphics.print(main[i], WINDOW_WIDTH/2, WINDOW_HEIGHT/2+(i-length)*font_height)
    if i == selection then
      love.graphics.rectangle('fill', WINDOW_WIDTH/2-(font_height+5), WINDOW_HEIGHT/2+(i-length)*font_height, font_height, font_height)
    end
  end]]

  love.graphics.push()
  love.graphics.translate(translation.x, translation.y)
  love.graphics.scale(scale)

  for index = 1, #images do
    local image = images[index]

    if index == 2 then
      for charIndex, charImageData in ipairs(image) do
        love.graphics.draw(charImageData[1])
        love.graphics.draw(charImageData[2])
      end
    else
      love.graphics.draw(image)
    end
  end

  love.graphics.pop()
end

function MainMenu:update(dt)
end

function MainMenu:keypressed(key, isrepeat)
  --[[if key == 'return' then
    lastPressed = 'return'
  elseif key == 'up' and selection > 1 then
    selection = selection - 1
  elseif key == 'down' and selection < length then
    selection = selection + 1
  end
  lastPressed = key]]
  if key == "f" then
    isFullscreen = not isFullscreen
    love.window.setFullscreen(isFullscreen)
  end
end

function MainMenu:keyreleased(key)
  --[[if key == 'return' and lastPressed == 'return' then
    if selection == 1 then
      --Gamestate.switch(ButtonSelect)
      Gamestate.switch(CharacterSelect)
    end
  end]]
end

function MainMenu:mousepressed(x, y, button)
  song:stop()
  Gamestate.switch(CharacterSelect)
end
