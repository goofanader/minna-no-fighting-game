local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Enemy = Class{
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

function Enemy:init(pos, imagefile)
  self.img = love.graphics.newImage(imagefile)
  self.pos = pos
  self.hitbox = HC.rectangle(pos.x,pos.y,SPRITE_SIZE,SPRITE_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'enemy'
  self.alive = true
  local g = anim8.newGrid(SPRITE_SIZE,SPRITE_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch1 = anim8.newAnimation(g('1-8',2),0.05,'pauseAtEnd')
  self.punch2 = anim8.newAnimation(g('1-8',3),0.05,'pauseAtEnd')
  self.punch3 = anim8.newAnimation(g('1-8',4,'1-8',5,1,6),0.05,'pauseAtEnd')
  self.hitstun = anim8.newAnimation(g('2-3',6),0.1)
  self.idle = anim8.newAnimation(g('4-8',6,'1-7',7),0.1)
  self.animation = self.idle
  self.flip = false
  self.state = "idle"
  self.timer = love.math.random(2)+3
end

function Enemy:update(dt)

  self.animation:update(dt)

  self.timer = self.timer - dt
  if self.timer < 0 then
    self.timer = love.math.random(2)+3
    
    --Find Nearest Player
    self.closestPlayer = nil
    local distance = 100000000
    for i=1,numberOfPlayers do
      if math.abs(players[i].pos.x - self.pos.x) < distance then
        self.closestPlayer = players[i]
        distance = math.abs(self.closestPlayer.pos.x - self.pos.x)
      end
    end
    
    if love.math.random() > 0.5 then
      self.state = "move"
    else
      self.state = "idle"
      self.animation = self.idle
    end
  end

  if self.state == "move" then
    if self.closestPlayer then
      local direction
      local dx
      if self.closestPlayer.pos.x < self.pos.x then
        self.hitbox:move(-1,0)
        direction = 'left'
        dx = -1
      else
        self.hitbox:move(1,0)
        direction = 'right'
        dx = 1
      end
      local moveBlock = false
      for i=1,numberOfPlayers do
        if self.hitbox:collidesWith(players[i].hitbox) then
          moveBlock = true
        end
      end
      if not moveBlock then
        self.pos.x = self.pos.x + dx
        self:faceDirection(direction)
        self.animation = self.running
      else
        self.hitbox:move(-dx,0)
        self.animation = self.idle
      end
      
    else
      self.animation = self.idle
    end
  end
end

function Enemy:draw()
  love.graphics.setShader(Enemy.pixelShader)

  if self.alive then
    self.animation:draw(self.img, self.pos.x, self.pos.y)
  end

  love.graphics.setShader()
  if self.hitbox then
    self.hitbox:draw('line')
  end
  
end

function Enemy:spawn(pos)
  self.alive = true
  self.pos = pos
  self.state = "move"
  self.timer = love.math.random(2)+3
  self.hitbox = HC.rectangle(pos.x,pos.y,SPRITE_SIZE,SPRITE_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'enemy'
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
    self.hitstun:flipH()
    self.idle:flipH()
  elseif direction == 'left' and not self.flip then
    self.flip = true
    self.running:flipH()
    self.punch1:flipH()
    self.punch2:flipH()
    self.hitstun:flipH()
    self.idle:flipH()
  end
end