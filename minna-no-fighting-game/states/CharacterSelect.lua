local Gamestate = require "libraries/hump.gamestate"
local utf8 = require("utf8")
local inspect = require("libraries/inspect")
local jsonLib = require("libraries/JSON")

require "states/ButtonSelect"
require "classes/Player"

local socketHttp = require "socket.http"
local socketUrl = require "socket.url"

local text
local errText
local foundData
local loadedImages
local goButton
local foundList
local view
local players
local numPlayers
local selectedPlayer
local song

CharacterSelect = {}

function CharacterSelect:getCharacter(searchTerm)
  --print(CHARACTERS_FOLDER)
  local ret = {
    ["ANIMAL"] = "/ANIMAL.png",
    ["REGULAR"] = "/REGULAR.png",
    ["FRONT"] = "/FRONT_32.png"
  }
  local retArr = {}

  -- TODO: rather than checking if the file exists, check if it's in loadedImages yet
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

  if true or #retArr < 1 then
    retArr = {}
    ret = {
      ["ANIMAL"] = "/ANIMAL.png",
      ["REGULAR"] = "/REGULAR.png",
      ["FRONT"] = "/FRONT_32.png"
    }

    -- didn't find it locally, so download from the internet
    local b, c, h = socketHttp.request(SEARCH_API_URL .. "?n=" .. searchTerm)

    if c == 200 and b ~= nil and b ~= "" then
      -- we're all good, we got some data~
      local webData = jsonLib:decode(b)
      --print(inspect(webData))

      for index, value in ipairs(webData) do
        local charLocation = CHARACTERS_FOLDER .. string.gsub(string.gsub(value, IMAGES_URL, ""), "/FRONT_32.png", "")
        local newRet = {}
        local doesCharacterExist = true

        for key, endFile in pairs(ret) do
          local imageURL = string.gsub(value, "/FRONT_32.png", endFile)

          -- TODO: check that the image doesn't already exist in the folders so we don't have to ping the internet again

          -- download each image and put them into the save directory
          local image, status, err = socketHttp.request(imageURL)
          if status == 200 then
            -- make the folders
            if not love.filesystem.exists(charLocation) then
              love.filesystem.createDirectory(charLocation)
            end

            --print(charLocation..endFile)
            love.filesystem.write(charLocation .. endFile, image)
            newRet[key] = charLocation .. endFile
          else
            print("Could not save and download " .. charLocation..endFile.."!")
            doesCharacterExist = false
          end
        end

        if doesCharacterExist then table.insert(retArr, newRet) end
      end
    end
  end

  return retArr
end

function CharacterSelect:buildGUI()
  --local searchFrame = loveframes.Create("panel")
  --searchFrame:SetName("Search")
  --searchFrame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT / 2.0)
  --searchFrame:SetDraggable(false):ShowCloseButton(false)
  local offset = WINDOW_WIDTH - (scale * ORIG_WIDTH) + 20
  local padding = 20

  --## The GO! Button ##--
  goButton = loveframes.Create('button')
  goButton:SetText("GO!")
  goButton:SetWidth(goButton:GetWidth() + (offset * 2))
  goButton:SetPos(WINDOW_WIDTH - offset - goButton:GetWidth(), 0):SetHeight(WINDOW_HEIGHT)
  if numPlayers == 0 then
    goButton:SetEnabled(false)
  end
  goButton.OnClick = function(object)
    -- prepare the characters for the button select screen
    local newPlayers = {}
    for i = 1, #players do
      local player = players[i]

      if player["imageDir"] ~= nil then
        local newPlayer = Player(nil, player["imageDir"], nil, player["name"], player["button"]:GetProperty("playerIndex"))
        table.insert(newPlayers, newPlayer)
      end
    end

    -- change gamestate
    Gamestate.switch(ButtonSelect, newPlayers, song)
  end

  --## The Search Text ##--
  local searchText = loveframes.Create('text')
  searchText:SetDefaultColor(255, 255, 255, 255):SetText("Search: ")
  searchText:SetPos(offset, WINDOW_HEIGHT / 2.0 - searchText:GetHeight(), false)

  --## The Text Input for Search ##--
  local searchInput = loveframes.Create('textinput')
  searchInput:SetPos(offset + searchText:GetWidth(), searchText:GetY() - (searchText:GetHeight() / 2.0), false)
  searchInput:SetWidth(WINDOW_WIDTH - searchInput:GetX() - offset - goButton:GetWidth() - padding)

  searchInput.OnEnter = function(object)
    local text = object:GetText()
    object:Clear()
    -- TODO: send this to a thread so the rest of the program can run while data is coming
    foundData = self:getCharacter(socketUrl.escape(trim(text)))
    foundList:Clear()

    -- add the remove button
    local removeButton = loveframes.Create("button")
    removeButton:SetText("Remove Player")
    removeButton.OnClick = function(buttonObject)
      if players[selectedPlayer]["name"] ~= nil then
        numPlayers = numPlayers - 1
      end

      players[selectedPlayer]["imageDir"] = nil
      players[selectedPlayer]["images"] = nil
      players[selectedPlayer]["name"] = nil
      players[selectedPlayer]["button"]:SetImage(nil):SetText("Player "..selectedPlayer)

      -- set the goButton to disabled if no more players
      if numPlayers == 0 then
        goButton:SetEnabled(false)
      end
    end
    foundList:AddItem(removeButton)

    -- load any new images
    for index, characterData in ipairs(foundData) do
      local arrKey = string.gsub(characterData["FRONT"], "/FRONT_32.png", "")
      local charName = split(arrKey, "/")
      charName = charName[#charName]

      if loadedImages[arrKey] == nil then
        loadedImages[arrKey] = love.graphics.newImage(characterData["FRONT"])
      end

      --## Add the found image to the list ##--
      local charImageButton = loveframes.Create("imagebutton")
      charImageButton:SetImage(loadedImages[arrKey])
      charImageButton:Center()
      charImageButton:SetText(charName)
      charImageButton:SizeToImage()

      charImageButton.OnClick = function(buttonObject)
        if players[selectedPlayer]["name"] == nil then
          numPlayers = numPlayers + 1
        end

        -- change the currently selected player slot to this character
        players[selectedPlayer]["imageDir"] = arrKey
        players[selectedPlayer]["images"] = {["front"] = buttonObject:GetImage()}
        players[selectedPlayer]["name"] = buttonObject:GetText()
        players[selectedPlayer]["button"]:SetImage(buttonObject:GetImage()):SizeToImage():SetText(buttonObject:GetText())

        -- change the gobutton to enabled
        goButton:SetEnabled(true)
      end

      foundList:AddItem(charImageButton)
    end

    errText = " "..#foundData.." FOUND."
  end

  --## List Space for Found Items ##--
  foundList = loveframes.Create("list")
  foundList:SetPos(offset, 0)
  foundList:SetSize(WINDOW_WIDTH - foundList:GetX() - offset - goButton:GetWidth() - padding, searchInput:GetY() - 20)
  foundList:SetDisplayType("vertical"):EnableHorizontalStacking(true):SetAutoScroll(false)
  foundList:SetPadding(32):SetSpacing(32)

  --## List Space for Players ##--
  playerList = loveframes.Create("list")
  playerList:SetPos(offset, searchInput:GetY() + searchInput:GetHeight() + 20)
  playerList:SetSize(WINDOW_WIDTH - playerList:GetX() - offset - goButton:GetWidth() - padding, WINDOW_HEIGHT - playerList:GetY())
  playerList:SetDisplayType("vertical"):EnableHorizontalStacking(true):SetAutoScroll(false)
  playerList:SetPadding(32):SetSpacing(32)

  for i = 1, MAX_PLAYERS do
    players[i] = {}
    players[i]["button"] = loveframes.Create("imagebutton")
    players[i]["button"]:SetText("Player "..i):Center()
    players[i]["button"]:SetProperty("isDown", false)
    if i == selectedPlayer then
      players[i]["button"]:SetProperty("isDown", true)
    end
    players[i]["button"]:SetProperty("playerIndex", i)

    players[i]["button"].OnClick = function(object)
      local index = object:GetProperty("playerIndex")
      selectedPlayer = index

      for j = 1, MAX_PLAYERS do
        players[j]["button"]:SetProperty("isDown", false)
      end
      object:SetProperty("isDown", true)
    end

    playerList:AddItem(players[i]["button"])
  end
end

function CharacterSelect:init()
  loadedImages = {}
  players = {}
  selectedPlayer = 1
  numPlayers = 0

  --[[local charactersDir = love.filesystem.getDirectoryItems(CHARACTERS_FOLDER)

  for index, playerID in ipairs(charactersDir) do
    local playerDir = love.filesystem.getDirectoryItems(CHARACTERS_FOLDER.."/"..playerID)

    for playerIDIndex, charName in ipairs(playerDir) do
      local newImage = love.graphics.newImage(CHARACTERS_FOLDER.."/"..playerID.."/"..charName.."/FRONT_32.png")
      loadedImages[CHARACTERS_FOLDER.."/"..playerID.."/"..charName] = newImage
    end
  end]]

  self:buildGUI()

  song = love.audio.newSource(MUSIC_FOLDER .."/Eric Skiff - Chibi Ninja CC.mp3")
  song:setLooping(true)
end

function CharacterSelect:enter()
  text = ""
  errText = ""
  foundData = {}
  --[[loadedImages = {}

  local charactersDir = love.filesystem.getDirectoryItems(CHARACTERS_FOLDER)

  for index, playerID in ipairs(charactersDir) do
    local playerDir = love.filesystem.getDirectoryItems(CHARACTERS_FOLDER.."/"..playerID)

    for playerIDIndex, charName in ipairs(playerDir) do
      local newImage = love.graphics.newImage(CHARACTERS_FOLDER.."/"..playerID.."/"..charName.."/FRONT_32.png")
      loadedImages[CHARACTERS_FOLDER.."/"..playerID.."/"..charName] = newImage
    end
  end]]
  song:rewind()
  song:play()
end

function CharacterSelect:draw()
  love.graphics.push()
  love.graphics.translate(translation.x, translation.y)
  love.graphics.scale(scale)

  --[[love.graphics.setDefaultFilter("linear", "linear")
  love.graphics.print("Enter your search:"..errText)
  love.graphics.print(text, 10, 10)

  love.graphics.setDefaultFilter("nearest", "nearest")]]
  local offset = (ORIG_WIDTH - 64) / (#foundData * 1.0)
  local addX = offset - 16
  local addY = 32

  --[[for index, characterData in ipairs(foundData) do
    local image = loadedImages[string.gsub(characterData["FRONT"], "/FRONT_32.png", "")]
    love.graphics.draw(image, addX, addY)
    addX = addX + image:getWidth() + offset

    if addX >= ORIG_WIDTH then
      addX = offset
      addY = addY + image:getHeight() + offset
    end
  end]]

  --love.graphics.setDefaultFilter("linear", "linear")
  love.graphics.pop()

  loveframes.draw()
  --goButton:draw()
  --love.graphics.setDefaultFilter("nearest", "nearest")
end

function CharacterSelect:update(dt)
  loveframes.update(dt)
  --[[yui.update({goButton})
  goButton:update(dt)]]
end

function CharacterSelect:textinput(t)
  loveframes.textinput(t)
  --text = text .. t
end

function CharacterSelect:keypressed(key, isrepeat)
  loveframes.keypressed(key, isrepeat)

  if key == "backspace" then
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(text, -1)

    if byteoffset then
        -- remove the last UTF-8 character.
        -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
        text = string.sub(text, 1, byteoffset - 1)
    end
  end

  --[[if key == "return" then
    -- TODO: send this to a thread so the rest of the program can run while data is coming
    foundData = self:getCharacter(socketUrl.escape(trim(text)))
    --print(inspect(foundData))

    -- load any new images
    for index, characterData in ipairs(foundData) do
      local arrKey = string.gsub(characterData["FRONT"], "/FRONT_32.png", "")

      --if loadedImages[arrKey] == nil then
        loadedImages[arrKey] = love.graphics.newImage(characterData["FRONT"])
      --end
    end

    errText = " "..#foundData.." FOUND."
    text = ""
  end]]
end

function CharacterSelect:keyreleased(key)
	loveframes.keyreleased(key)
end

function CharacterSelect:mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function CharacterSelect:mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end
