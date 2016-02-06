local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/BossClasses/Boss"
Phyllis = Class {__includes = Boss}

local SPEED = 0.25
local ATTACK_TIME = 6 --seconds
local REST_TIME = 2 --seconds
local SUMMON_COOLDOWN = 5 --seconds

function Phyllis:init(minionCount)
  local HP = 200*minionCount
  Boss.init(self, HP, minionCount)
  
  self.img = love.graphics.newImage('assets/sprites/bosses/phyllis_douglas/phyllis.png')
  local g = anim8.newGrid(BOSS_SIZE,BOSS_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-6',2),0.1)
  self.resting = anim8.newAnimation(g('2-3',1),0.75)
  self.summoning = anim8.newAnimation(g('4-5',1),0.75)
  self.animation = self.running

  self.flip = 1
end

function Phyllis:spawn(pos)
  self.pos = pos
  self.alive = true
  self.spawned = true
  self.hitbox = HC.rectangle(pos.x,pos.y,BOSS_SIZE,BOSS_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'boss'
  self.vel = vector(-SPEED,0)
  self:faceDirection('left')
  self.summonTimer = 0 --seconds
  self.attackTimer = love.math.random(ATTACK_TIME)+ATTACK_TIME --seconds
  self.lag = 0
end

function Phyllis:draw()
  Boss.draw(self)
  if self.alive then
    self.animation:draw(self.img, self.pos.x, self.pos.y)
  end
  if isDrawingHitbox and self.hitbox then
    self.hitbox:draw('line')
    love.graphics.print(self.hp,self.pos.x,self.pos.y+BOSS_SIZE)
  end
end

function Phyllis:update(dt)
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
        self.animation = self.summoning
      else
        self:attack(dt)
      end
    end
  end
  
  self.animation:update(dt)
  
end

function Phyllis:attack(dt)  
  
  self.animation = self.running
  
  local DIST_FROM_EDGE = 50
  
  self.vel.x = self.flip*SPEED*math.ceil(self.attackTimer/(ATTACK_TIME*2)*8)
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
    self.attackTimer = love.math.random(ATTACK_TIME)+ATTACK_TIME --seconds
    self.animation = self.resting
  end
end

function Phyllis:faceDirection(direction)
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