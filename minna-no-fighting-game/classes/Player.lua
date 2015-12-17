local Class = require "libraries/hump.class"
local anim8 = require "anim8"

Player = Class{}

function Player:init(pos, imagefile)
  self.img = love.graphics.newImage(imagefile)
  local g = anim8.newGrid(32,32,self.img:getWidth(),self.img:getHeight())
  self.animation = anim8.newAnimation(g('1-8',1),0.1)
end

function Player:update(dt)
  self.animation:update(dt)
end

function Player:draw()
  love.graphics.draw(self.img, self.pos.x, self.pos.y)
end
