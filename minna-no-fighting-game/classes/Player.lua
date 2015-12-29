local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Player = Class{}

local BUTTON_DELAY = 0.1 --seconds

function Player:init(pos, imagefile, button)
  self.img = love.graphics.newImage(imagefile)
  self.pos = pos
  self.button = button
  local g = anim8.newGrid(SPRITE_SIZE,SPRITE_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch1 = anim8.newAnimation(g('1-8',2),0.05,'pauseAtEnd')
  self.punch2 = anim8.newAnimation(g('1-7',3),0.05,'pauseAtEnd')
  self.hitstun = anim8.newAnimation(g('1-2',4),0.1)
  self.idle = anim8.newAnimation(g('3-8',4,'1-6',5),0.1)
  self.animation = self.running
  self.flip = false
  self.buttonFlag = false
  self.holdTime = 0
  self.releaseTime = 0
  self.charge = 0
  self.chargeFlag = false
end

function Player:update(dt)
  
  --Button Press Actions
  if love.keyboard.isDown(self.button) then
    if not self.buttonFlag then
      self.buttonFlag = true
      self.holdTime = 0
      
      if self.releaseTime < BUTTON_DELAY then
        if self.chargeFlag or self.state == 'charge' then
          if self.state ~= 'charge' then
            self.state = 'charge'
            self.animation = self.hitstun
          end
          self.charge = self.charge + 5
        else
          self.chargeFlag = true
        end
      else
        self.chargeFlag = false
      end
      
    else
      self.holdTime = self.holdTime + dt
      if self.charge > 0 then
        self.charge = self.charge - 1
      end
    end
    
    --Button Hold Action
    if self.holdTime > 2*BUTTON_DELAY and self.state ~= 'moveAway' and self.charge <= 0 then
      if self.state ~= 'moveAway' then
        self.state = 'moveAway'
        self.animation = self.idle
      end
    end
    
  else --Button Release Actions
    if self.buttonFlag then
      self.buttonFlag = false
      self.releaseTime = 0
      if self.holdTime < BUTTON_DELAY then -- CHARGE
        if self.chargeFlag or self.state == 'charge' then
          if self.state ~= 'charge' then
            self.state = 'charge'
            self.animation = self.hitstun
          end
          self.charge = self.charge + 5
        else
          self.chargeFlag = true
        end
      else
        self.chargeFlag = false
      end
      
      if self.holdTime < 2*BUTTON_DELAY and self.state ~= 'charge' then --ATTACKU
        self.state = 'punch'
        self.animation = self.punch1
        self.animation:gotoFrame(1)
        if self.closestEnemy then
          self.closestEnemy:kill()
        end
      end
      
    else
      self.releaseTime = self.releaseTime + dt
      if self.charge > 0 then
        self.charge = self.charge - 1
      end
    end
    
    --Button Release Hold Action?
    if self.releaseTime > 2*BUTTON_DELAY and self.state ~= 'moveTowards' and self.charge <= 0 then
      self.state = 'moveTowards'
      self.animation = self.idle
    end
    
  end
  
  --Act on Player State
  if self.state == 'moveTowards' then
    
    --Find Nearest Enemy
    self.closestEnemy = nil
    local distance = 100000000
    for i=1,numberOfEnemies do
      if enemies[i].alive then
        if math.abs(enemies[i].pos - self.pos) < distance then
          self.closestEnemy = enemies[i]
          distance = math.abs(self.closestEnemy.pos - self.pos)
        end
      end
    end
    
    if self.closestEnemy then
      if self.closestEnemy.pos < self.pos-SPRITE_SIZE and self.pos > 0 then
        self.pos = self.pos - 1
        self:faceDirection('left')
        self.animation = self.running
      elseif self.closestEnemy.pos > self.pos+SPRITE_SIZE and self.pos < WINDOW_WIDTH-SPRITE_SIZE then
        self.pos = self.pos + 1
        self:faceDirection('right')
        self.animation = self.running
      else
        self.animation = self.idle
      end
    else
      self.animation = self.idle
    end
    
  elseif self.state == 'moveAway' then
    
    if self.closestEnemy then
      if self.closestEnemy.pos < self.pos and self.pos < WINDOW_WIDTH-SPRITE_SIZE then
        self.pos = self.pos + 1
        self:faceDirection('right')
        self.animation = self.running
      elseif self.closestEnemy.pos >= self.pos and self.pos > 0 then
        self.pos = self.pos - 1
        self:faceDirection('left')
        self.animation = self.running
      end
    else
      self.animation = self.idle
    end 
  end
  
  self.animation:update(dt)
end

function Player:draw()
  self.animation:draw(self.img, self.pos, HORIZONTAL_PLANE)
  if self.charge > 0 then
    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle('fill', self.pos, HORIZONTAL_PLANE+SPRITE_SIZE+3, self.charge, 3)
    love.graphics.setColor(255,255,255,255)
  end
end

function Player:faceDirection(direction)
  if direction == 'right' and self.flip then
    self.flip = false
    self.running:flipH()
    self.punch1:flipH()
    self.punch2:flipH()
    self.hitstun:flipH()
    self.idle:flipH()
  elseif direction == 'left' and not self.flip then
    self.flip = true
    self.running:flipH()
    self.punch1:flipH()
    self.punch2:flipH()
    self.hitstun:flipH()
    self.idle:flipH()
  end
end
