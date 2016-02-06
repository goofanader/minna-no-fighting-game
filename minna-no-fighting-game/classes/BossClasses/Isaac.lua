local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/BossClasses/Boss"
Isaac = Class {__includes = Boss}

local SPEED = 0.5
local ATTACK_COOLDOWN = 5 --seconds
local SUMMON_COOLDOWN = 5 --seconds
local ITEM_FLOAT_TIME = 1 --seconds
local ITEM_SPEED = 3
local DAMAGE = 10

function Isaac:init(minionCount)
  local HP = 200*minionCount
  local name = 'The Cat King'
  local monologue = 'Hey there!'
  Boss.init(self, HP, minionCount, name, monologue, MUSIC_FOLDER .. "/YZYX - Neon Genesis Evangelion - Cruel Angel's Thesis (Game Boy version) (Probably Copyrighted).mp3", THE_SILO)

  self.img = love.graphics.newImage('assets/sprites/bosses/isaac_cameron/isaac.png')
  local g = anim8.newGrid(BOSS_SIZE,BOSS_SIZE,self.img:getWidth(),self.img:getHeight())
  self.idle = anim8.newAnimation(g('2-3',1),0.75)
  self.walking = anim8.newAnimation(g('4-6',1,1,2),0.1)
  self.pointing = anim8.newAnimation(g('2-3',2),0.75)
  self.itemImages = {love.graphics.newImage('assets/sprites/bosses/isaac_cameron/book1.png'),
    love.graphics.newImage('assets/sprites/bosses/isaac_cameron/book2.png'),
    love.graphics.newImage('assets/sprites/bosses/isaac_cameron/drill.png') }
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
  self.vel = vector(0,0)
  self.summonTimer = 0 --seconds
  self.attackTimer = love.math.random(ATTACK_COOLDOWN)+ATTACK_COOLDOWN --seconds
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
  for index, item in ipairs(self.items) do
    love.graphics.draw(item.img,item.pos.x,item.pos.y,item.theta)
    if isDrawingHitbox and item.hitbox then
      love.graphics.setColor(0,0,255)
      item.hitbox:draw('line')
      love.graphics.setColor(255,255,255)
    end
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
      self.attackTimer = self.attackTimer - dt
      if self.attackTimer <= 0 then
        self:attack()
        self.animation = self.pointing
        self.lag = 1.5 --seconds
        self.attackTimer = love.math.random(ATTACK_COOLDOWN)+ATTACK_COOLDOWN
      elseif self.summonTimer <= 0 then
        self:summonMinions()
        self.summonTimer = love.math.random(SUMMON_COOLDOWN)+SUMMON_COOLDOWN
        self.lag = 1.5 --seconds
        self.animation = self.pointing
      else
        self:move(dt)
      end
    end
  end

  self.animation:update(dt)

  for index, item in ipairs(self.items) do
    if item.timer > 0 then
      item.timer = item.timer - dt
    elseif not item.fired then
      item.vel = (players[love.math.random(numberOfPlayers)].pos - item.pos):normalized()*ITEM_SPEED
      --item.omega = (love.math.random()-0.5)/10
      item.fired = true
    end

    item.pos = item.pos + item.vel
    item.theta = item.theta + item.omega --rotational velocity
    item.hitbox:move(item.vel.x,item.vel.y)
    item.hitbox:rotate(item.omega)

    if item.fired then
      for shape, delta in pairs(HC.collisions(item.hitbox)) do
        if shape.class == 'player' then
          local alreadyHit = false
          if item.targetsHit then
            for i,target in ipairs(item.targetsHit) do
              if target == shape.owner then
                alreadyHit = true
              end
            end
          end
          if not alreadyHit then
            shape.owner:hit(DAMAGE)
            --TODO: Knockback here OR put it in the hit() function
            table.insert(item.targetsHit,shape.owner)
          end
        elseif shape.class == 'wall' and ( delta.x > item.img:getWidth()/2 or delta.y > item.img:getWidth()/2 ) then
          HC.remove(item.hitbox)
          table.remove(self.items,index)
        end
      end
    end
  end

end

function Isaac:move(dt)
  self.animation = self.walking

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

function Isaac:attack()
  for i=1, math.ceil(numberOfPlayers*1.25) do
    local item = {}
    item.img = self.itemImages[love.math.random(#self.itemImages)]
    item.pos = self.pos + vector(love.math.random(-100,100),love.math.random(-10,10))
    local DIST_FROM_EDGE = 50
    if item.pos.x < DIST_FROM_EDGE then
      item.pos.x = DIST_FROM_EDGE
    elseif item.pos.x > ORIG_WIDTH-DIST_FROM_EDGE then
      item.pos.x = ORIG_WIDTH-DIST_FROM_EDGE
    end
    item.vel = vector(0,-0.5)
    item.theta = 0 --love.math.random()*2*math.pi --angular position
    item.omega = 0 --angular velocity
    item.timer = ITEM_FLOAT_TIME
    item.fired = false
    item.hitbox = HC.rectangle(item.pos.x,item.pos.y,item.img:getWidth(),item.img:getHeight())
    item.hitbox:setRotation(item.theta)
    item.hitbox.class = 'projectile'
    item.targetsHit = {}
    table.insert(self.items,item)
  end
end

function Isaac:faceDirection(direction)
  if direction == 'right' and self.flip == -1 then
    self.idle:flipH()
    self.walking:flipH()
    self.pointing:flipH()
    self.flip = 1
  elseif direction == 'left' and self.flip == 1 then
    self.flip = -1
    self.idle:flipH()
    self.walking:flipH()
    self.pointing:flipH()
  end
end
