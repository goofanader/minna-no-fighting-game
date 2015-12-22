local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Enemy = Class{}

function Enemy:init(pos, imagefile)
  self.img = love.graphics.newImage(imagefile)
  self.pos = pos
  local g = anim8.newGrid(32,32,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch = anim8.newAnimation(g('1-8',2),0.1)
  self.hitstun = anim8.newAnimation(g('1-2',3),0.1)
  self.idle = anim8.newAnimation(g('3-8',3,'1-6',4),0.1)
  self.animation = self.idle
  self.animation:flipH()
end

function Enemy:update(dt)
  self.animation:update(dt)
end

function Enemy:draw()
  self.animation:draw(self.img, self.pos, 50)
end
