local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Boss = Class {}

function Boss:init(hp, minionCount, name, monologue)
  self.alive = false
  self.spawned = false
  self.hp = hp
  self.maxHP = hp
  self.minionCount = minionCount
  self.name = name
  self.monologue = monologue
  for i=1,minionCount do
    enemies[i] = Enemy(vector(0,Y_POS+love.math.random(12)),'assets/sprites/animal.png')
  end
end

function Boss:draw()
  for i=1,self.minionCount do
    enemies[i]:draw()
  end
  
  --HP BAR!
  local EDGE_BUFFER = 15
  local BORDER = 5
  local x = EDGE_BUFFER
  local y = EDGE_BUFFER
  local width = ORIG_WIDTH-EDGE_BUFFER*2
  local height = EDGE_BUFFER*2
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle('fill', x, y, width, height)
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle('fill', x+BORDER, y+BORDER, (width-BORDER*2)*self.hp/self.maxHP, height-BORDER*2)
  love.graphics.setColor(255,255,255)
  love.graphics.print(self.name, x+EDGE_BUFFER, y+EDGE_BUFFER/2, 0, 1, 1)
end

function Boss:update(dt)
  for i=1,self.minionCount do
    enemies[i]:update(dt)
  end
end

function Boss:hit(damage)
  self.hp = self.hp - damage
  if self.hp <= 0 then
    self.alive = false
    HC.remove(self.hitbox)
    self.hitbox = nil
  end
end

function Boss:summonMinions()
  for i=1,self.minionCount do
    if not enemies[i].alive then
      enemies[i]:spawn(vector(love.math.random(ORIG_WIDTH),-SPRITE_SIZE))
    end
  end
end

function Boss:isDefeated()
  if not self.alive and self.spawned then
    return true
  else
    return false
  end
end
