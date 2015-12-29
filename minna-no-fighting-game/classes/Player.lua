local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Player = Class{}

local lastPressed
local BUTTON_DELAY = 0.1 --seconds

function Player:init(pos, imagefile, button)
  self.img = love.graphics.newImage(imagefile)
  self.pos = pos
  self.button = button
  local g = anim8.newGrid(SPRITE_SIZE,SPRITE_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch = anim8.newAnimation(g('1-8',2),0.1)
  self.hitstun = anim8.newAnimation(g('1-2',3),0.1)
  self.idle = anim8.newAnimation(g('3-8',3,'1-6',4),0.1)
  self.animation = self.running
  self.flipH = false
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
      
      if self.releaseTime < BUTTON_DELAY then --TODO: Make local function
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
    if self.holdTime > 2*BUTTON_DELAY and self.state ~= 'moveLeft' and self.charge <= 0 then
      if self.state ~= 'moveLeft' then
        self.state = 'moveLeft'
        if not self.flipH then --TODO: Make local function
          self.flipH = true
          self.running:flipH()
          self.punch:flipH()
          self.hitstun:flipH()
          self.idle:flipH()
        end
        self.animation = self.running
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
        self.animation = self.punch
      end
      
    else
      self.releaseTime = self.releaseTime + dt
      if self.charge > 0 then
        self.charge = self.charge - 1
      end
    end
    
    --Button Release Hold Action?
    if self.releaseTime > 2*BUTTON_DELAY and self.state ~= 'moveRight' and self.charge <= 0 then
      self.state = 'moveRight'
      if self.flipH then
        self.flipH = false
        self.running:flipH()
        self.punch:flipH()
        self.hitstun:flipH()
        self.idle:flipH()
      end
      self.animation = self.running
    end
    
  end
  
  --Act on Player State
  if self.state == 'moveRight' then
    if self.pos < WINDOW_WIDTH - SPRITE_SIZE then
      self.pos = self.pos + 1
    end
  elseif self.state == 'moveLeft' then
    if self.pos > 0 then
      self.pos = self.pos - 1
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
