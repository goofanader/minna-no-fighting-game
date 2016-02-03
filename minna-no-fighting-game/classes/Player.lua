local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/PlayerClass/ANIMAL"
require "classes/PlayerClass/REGULAR"

Player = Class{}

local BUTTON_DELAY = 0.1 --seconds

function Player:init(pos, imagefilesLocation, button, name, id)
  self.classes = self:getClasses(imagefilesLocation)
  self.button = button
  self.name = name
  self.id = id
  --[[local g = anim8.newGrid(SPRITE_SIZE,SPRITE_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch1 = anim8.newAnimation(g('1-8',2),0.02,'pauseAtEnd')
  self.punch2 = anim8.newAnimation(g('1-8',3),0.02,'pauseAtEnd')
  self.punch3 = anim8.newAnimation(g('1-8',4,'1-8',5,1,6),0.02,'pauseAtEnd')
  self.hitstun = anim8.newAnimation(g('2-3',6),0.1)
  self.idle = anim8.newAnimation(g('4-8',6,'1-7',7),0.1)
  self.animation = self.idle]]
  self:spawn(pos)
end

function Player:getClasses(imagesLocation)
  -- hardcoding the two classes we have right now...
  local classInfo = {}
  classInfo[NO_RANGE] = RegularPlayerClass(imagesLocation)
  classInfo[CLOSE_RANGE] = AnimalPlayerClass(imagesLocation)

  return classInfo
end

function Player:spawn(pos)
  self.pos = pos or vector(0, 0)
  self.hitbox = HC.rectangle(self.pos.x, self.pos.y, SPRITE_SIZE, SPRITE_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'player'
  self.currClass = self.classes[NO_RANGE]
  self.animation = self.currClass.idle
  self.flip = false
  self.buttonFlag = false
  self.holdTime = 0
  self.releaseTime = 0
  self.charge = 0
  self.chargeFlag = false
  self.lag = 0
  self.state = 'idle'
  self.alive = true
end

function Player:update(dt)

  if self.alive then
    --Button Press Actions
    if love.keyboard.isDown(self.button) then
      if not self.buttonFlag then
        self.buttonFlag = true
        self.holdTime = 0

        if self.releaseTime < BUTTON_DELAY then -- CHARGE
          if self.chargeFlag or self.state == 'charge' then
            --self:chargeUp()
          elseif self:canMove() then
            self.chargeFlag = true
          end
        else
          self.chargeFlag = false
        end

      else -- INCREMENT HOLD TIME
        self.holdTime = self.holdTime + dt
        if self.charge > 0 then -- DEFUSE THE CHARGE
          self.charge = self.charge - 1
        elseif self.state == 'charge' then
          self.state = 'idle'
        end
      end

      --Button Hold Action -- Move away from nearest enemy
      if self.holdTime > 2*BUTTON_DELAY and self:canMove() then
        self.combo = 0
        if self.state ~= 'moveAway' and self.charge <= 0 then
          self.state = 'moveAway'
          self.currClass = self.classes[NO_RANGE]
          self.animation = self.currClass.idle
        end
      end

    else --Button Release Actions
      if self.buttonFlag then
        self.buttonFlag = false
        self.releaseTime = 0

        if self.holdTime < BUTTON_DELAY then -- CHARGE
          if self.chargeFlag or self.state == 'charge' then
            --self:chargeUp()
          elseif self:canMove() then
            self.chargeFlag = true
          end
        else
          self.chargeFlag = false
        end

        if self.holdTime < 2*BUTTON_DELAY and self:canMove() then
          if self.state ~= 'charge' then --ATTACK
            self.state = 'attack'
            if self.combo == 0 or self.combo == 3 then
              self.currClass = self.classes[CLOSE_RANGE]
              self.animation = self.currClass.punch1
              self.combo = 1
            elseif self.combo == 1 then
              self.currClass = self.classes[CLOSE_RANGE]
              self.animation = self.currClass.punch2
              self.combo = 2
            else
              self.currClass = self.classes[CLOSE_RANGE]
              self.animation = self.currClass.punch3
              self.combo = 3
            end
            self.attackBoxFlag = false
            self.animation:gotoFrame(1)
            self.animation:resume()
          end
        end

      else -- Increment Release Time
        self.releaseTime = self.releaseTime + dt
        if self.charge > 0 then -- Defuse Charge
          self.charge = self.charge - 1
        elseif self.state == 'charge' then
          self.state = 'idle'
        end
      end

      --The Do Nothing Action -- Move towards enemy
      if self.releaseTime > 2*BUTTON_DELAY and self:canMove() then
        self.combo = 0
        if self.state ~= 'moveTowards' and self.charge <= 0 then
          self.state = 'moveTowards'
          self.currClass = self.classes[NO_RANGE]
          self.animation = self.currClass.idle
        end
      end
    end

    --Act on Player State
    if self.state == 'moveTowards' then -- Not doing anything

      --Find Nearest Enemy
      self.closestEnemy = nil
      local distance = 10000000

      for i=1,numberOfEnemies do
        if enemies[i].alive then
          if math.abs(enemies[i].pos.x - self.pos.x) < distance then
            self.closestEnemy = enemies[i]
            distance = math.abs(self.closestEnemy.pos.x - self.pos.x)
          end
        end
      end

      -- Move towards nearest enemy
      if self.closestEnemy then
        if self.closestEnemy.pos.x < self.pos.x then
          self:move_with_collision(-1,0)
        else
          self:move_with_collision(1,0)
        end
      else
        self.currClass = self.classes[NO_RANGE]
        self.animation = self.currClass.idle
      end

    elseif self.state == 'moveAway' then -- Holding the button
      -- Move away from last targeted enemy
      if self.closestEnemy then
        if self.closestEnemy.pos.x < self.pos.x then
          self:move_with_collision(1,0)
        else
          self:move_with_collision(-1,0)
        end
      else
        self.currClass = self.classes[NO_RANGE]
        self.animation = self.currClass.idle
      end

    elseif self.state == 'attack' then -- Tapping the button, but not too fast
      if self.combo == 1 then
        if self.animation.position >= 2 and not self.attackBoxFlag then -- Frame Number
          if self.flip then
            self.punchbox = HC.rectangle(self.pos.x-5,self.pos.y,5,SPRITE_SIZE)
          else
            self.punchbox = HC.rectangle(self.pos.x+SPRITE_SIZE,self.pos.y,5,SPRITE_SIZE)
          end
          self.punchbox.damage = 3
          self.targetsHit = {}
          self.attackBoxFlag = true
        elseif self.animation.position >= 7 and self.attackBoxFlag then
          self.attackBoxFlag = false
          HC.remove(self.punchbox)
          self.punchbox = nil
          self.state = 'idle'
          self.lag = BUTTON_DELAY
        end
      elseif self.combo == 2 then
        if self.animation.position >= 2 and not self.attackBoxFlag then
          if self.flip then
            self.punchbox = HC.rectangle(self.pos.x-5,self.pos.y,5,SPRITE_SIZE)
          else
            self.punchbox = HC.rectangle(self.pos.x+SPRITE_SIZE,self.pos.y,5,SPRITE_SIZE)
          end
          self.punchbox.damage = 4
          self.targetsHit = {}
          self.attackBoxFlag = true
        elseif self.animation.position >= 8 and self.attackBoxFlag then
          self.attackBoxFlag = false
          HC.remove(self.punchbox)
          self.punchbox = nil
          self.state = 'idle'
          self.lag = BUTTON_DELAY
        end
      elseif self.combo == 3 then
        if self.animation.position >= 1 and not self.attackBoxFlag then
          if self.flip then
            self.punchbox = HC.rectangle(self.pos.x-5,self.pos.y,5,SPRITE_SIZE)
          else
            self.punchbox = HC.rectangle(self.pos.x+SPRITE_SIZE,self.pos.y,5,SPRITE_SIZE)
          end
          self.punchbox.damage = 5
          self.targetsHit = {}
          self.attackBoxFlag = true
        elseif self.animation.position >= 7 and self.attackBoxFlag then
          self.attackBoxFlag = false
          HC.remove(self.punchbox)
          self.punchbox = nil
          self.state = 'idle'
          self.lag = BUTTON_DELAY
        end
      end
      if self.attackBoxFlag then
        for shape, delta in pairs(HC.collisions(self.punchbox)) do
          if shape.class == 'enemy' then
            local alreadyHit = false
            if self.targetsHit then
              for i,target in ipairs(self.targetsHit) do
                if target == shape.owner then
                  alreadyHit = true
                end
              end
            end
            if not alreadyHit then
              shape.owner:hit(self.punchbox.damage)
              table.insert(self.targetsHit,shape.owner)
            end
            if self.flip then
              --shape.owner:move_with_collision(-1,0)
            else
              --shape.owner:move_with_collision(1,0)
            end
          end
        end
      end
    end
  end

  if self.lag > 0 then
    self.lag = self.lag - dt
  end
  self.animation:update(dt)
end

function Player:draw()
  self.animation:draw(self.currClass.spritesheet, self.pos.x, self.pos.y)
  --[[if self.charge > 0 then
    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle('fill', self.pos.x, self.pos.y+SPRITE_SIZE+3, self.charge, 3)
    love.graphics.setColor(255,255,255,255)
  end]]
  if isDrawingHitbox then self.hitbox:draw('line') end

  if isDrawingHitbox and self.punchbox then
    love.graphics.setColor(0,255,0)
    self.punchbox:draw('line')
    love.graphics.setColor(255,255,255)
  end
  if self.currentFrame then
    love.graphics.print(self.currentFrame,self.pos.x,self.pos.y-10)
  end

end

function Player:faceDirection(direction)
  if direction == 'right' and self.flip then
    self.flip = false
    self.classes[CLOSE_RANGE].running:flipH()
    self.classes[CLOSE_RANGE].punch1:flipH()
    self.classes[CLOSE_RANGE].punch2:flipH()
    self.classes[CLOSE_RANGE].punch3:flipH()
    self.classes[NO_RANGE].hitstun:flipH()
    self.classes[NO_RANGE].idle:flipH()
  elseif direction == 'left' and not self.flip then
    self.flip = true
    self.classes[CLOSE_RANGE].running:flipH()
    self.classes[CLOSE_RANGE].punch1:flipH()
    self.classes[CLOSE_RANGE].punch2:flipH()
    self.classes[CLOSE_RANGE].punch3:flipH()
    self.classes[NO_RANGE].hitstun:flipH()
    self.classes[NO_RANGE].idle:flipH()
  end
end

function Player:move_with_collision(dx, dy)
  local direction
  if dx < 0 then
    direction = 'left'
  else
    direction = 'right'
  end

  local pushback = 0 --Player Pushback
  for shape, delta in pairs(HC.collisions(self.hitbox)) do
    if shape.class == 'player' then
      pushback = pushback + delta.x
    end
  end
  local pdx = 0
  if pushback > 0 then
    pdx = 0.5
  elseif pushback < 0 then
    pdx = -0.5
  end

  self.hitbox:move(dx+pdx,dy) --Move Hitbox

  local moveBlock = false --Check Hard Collisions
  for shape, delta in pairs(HC.collisions(self.hitbox)) do
    if shape.class == 'enemy' or shape.class == 'wall' then
      moveBlock = true
    end
  end

  if not moveBlock then --Then either move player
    self.pos.x = self.pos.x + dx + pdx
    self.currClass = self.classes[CLOSE_RANGE]
    self.animation = self.currClass.running
  else
    self.hitbox:move(-dx-pdx,-dy) --Or move hitbox back
    self.currClass = self.classes[NO_RANGE]
    self.animation = self.currClass.idle
  end
  self:faceDirection(direction)
end

function Player:chargeUp()
  if self.state ~= 'charge' then
    self.state = 'charge'
    self.currClass = self.classes[NO_RANGE]
    self.animation = self.currClass.hitstun
  end
  self.charge = self.charge + 5
end

function Player:canMove()
  if self.lag <= 0 and (self.state == 'moveTowards' or self.state == 'moveAway' or self.state == 'idle') then
    return true
  else
    return false
  end
end
