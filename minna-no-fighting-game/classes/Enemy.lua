local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Enemy = Class {
  -- shader code from here: https://love2d.org/forums/viewtopic.php?t=32605&p=174896#p171718
  pixelShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
    {
      vec4 pixel = Texel(texture, tc);
      number gray =  0.30 * pixel.r + 0.59 * pixel.g + 0.11 * pixel.b;

      return vec4(vec3(gray, gray, gray), pixel.a);
    }
  ]])
}

local FLINCH_TIME = 0.2 --seconds
local ATTACK_DELAY = 0.3 --seconds

function Enemy:init(pos, imagefile)
  self.ground = pos.y
  self.img = love.graphics.newImage(imagefile)
  local g = anim8.newGrid(SPRITE_SIZE,SPRITE_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch1 = anim8.newAnimation(g('1-8',2),0.02,'pauseAtEnd')
  self.punch2 = anim8.newAnimation(g('1-8',3),0.02,'pauseAtEnd')
  self.punch3 = anim8.newAnimation(g('1-8',4,'1-8',5,1,6),0.02,'pauseAtEnd')
  self.hitstun = anim8.newAnimation(g('2-3',6),0.1)
  self.idle = anim8.newAnimation(g('4-8',6,'1-7',7),0.1)
  self.animation = self.idle
  self.flip = false
end

function Enemy:update(dt)
  if self.alive then
    self.timer = self.timer - dt
    if self.timer < 0 and self.state ~= 'flinch' then
      self.timer = love.math.random(2)+2

      --Find Nearest Player
      self.closestPlayer = nil
      local distance = 100000000
      for i=1,numberOfPlayers do
        if math.abs(players[i].pos.x - self.pos.x) < distance then
          self.closestPlayer = players[i]
          distance = math.abs(self.closestPlayer.pos.x - self.pos.x)
        end
      end

      if love.math.random() > 0.75 then
        if self.state == 'move' then
          self.state = 'idle'
          self.animation = self.idle
        else
          self.state = 'move'
        end
      end
    end
    if self.pos.y < self.ground then
      if self.pos.y + self.vel.y >= self.ground then
        self.hitbox:move(self.vel.x,self.ground-self.pos.y)
        self.pos.y = self.ground
        self.vel = vector(0,0)
        self.animation = self.idle
      else
        self.pos = self.pos + self.vel
        self.hitbox:move(self.vel.x,self.vel.y)
        self.vel = self.vel + vector(0,0.5) --acceleration to ground
        self.animation = self.hitstun
      end
      
    else
    
      if self.state == "move" then
        if self.closestPlayer then
          if math.abs(self.closestPlayer.pos.x - self.pos.x) > SPRITE_SIZE+1 then
            if self.closestPlayer.pos.x < self.pos.x then
              self:move_with_collision(-1,0)
            else
              self:move_with_collision(1,0)
            end
          else
            if love.math.random() > 0.95 then --Chance to Attack when in range
              self.state = 'attack'
              self.combo = 1
              self.animation = self.punch1
              self.attackBoxFlag = false
              self.attackLag = false
              self.animation:gotoFrame(1)
              self.animation:resume()
            else
              self.animation = self.idle
            end
          end
          
        else
          self.animation = self.idle
        end
      elseif self.state == 'attack' then
        if self.lag <= 0 then
          if self.attackLag then -- What happens when finishes a punch
            if self.combo == 2 then
              self.animation = self.punch2
            elseif self.combo == 3 then
              self.animation = self.punch3
            elseif self.combo == 1 then
              self.state = 'move'
            end
            self.animation:gotoFrame(1)
            self.animation:resume()
            self.attackLag = false
          else
            if self.combo == 1 then -- Contents of each punch
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
                self.lag = ATTACK_DELAY
                self.attackLag = true
                self.combo = 2
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
                self.lag = ATTACK_DELAY
                self.attackLag = true
                self.combo = 3
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
                self.lag = 2*ATTACK_DELAY
                self.attackLag = true
                self.combo = 1
              end
            end
          end
        end
        
        if self.attackBoxFlag then -- Punch Hitbox Detection Stuff
          for shape, delta in pairs(HC.collisions(self.punchbox)) do
            if shape.class == 'player' then
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
              if self.flip then --TODO: Fix knockback here OR put it in the hit() function
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
      self.timer = 0
      self.state = 'move'
    end

    self.animation:update(dt)
  end
end

function Enemy:draw()
  love.graphics.setShader(Enemy.pixelShader)

  if self.alive then
    self.animation:draw(self.img, self.pos.x, self.pos.y)
  end

  love.graphics.setShader()
  if isDrawingHitbox and self.hitbox then
    self.hitbox:draw('line')
  end

  if isDrawingHitbox and self.punchbox then
    love.graphics.setColor(0,255,0)
    self.punchbox:draw('line')
    love.graphics.setColor(255,255,255)
  end

end

function Enemy:spawn(pos)
  self.alive = true
  self.pos = pos
  self.vel = vector(0,0)
  self.state = "move"
  self.timer = 0.5
  self.hitbox = HC.rectangle(pos.x,pos.y,SPRITE_SIZE,SPRITE_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'enemy'
  self.lag = 0
  self.hp = 12
end

function Enemy:kill()
  self.alive = false
  HC.remove(self.hitbox)
  self.hitbox = nil
end

function Enemy:faceDirection(direction)
  if direction == 'right' and self.flip then
    self.flip = false
    self.running:flipH()
    self.punch1:flipH()
    self.punch2:flipH()
    self.punch3:flipH()
    self.hitstun:flipH()
    self.idle:flipH()
  elseif direction == 'left' and not self.flip then
    self.flip = true
    self.running:flipH()
    self.punch1:flipH()
    self.punch2:flipH()
    self.punch3:flipH()
    self.hitstun:flipH()
    self.idle:flipH()
  end
end

function Enemy:move_with_collision(dx, dy)
  local direction
  if dx < 0 then
    direction = 'left'
  else
    direction = 'right'
  end

  local pushback = 0 --Enemy Pushback
  for shape, delta in pairs(HC.collisions(self.hitbox)) do
    if shape.class == 'enemy' then
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
  for i=1,numberOfPlayers do
    if self.hitbox:collidesWith(players[i].hitbox) then
      moveBlock = true
    end
  end

  if not moveBlock then --Then either move enemy
    self.pos.x = self.pos.x + dx + pdx
    self.animation = self.running
  else
    self.hitbox:move(-dx-pdx,-dy) --Or move hitbox back
    self.animation = self.idle
  end
  self:faceDirection(direction)
end

function Enemy:hit(damage)
  self.hp = self.hp - damage
  if self.hp <= 0 then
    self:kill()
  else
    self.state = 'flinch'
    self.animation = self.hitstun
    self.lag = FLINCH_TIME
  end
end
