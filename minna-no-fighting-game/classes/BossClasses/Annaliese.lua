local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/BossClasses/Boss"
Annaliese = Class {__includes = Boss}

local SPEED = 3
local SPECIAL_COOLDOWN = 5 --seconds
local SPECIAL_DURATION = 3 --seconds
local SUMMON_COOLDOWN = 5 --seconds
local METEOR_COOLDOWN = 0.05 --seconds
local METEOR_SPEED = 6
local METEOR_DAMAGE = 5

function Annaliese:init(minionCount)
  local HP = 150*minionCount
  local name = 'Annaliese'
  local monologue = 'Hey there!'
  Boss.init(self, HP, minionCount, name, monologue, nil, THE_SILO)

  self.img = love.graphics.newImage('assets/sprites/bosses/annaliese/annaliese.png')
  local g = anim8.newGrid(BOSS_SIZE,BOSS_SIZE,self.img:getWidth(),self.img:getHeight())
  self.idle = anim8.newAnimation(g('2-3',1),0.75)
  self.moving = anim8.newAnimation(g('4-5',1),0.1)
  self.attacking = anim8.newAnimation(g(6,1,1,2,6,1,2,2,6,1,3,2),0.075)
  self.meteorAnimation = anim8.newAnimation(g('4-5',2),0.1)
  self.meteors = {}
  self.animation = self.idle
  self.flip = 1
end

function Annaliese:spawn(pos)
  self.pos = pos
  self.alive = true
  self.spawned = true
  self.hitbox = HC.rectangle(pos.x,pos.y,BOSS_SIZE,BOSS_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'boss'
  self:faceDirection('left')
  self.vel = vector(0,0)
  self.summonTimer = 0 --seconds
  self.specialTimer = love.math.random(SPECIAL_COOLDOWN)+SPECIAL_COOLDOWN --seconds
  self.meteorTimer = METEOR_COOLDOWN --seconds
  self.lag = 0
end

function Annaliese:draw()
  Boss.draw(self)
  if self.alive then
    self.animation:draw(self.img, self.pos.x, self.pos.y)
  end
  if isDrawingHitbox and self.hitbox then
    self.hitbox:draw('line')
    love.graphics.print(self.hp,self.pos.x,self.pos.y+BOSS_SIZE)
  end
  for index, meteor in ipairs(self.meteors) do
    meteor.animation:draw(self.img,meteor.pos.x,meteor.pos.y,meteor.theta)
    if isDrawingHitbox and meteor.hitbox then
      love.graphics.setColor(0,0,255)
      meteor.hitbox:draw('line')
      love.graphics.setColor(255,255,255)
    end
  end
end

function Annaliese:update(dt)
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
        self:specialAttack(dt)
      elseif self.summonTimer <= 0 then
        self:summonMinions()
        self.summonTimer = love.math.random(SUMMON_COOLDOWN)+SUMMON_COOLDOWN
        self.lag = 1.5 --seconds
        self.animation = self.attacking
      else
        self:move(dt)
      end
    end
  end

  self.animation:update(dt)

  for index, meteor in ipairs(self.meteors) do

    meteor.pos = meteor.pos + meteor.vel
    meteor.hitbox:move(meteor.vel.x,meteor.vel.y)
    meteor.animation:update(dt)

    if meteor.pos.y > ORIG_HEIGHT+BOSS_SIZE then
      HC.remove(meteor.hitbox)
      table.remove(self.meteors,index)
    end

    for shape, delta in pairs(HC.collisions(meteor.hitbox)) do
      if shape.class == 'player' then
        local alreadyHit = false
        if meteor.targetsHit then
          for i,target in ipairs(meteor.targetsHit) do
            if target == shape.owner then
              alreadyHit = true
            end
          end
        end
        if not alreadyHit then
          shape.owner:hit(METEOR_DAMAGE)
          --TODO: Knockback here OR put it in the hit() function
          table.insert(meteor.targetsHit,shape.owner)
        end
      end
    end
  end

end

function Annaliese:move(dt)
  self.animation = self.moving

  local DIST_FROM_EDGE = 50

  self.vel.x = self.flip*SPEED
  self.pos = self.pos + self.vel
  self.hitbox:move(self.vel.x,self.vel.y)

  if self.pos.x < DIST_FROM_EDGE-BOSS_SIZE/2 then
    self:faceDirection('right')
  elseif self.pos.x > ORIG_WIDTH-DIST_FROM_EDGE-BOSS_SIZE/2 then
    self:faceDirection('left')
  end
end

function Annaliese:specialAttack(dt)
  self.meteorTimer = self.meteorTimer - dt
  self.animation = self.attacking

  if self.meteorTimer <= 0 then
    local meteor = {}
    meteor.animation = self.meteorAnimation:clone()
    meteor.pos = vector(love.math.random(BOSS_SIZE,ORIG_WIDTH-BOSS_SIZE),-BOSS_SIZE)
    meteor.theta = math.pi/2
    meteor.vel = vector(0,METEOR_SPEED)
    meteor.hitbox = HC.rectangle(meteor.pos.x,meteor.pos.y,BOSS_SIZE,BOSS_SIZE)
    meteor.hitbox:setRotation(meteor.theta,meteor.pos.x,meteor.pos.y)
    meteor.hitbox.class = 'projectile'
    meteor.targetsHit = {}
    table.insert(self.meteors,meteor)
    self.meteorTimer = love.math.random()*METEOR_COOLDOWN*3+METEOR_COOLDOWN
  end

  if self.specialTimer < -SPECIAL_DURATION then
    self.lag = 1.5 --seconds
    self.specialTimer = math.ceil((love.math.random(SPECIAL_COOLDOWN)+SPECIAL_COOLDOWN)*self.hp/self.maxHP)
    self.animation = self.idle
  end
end

function Annaliese:faceDirection(direction)
  if direction == 'right' and self.flip == -1 then
    self.idle:flipH()
    self.moving:flipH()
    self.attacking:flipH()
    self.flip = 1
  elseif direction == 'left' and self.flip == 1 then
    self.idle:flipH()
    self.moving:flipH()
    self.attacking:flipH()
    self.flip = -1
  end
end
