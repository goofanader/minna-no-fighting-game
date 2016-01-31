local Gamestate = require "libraries/hump.gamestate"
local utf8 = require("utf8")
local inspect = require("libraries/inspect")
local jsonLib = require("libraries/JSON")

require "states/ButtonSelect"
require "classes/Player"

local socketHttp = require "socket.http"
local socketUrl = require "socket.url"

CharacterSelect = {}

function CharacterSelect:getCharacter(searchTerm)
  --print(CHARACTERS_FOLDER)
  local ret = {
    ["ANIMAL"] = "/ANIMAL.png",
    ["NONE"] = "/NONE.png",
    ["FRONT"] = "/FRONT_32.png"
  }
  local retArr = {}

  if not love.filesystem.exists(CHARACTERS_FOLDER) then
    -- create the folder
    love.filesystem.createDirectory(CHARACTERS_FOLDER)
  end

  local charactersDir = love.filesystem.getDirectoryItems(CHARACTERS_FOLDER)

  if searchTerm ~= nil and searchTerm ~= "" then
    -- loop through each player ID's folder to make sure the character doesn't exist
    for i = 1, #charactersDir do
      local newDir = CHARACTERS_FOLDER .. "/" .. i .. "/" .. searchTerm

      if love.filesystem.exists(newDir) then
        -- return the character file names
        for key, value in pairs(ret) do
          ret[key] = newDir .. value
        end

        table.insert(retArr, ret)
      end
    end
  end

  if #retArr < 1 then
    -- didn't find it locally, so download from the internet
    local b, c, h = socketHttp.request(SEARCH_API_URL .. "?n=" .. searchTerm)

    if c == 200 and b ~= nil and b ~= "" then
      -- we're all good, we got some data~
      local webData = jsonLib:decode(b)
      print(inspect(webData))

      for index, value in ipairs(webData) do
        local charLocation = CHARACTERS_FOLDER .. string.gsub(string.gsub(value, IMAGES_URL, ""), "/FRONT_32.png", "")
        local newRet = {}

        for key, endFile in pairs(ret) do
          local imageURL = string.gsub(value, "/FRONT_32.png", endFile)

          -- download each image and put them into the save directory
          local image, status, err = socketHttp.request(imageURL)
          if status == 200 then
            -- make the folders
            if not love.filesystem.exists(charLocation) then
              love.filesystem.createDirectory(charLocation)
            end

            --print(charLocation..endFile)
            love.filesystem.write(charLocation .. endFile, image)
          else
            print("Could not save and download " .. charLocation..endFile.."!")
          end

          newRet[key] = charLocation .. endFile
        end

        table.insert(retArr, newRet)
      end
    end
  end

  return retArr
end

function CharacterSelect:enter()
  text = ""
  errText = ""
  foundData = {}
  --local foundData = self:getCharacter("p")
  --print(inspect(foundData))

  loadedImages = {}
  local charactersDir = love.filesystem.getDirectoryItems(CHARACTERS_FOLDER)

  for index, playerID in ipairs(charactersDir) do
    local playerDir = love.filesystem.getDirectoryItems(CHARACTERS_FOLDER.."/"..playerID)

    for playerIDIndex, charName in ipairs(playerDir) do
      local newImage = love.graphics.newImage(CHARACTERS_FOLDER.."/"..playerID.."/"..charName.."/FRONT_32.png")
      loadedImages[CHARACTERS_FOLDER.."/"..playerID.."/"..charName] = newImage
    end
  end
end

function CharacterSelect:draw()
  love.graphics.print("Enter your search:"..errText)
  love.graphics.print(text, 10, 10)

  local addX = 0
  local addY = 32
  local offset = 5

  for key, image in pairs(loadedImages) do
    love.graphics.draw(image, addX, addY)
    addX = addX + image:getWidth() + offset

    if addX >= love.window.getWidth() then
      addX = 0
      addY = addY + image:getHeight() + offset
    end
  end
end

function CharacterSelect:update(dt)
end

function CharacterSelect:textinput(t)
  text = text .. t
end

function CharacterSelect:keypressed(key)
  if key == "backspace" then
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(text, -1)

    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
        text = string.sub(text, 1, byteoffset - 1)
    end
  end

  if key == "return" then
    foundData = self:getCharacter(socketUrl.escape(trim(text)))
    --print(inspect(foundData))

    -- load any new images
    for index, characterData in ipairs(foundData) do
      local arrKey = string.gsub(characterData["FRONT"], "/FRONT_32.png", "")

      if loadedImages[arrKey] == nil then
        loadedImages[arrKey] = love.graphics.newImage(characterData["FRONT"])
      end
    end

    errText = " "..#foundData.." FOUND."
    text = ""
  end
end
