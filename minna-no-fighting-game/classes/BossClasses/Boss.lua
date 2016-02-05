local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Boss = Class {}

function Boss:init(hp, minionCount)
  self.alive = false
  self.hp = hp
  self.minionCount = minionCount
  for i=1,minionCount do
    enemies[i] = Enemy(vector(0,Y_POS+love.math.random(12)),'assets/sprites/animal.png')
  end
end

function Boss:draw()
  for i=1,self.minionCount do
    enemies[i]:draw()
  end
end

function Boss:update(dt)
  for i=1,self.minionCount do
    enemies[i]:update(dt)
  end
end

function Boss:hit(damage)
  self.hp = self.hp - damage
  if self.hp <= 0 then
    --self:kill()
  end
end

function Boss:summonMinions()
  for i=1,self.minionCount do
    if not enemies[i].alive then
      enemies[i]:spawn(vector(love.math.random(ORIG_WIDTH),-SPRITE_SIZE))
    end
  end
end
