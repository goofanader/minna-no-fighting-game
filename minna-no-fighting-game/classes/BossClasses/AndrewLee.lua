local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/BossClasses/Boss"
AndrewLee = Class {__includes = Boss}

function AndrewLee:init()
  Boss.init(self)
  self.idle = love.graphics.newImage('assets/sprites/bosses/andrew_lee/andrew_lee_idle.png')
  self.hand = love.graphics.newImage('assets/sprites/bosses/andrew_lee/andrew_lee_idle_hand.png')
  self.sliders = {}
  for i=1,9 do
    self.sliders[i] = love.graphics.newImage('assets/sprites/bosses/andrew_lee/slidingImages/' .. i .. '.jpg')
  end
  self.spawned = false
  self.frame = self.idle
end

function AndrewLee:spawn(pos)
  self.pos = pos
  self.alive = true
  self.spawned = true
end

function AndrewLee:draw()
  if self.alive then
    love.graphics.draw(self.frame,self.pos.x,self.pos.y)
  end
  
end

function AndrewLee:update(dt)
  if not self.alive and not self.spawned then
    self:spawn(vector(WINDOW_WIDTH-100,Y_POS+10))
  elseif self.alive then
    
    
  end
  
end
