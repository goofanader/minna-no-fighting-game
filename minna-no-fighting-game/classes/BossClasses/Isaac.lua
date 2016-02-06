local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/BossClasses/Boss"
Isaac = Class {__includes = Boss}

local SPEED = 0.25
local ATTACK_TIMER = 6 --seconds
local SUMMON_COOLDOWN = 5 --seconds

function Isaac:init(minionCount)
  local HP = 200*minionCount
  Boss.init(self, HP, minionCount)
  
  self.img = love.graphics.newImage('assets/sprites/bosses/isaac_cameron/isaac.png')
  local g = anim8.newGrid(BOSS_SIZE,BOSS_SIZE,self.img:getWidth(),self.img:getHeight())
  self.idle = anim8.newAnimation(g('2-3',1),1)
  self.walking = anim8.newAnimation(g('4-6',1,1,2),0.75)
  self.pointing = anim8.newAnimation(g('2-3',2),0.75)
  self.itemImages = {}
  for i=1,3 do
    self.itemImages[i]=love.graphics.newImage('assets/sprites/bosses/andrew_lee/slidingImages/' .. i .. '.jpg')
  end
  self.items = {}
  self.animation = self.idle
  self.flip = 1
end

function Isaac:spawn(pos)
  self.pos = pos
  self.alive = true
  self.spawned = true
  self.hitbox = HC.rectangle(pos.x,pos.y,BOSS_SIZE,BOSS_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'boss'
  self:faceDirection('left')
  self.summonTimer = 0 --seconds
  self.attackTimer = love.math.random(ATTACK_TIMER)+ATTACK_TIMER --seconds
  self.lag = 0
end

function Isaac:draw()
  Boss.draw(self)
  if self.alive then
    self.animation:draw(self.img, self.pos.x, self.pos.y)
  end
  if isDrawingHitbox and self.hitbox then
    self.hitbox:draw('line')
    love.graphics.print(self.hp,self.pos.x,self.pos.y+BOSS_SIZE)
  end
end

function Isaac:update(dt)
  Boss.update(self, dt)
  
  if not self.alive and not self.spawned then
    self:spawn(vector(ORIG_WIDTH-100,Y_POS))
  elseif self.alive then
    if self.lag > 0 then
      self.lag = self.lag - dt
    else
      self.summonTimer = self.summonTimer - dt
      if self.summonTimer <= 0 then
        self:summonMinions()
        self.summonTimer = love.math.random(SUMMON_COOLDOWN)+SUMMON_COOLDOWN
        self.lag = 1.5 --seconds
        self.animation = self.pointing
      else
        self:attack(dt)
      end
    end
  end
  
  self.animation:update(dt)
  
end

function Isaac:attack(dt)  
  
  self.animation = self.running
  
  local DIST_FROM_EDGE = 50
  
  self.vel.x = self.flip*SPEED*math.ceil(self.attackTimer/(ATTACK_TIMER*2)*8)
  self.pos = self.pos + self.vel
  self.hitbox:move(self.vel.x,self.vel.y)
  
  if self.pos.x < DIST_FROM_EDGE then
    self:faceDirection('right')
  elseif self.pos.x > ORIG_WIDTH-DIST_FROM_EDGE then
    self:faceDirection('left')
  end
  
  self.attackTimer = self.attackTimer - dt
  if self.attackTimer < 0 then
    self.lag = love.math.random(REST_TIME)+REST_TIME --seconds
    self.attackTimer = love.math.random(ATTACK_TIMER)+ATTACK_TIMER --seconds
    self.animation = self.resting
  end
end

function Isaac:faceDirection(direction)
  if direction == 'right' and self.flip == -1 then
    self.running:flipH()
    self.resting:flipH()
    self.summoning:flipH()
    self.flip = 1
  elseif direction == 'left' and self.flip == 1 then
    self.flip = -1
    self.running:flipH()
    self.resting:flipH()
    self.summoning:flipH()
  end
end