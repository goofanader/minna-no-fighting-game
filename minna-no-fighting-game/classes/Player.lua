local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Player = Class{}

function Player:init(pos, imagefile)
  self.img = love.graphics.newImage(imagefile)
  self.pos = pos
  local g = anim8.newGrid(32,32,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch = anim8.newAnimation(g('1-8',2),0.1)
  self.hitstun = anim8.newAnimation(g('1-2',3),0.1)
  self.idle = anim8.newAnimation(g('3-8',3,'1-6',4),0.1)
  self.animation = self.idle
  self.flipH = 0
end

function Player:update(dt)
  self.animation:update(dt)
end

function Player:draw()
  self.animation:draw(self.img, self.pos, 50)
end

function Player:keypressed(key, isrepeat)
  if key == "right" then
    if self.flipH == 1 then
      self.running:flipH()
      self.punch:flipH()
      self.hitstun:flipH()
      self.idle:flipH()
      self.flipH = 0
    end
    self.animation = self.running
  end
  if key == "left" then
    if self.flipH == 0 then
      self.running:flipH()
      self.punch:flipH()
      self.hitstun:flipH()
      self.idle:flipH()
      self.flipH = 1
    end
    self.animation = self.running
  end
  if key == "z" then
    self.animation = self.punch
    self.animation:gotoFrame(1)
  end
  if key == "x" then
    self.animation = self.hitstun
  end
end

function Player:keyreleased(key, isrepeat)
  --if key == "right" then
    self.animation = self.idle
  --end
end
