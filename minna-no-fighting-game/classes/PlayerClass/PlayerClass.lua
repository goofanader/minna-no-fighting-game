local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

PlayerClass = Class {}

function PlayerClass:init(imageLocation, className, range)
  self.name = className
  self.imageLocation = imageLocation
  self.range = range
  self.spritesheet = love.graphics.newImage(imageLocation .. "/"..className..".png")

  self.grid = anim8.newGrid(SPRITE_SIZE, SPRITE_SIZE, self.spritesheet:getWidth(), self.spritesheet:getHeight())
  self.animation = ""
end

function PlayerClass:draw()
end

function PlayerClass:update(dt)
end
