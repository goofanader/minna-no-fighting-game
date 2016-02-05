local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/BossClasses/Boss"
AndrewLee = Class {__includes = Boss}

local HORIZ_SPEED = 1
local VERT_SPEED = 0.5
local SPECIAL_COOLDOWN = 15 --seconds
local SUMMON_COOLDOWN = 5 --seconds

function AndrewLee:init(minionCount)
  local HP = 100
  Boss.init(self, HP, minionCount)
  self.idle = love.graphics.newImage('assets/sprites/bosses/andrew_lee/andrew_lee_idle.png')
  self.hand = love.graphics.newImage('assets/sprites/bosses/andrew_lee/andrew_lee_idle_hand.png')
  self.sliders = {}
  for i=1,9 do
    self.sliders[i] = love.graphics.newImage('assets/sprites/bosses/andrew_lee/slidingImages/' .. i .. '.jpg')
  end
  self.spawned = false
  self.alive = false
  self.frame = self.idle
  self.flip = 1
end

function AndrewLee:spawn(pos)
  self.pos = pos
  self.alive = true
  self.spawned = true
  self.hitbox = HC.rectangle(pos.x-BOSS_SIZE/2,pos.y,BOSS_SIZE,BOSS_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'boss'
  self.vel = vector(-HORIZ_SPEED,VERT_SPEED)
  self.summonTimer = 0 --seconds
  self.specialTimer = SPECIAL_COOLDOWN*2 --seconds
  self.lag = 0
end

function AndrewLee:draw()
  Boss.draw(self)
  if self.alive then
    love.graphics.draw(self.frame,self.pos.x-self.flip*BOSS_SIZE,self.pos.y,0,self.flip,1)
  end
  if isDrawingHitbox and self.hitbox then
    self.hitbox:draw('line')
    love.graphics.print(self.hp,self.pos.x,self.pos.y+BOSS_SIZE)
  end
end

function AndrewLee:update(dt)
  Boss.update(self, dt)
  if not self.alive and not self.spawned then
    self:spawn(vector(ORIG_WIDTH-100,Y_POS))
  elseif self.alive then
    if self.lag > 0 then
      self.lag = self.lag - dt
    else
      self.summonTimer = self.summonTimer - dt
      self.specialTimer = self.specialTimer - dt
      if self.specialTimer <= 0 then
        self.lag = 3 --seconds
        self.specialTimer = love.math.random(SPECIAL_COOLDOWN)+SPECIAL_COOLDOWN
        self.frame = self.hand
      elseif self.summonTimer <= 0 then
        self:summonMinions()
        self.summonTimer = love.math.random(SUMMON_COOLDOWN)+SUMMON_COOLDOWN
        self.lag = 1.5 --seconds
        self.frame = self.hand
      else
        self:move()
        self.frame = self.idle
      end
    end
  end
  
end

function AndrewLee:move()
  local DIST_FROM_EDGE = 50
  local FLOAT_HEIGHT = 20
  
  self.pos = self.pos + self.vel
  self.hitbox:move(self.vel.x,self.vel.y)
  
  if self.pos.x < DIST_FROM_EDGE then
    self.vel.x = HORIZ_SPEED
    self:faceDirection('right')
  elseif self.pos.x > ORIG_WIDTH-DIST_FROM_EDGE then
    self.vel.x = -HORIZ_SPEED
    self:faceDirection('left')
  end
  
  if self.pos.y >= Y_POS then
    self.vel.y = -VERT_SPEED
  elseif self.pos.y < Y_POS - FLOAT_HEIGHT then
    self.vel.y = VERT_SPEED
  end
  
end

function AndrewLee:faceDirection(direction)
  if direction == 'right' and self.flip == 1 then
    self.flip = -1
  elseif direction == 'left' and self.flip == -1 then
    self.flip = 1
  end
end