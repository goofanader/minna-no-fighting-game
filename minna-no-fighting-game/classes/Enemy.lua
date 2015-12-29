local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Enemy = Class{}

function Enemy:init(pos, imagefile)
  self.img = love.graphics.newImage(imagefile)
  self.pos = pos
  self.alive = true
  local g = anim8.newGrid(SPRITE_SIZE,SPRITE_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch = anim8.newAnimation(g('1-8',2),0.1)
  self.hitstun = anim8.newAnimation(g('1-2',3),0.1)
  self.idle = anim8.newAnimation(g('3-8',3,'1-6',4),0.1)
  self.animation = self.running
  --self.animation:flipH()
end

function Enemy:update(dt)
  self.animation:update(dt)
  if self.pos <= WINDOW_WIDTH then
    self.pos = self.pos + 1
  else
    self.pos = -25
  end
  
end

function Enemy:draw()
  if self.alive then
    self.animation:draw(self.img, self.pos, HORIZONTAL_PLANE)
  end
end

function Enemy:spawn(pos)
  self.alive = true
end

function Enemy:kill()
  self.alive = false
end
