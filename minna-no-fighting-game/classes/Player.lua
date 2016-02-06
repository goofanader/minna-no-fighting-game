local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/PlayerClass/ANIMAL"
require "classes/PlayerClass/REGULAR"

Player = Class{
  runSound = love.sound.newSoundData(SOUNDS_FOLDER .. "/step_full.wav"),
  punch1SFX = love.sound.newSoundData(SOUNDS_FOLDER .. "/punch1.wav"),
  punch2SFX = love.sound.newSoundData(SOUNDS_FOLDER .. "/punch2.wav"),
  punch3SFX = love.sound.newSoundData(SOUNDS_FOLDER .. "/punch3.wav"),
  gotHitSFX = love.sound.newSoundData(SOUNDS_FOLDER .. "/got_hit.wav")
}

local BUTTON_DELAY = 0.1 --seconds
local FLINCH_TIME = 0.2 --seconds

function Player:playSound(sound, isRepeating, volume)
  local newSound = love.audio.newSource(sound, "static")
  local vol = volume or 1.0
  local isLooping = isRepeating ~= nil and isRepeating or false

  newSound:setVolume(vol)
  newSound:setLooping(isLooping)
  newSound:play()

  if isLooping then return newSound else return false end
end

function Player:init(pos, imagefilesLocation, button, name, id)
  self.classes = self:getClasses(imagefilesLocation)
  self.currClass = self.classes[NO_RANGE]
  self.animation = self.currClass.idle
  self.pos = pos
  self.button = button
  self.name = name
  self.id = id
  self.lag = 0
  --self:spawn(pos)

  self.runningSound = self:playSound(Player.runSound, true)
  self.runningSound:stop()
  self.runningSound:rewind()

  self.hitSound = self:playSound(Player.gotHitSFX, true)
  self.hitSound:stop()
  print(inspect(self.hitSound))
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

function Player:isButtonDown()
  if self.button.type == KEYBOARD then
    -- handle keyboard is down
    return love.keyboard.isDown(self.button.button)
  else
    -- handle joystick button is down
    return self.button.joystick:isDown(self.button.button)
  end
end

function Player:update(dt)

  if self.alive then
    --Button Press Actions
    if self:isButtonDown() then
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

          if self.runningSound:isPlaying() then
            self.runningSound:stop()
            self.runningSound:rewind()
          end
          if self.hitSound:isPlaying() then
            self.hitSound:stop()
          end
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
              self:playSound(Player.punch1SFX)
            elseif self.combo == 1 then
              self.currClass = self.classes[CLOSE_RANGE]
              self.animation = self.currClass.punch2
              self.combo = 2
              self:playSound(Player.punch2SFX)
            else
              self.currClass = self.classes[CLOSE_RANGE]
              self.animation = self.currClass.punch3
              self.combo = 3
              self:playSound(Player.punch3SFX)
            end
            self.attackBoxFlag = false
            self.animation:gotoFrame(1)
            self.animation:resume()

            if self.runningSound:isPlaying() then
              self.runningSound:stop()
              self.runningSound:rewind()
            end
            if self.hitSound:isPlaying() then
              self.hitSound:stop()
            end
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

          if self.runningSound:isPlaying() then
            self.runningSound:stop()
            self.runningSound:rewind()
          end
          if self.hitSound:isPlaying() then
            self.hitSound:stop()
          end
        end
      end
    end

    --Act on Player State
    if self.state == 'moveTowards' then -- Not doing anything

      --Find Nearest Enemy
      local distance = 1000000
      if CurrentBoss then
        self.closestEnemy = CurrentBoss
        distance = math.abs(CurrentBoss.pos.x - self.pos.x)
      end

      for i=1,numberOfEnemies do
        if enemies[i] then
          if enemies[i].alive then
            if math.abs(enemies[i].pos.x - self.pos.x) < distance then
              self.closestEnemy = enemies[i]
              distance = math.abs(self.closestEnemy.pos.x - self.pos.x)
            end
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

        if self.runningSound:isPlaying() then
          self.runningSound:stop()
          self.runningSound:rewind()
        end
        if self.hitSound:isPlaying() then
          self.hitSound:stop()
        end
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

        if self.runningSound:isPlaying() then
          self.runningSound:stop()
          self.runningSound:rewind()
        end
        if self.hitSound:isPlaying() then
          self.hitSound:stop()
        end
      end

    elseif self.state == 'attack' then -- Tapping the button, but not too fast
      if self.combo == 1 then
        if self.animation.position >= 2 and not self.attackBoxFlag then -- Frame Number
          if self.flip then
            self.punchbox = HC.rectangle(self.pos.x-5,self.pos.y,5,SPRITE_SIZE)
          else
            self.punchbox = HC.rectangle(self.pos.x+SPRITE_SIZE,self.pos.y,5,SPRITE_SIZE)
          end
          self.punchbox.damage = self.classes[CLOSE_RANGE].damageValues.punch1
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
          self.punchbox.damage = self.classes[CLOSE_RANGE].damageValues.punch2
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
          self.punchbox.damage = self.classes[CLOSE_RANGE].damageValues.punch3
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
          if shape.class == 'enemy' or shape.class == 'boss' then
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
  elseif self.state == 'flinch' then
    self.state = 'idle'
  end

  self.animation:update(dt)

  if self.animation == self.classes[NO_RANGE].hitstun and not self.hitSound:isPlaying() then
    self.hitSound:play()
  elseif self.animation ~= self.classes[NO_RANGE].hitstun and self.hitSound:isPlaying() then
    self.hitSound:stop()
  end
end

function Player:draw()
  self.animation:draw(self.currClass.spritesheet, self.pos.x, self.pos.y)
  --[[if self.charge > 0 then
    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle('fill', self.pos.x, self.pos.y+SPRITE_SIZE+3, self.charge, 3)
    love.graphics.setColor(255,255,255,255)
  end]]
  if isDrawingHitbox and self.hitbox then self.hitbox:draw('line') end

  if isDrawingHitbox and self.punchbox then
    love.graphics.setColor(0,255,0)
    self.punchbox:draw('line')
    love.graphics.setColor(255,255,255)
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
    if shape.class == 'player' or shape.class == 'boss' then
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
    if not self.runningSound:isPlaying() then
      self.runningSound:play()
    end
  else
    self.hitbox:move(-dx-pdx,-dy) --Or move hitbox back
    self.currClass = self.classes[NO_RANGE]
    self.animation = self.currClass.idle

    if self.runningSound:isPlaying() then
      self.runningSound:stop()
      self.runningSound:rewind()
    end
  end
  if self.hitSound:isPlaying() then
    self.hitSound:stop()
  end
  self:faceDirection(direction)
end

function Player:chargeUp()
  if self.state ~= 'charge' then
    self.state = 'charge'
    self.currClass = self.classes[NO_RANGE]
    self.animation = self.currClass.hitstun

    if self.runningSound:isPlaying() then
      self.runningSound:stop()
      self.runningSound:rewind()
    end

    if not self.hitSound:isPlaying() then
      self.hitSound:play()
    end
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

function Player:hit(damage)
  playerHP = playerHP - damage
  if playerHP <= 0 then
    playerHP = 0
    --GAME OVER
  else
    self.state = 'flinch'
    self.currClass = self.classes[NO_RANGE]
    self.animation = self.currClass.hitstun
    self.lag = FLINCH_TIME
  end
end

function Player:selected(bool)
  if bool then
    self.currClass = self.classes[CLOSE_RANGE]
    self.animation = self.currClass.running
    if not self.runningSound:isPlaying() then
      self.runningSound:play()
    end
  else
    self.currClass = self.classes[NO_RANGE]
    self.animation = self.currClass.idle
    if self.runningSound:isPlaying() then
      self.runningSound:stop()
      self.runningSound:rewind()
    end
  end
  if self.hitSound:isPlaying() then
    self.hitSound:stop()
  end
end
