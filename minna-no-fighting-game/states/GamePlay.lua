local Gamestate = require "libraries/hump.gamestate"

require "classes/Player"
require "classes/Enemy"

GamePlay = {}

function GamePlay:enter()
  --player1 = Player(
end

function GamePlay:draw()
  love.graphics.print("You're playing a game!", 10, 10)
  --player1.draw()
end

function GamePlay:update(dt)
end