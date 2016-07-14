local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/BossClasses/Boss"
AndrewLee = Class {
  __includes = Boss,
  slideSound = love.sound.newSoundData(BOSSES_FOLDER .. "/andrew_lee/sliding_sound.wav")
}

local HORIZ_SPEED = 1
local VERT_SPEED = 0.5
local SPECIAL_COOLDOWN = 5 --seconds
local SUMMON_COOLDOWN = 5 --seconds
local SLIDER_COOLDOWN = 0.25
local SLIDER_SPEED = 15
local SLIDER_SCALE = 0.75 --How big the images are
local SLIDER_DAMAGE = 4

function AndrewLee:init(minionCount)
  local HP = 200*minionCount
  local name = 'Omega Andrew Lee'
  local monologue = 'Hey there!'
  Boss.init(self, HP, minionCount, name, monologue, BOSSES_FOLDER .. "/andrew_lee/Trammell Starks - Good Times.mp3", SUBWAY)
  self.idle = love.graphics.newImage(BOSSES_FOLDER .. '/andrew_lee/andrew_lee_idle.png')
  self.hand = love.graphics.newImage(BOSSES_FOLDER .. '/andrew_lee/andrew_lee_idle_hand.png')
  self.sliderpics = {}
  for i=1,9 do
    self.sliderpics[i] = love.graphics.newImage(BOSSES_FOLDER .. '/andrew_lee/slidingImages/' .. i .. '.jpg')
  end
  self.sliders = {}
  self.imageTrail = love.graphics.newImage(BOSSES_FOLDER .. '/andrew_lee/imageTrail.png')

  self.frame = self.idle
  self.flip = 1
end

function AndrewLee:spawn(pos)
  self.pos = pos
  self.alive = true
  self.spawned = true
  self.hitbox = HC.rectangle(pos.x-BOSS_SIZE/2,pos.y,BOSS_SIZE,BOSS_SIZE)
  self.hitbox.owner = self
  self.hitbox.class = 'boss'
  self.vel = vector(-HORIZ_SPEED,VERT_SPEED)
  self.summonTimer = 0 --seconds
  self.specialTimer = SPECIAL_COOLDOWN*2 --seconds
  self.sliderTimer = 0
  self.lag = 0
end

function AndrewLee:drawStageFG()
  Boss.drawStageFG(self)

  for index, slider in ipairs(self.sliders) do
    love.graphics.draw(slider.img,slider.pos.x,slider.pos.y,0,SLIDER_SCALE,SLIDER_SCALE)
    local trailPos
    local scale
    if slider.vel.x > 0 then
      trailPos = slider.pos
      scale = slider.img:getHeight()/self.imageTrail:getWidth()*SLIDER_SCALE
    elseif slider.vel.x < 0 then
      trailPos = slider.pos + vector(slider.img:getWidth(),slider.img:getHeight())*SLIDER_SCALE
      scale = slider.img:getHeight()/self.imageTrail:getWidth()*SLIDER_SCALE
    elseif slider.vel.y > 0 then
      trailPos = slider.pos + vector(1,0)*slider.img:getWidth()*SLIDER_SCALE
      scale = slider.img:getWidth()/self.imageTrail:getWidth()*SLIDER_SCALE
    else
      trailPos = slider.pos + vector(0,1)*slider.img:getHeight()*SLIDER_SCALE
      scale = slider.img:getWidth()/self.imageTrail:getWidth()*SLIDER_SCALE
    end
    love.graphics.draw(self.imageTrail,trailPos.x,trailPos.y,slider.vel:angleTo()+math.pi/2,scale,0.5)
    if isDrawingHitbox then
      love.graphics.setColor(0,0,255)
      slider.hitbox:draw('line')
      love.graphics.setColor(255,255,255)
    end
  end
end

function AndrewLee:draw()
  Boss.draw(self)
  if self.alive then
    love.graphics.draw(self.frame,self.pos.x-self.flip*BOSS_SIZE,self.pos.y,0,self.flip,1)
  end
  if isDrawingHitbox and self.hitbox then
    self.hitbox:draw('line')
    love.graphics.print(self.hp,self.pos.x,self.pos.y+BOSS_SIZE)
  end
end

function AndrewLee:update(dt)
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
        self.frame = self.hand
      elseif self.summonTimer <= 0 then
        self:summonMinions()
        self.summonTimer = love.math.random(SUMMON_COOLDOWN)+SUMMON_COOLDOWN
        self.lag = 1.5 --seconds
        self.frame = self.hand
      else
        self:move()
        self.frame = self.idle
      end
    end
  end

  for index, slider in ipairs(self.sliders) do --Remove sliders when they leave the screen
    slider.pos = slider.pos + slider.vel
    slider.hitbox:move(slider.vel.x,slider.vel.y)

    for shape, delta in pairs(HC.collisions(slider.hitbox)) do
      if shape.class == 'player' then
        local alreadyHit = false
        if slider.targetsHit then
          for i,target in ipairs(slider.targetsHit) do
            if target == shape.owner then
              alreadyHit = true
            end
          end
        end
        if not alreadyHit then
          shape.owner:hit(SLIDER_DAMAGE)
          --TODO: Knockback here OR put it in the hit() function
          table.insert(slider.targetsHit,shape.owner)
        end
      end
    end

    local trailLength = self.imageTrail:getHeight()
    if slider.vel.x > 0 then
      if slider.pos.x > ORIG_WIDTH+slider.img:getWidth()+trailLength then
        HC.remove(slider.hitbox)
        table.remove(self.sliders,index)
      end
    elseif slider.vel.x < 0 then
      if slider.pos.x < -(slider.img:getWidth()+trailLength) then
        HC.remove(slider.hitbox)
        table.remove(self.sliders,index)
      end
    elseif slider.vel.y > 0 then
      if slider.pos.y > ORIG_HEIGHT+slider.img:getHeight()+trailLength then
        HC.remove(slider.hitbox)
        table.remove(self.sliders,index)
      end
    elseif slider.pos.y < -(slider.img:getHeight()+trailLength) then
      HC.remove(slider.hitbox)
      table.remove(self.sliders,index)
    end
  end


end

function AndrewLee:specialAttack(dt)
  self.sliderTimer = self.sliderTimer - dt

  if self.sliderTimer <= 0 then
    local slider = {}
    local rando = love.math.random(9)
    slider.img = self.sliderpics[rando]
    local width = slider.img:getWidth()
    local height = slider.img:getHeight()
    rando = love.math.random(10)
    if rando <= 4 then --from above screen
      slider.pos = vector(love.math.random(ORIG_WIDTH-width/2),-height)
      slider.vel = vector(0,SLIDER_SPEED)
    elseif rando <= 8 then --from below screen
      slider.pos = vector(love.math.random(ORIG_WIDTH-width/2),ORIG_HEIGHT+height)
      slider.vel = vector(0,-SLIDER_SPEED)
    elseif rando == 9 then --from left of screen
      slider.pos = vector(-width,ORIG_HEIGHT/2-height/2)
      slider.vel = vector(SLIDER_SPEED,0)
    else --from right of screen
      slider.pos = vector(ORIG_WIDTH+width,ORIG_HEIGHT/2-height/2)
      slider.vel = vector(-SLIDER_SPEED,0)
    end
    slider.hitbox = HC.rectangle(slider.pos.x,slider.pos.y,width*SLIDER_SCALE,height*SLIDER_SCALE)
    slider.hitbox.class = 'projectile'
    slider.targetsHit = {}
    table.insert(self.sliders,slider)
    self.sliderTimer = love.math.random()*SLIDER_COOLDOWN + SLIDER_COOLDOWN

    local sound = love.audio.newSource(AndrewLee.slideSound, "static")
    sound:setVolume(.6)
    sound:play()
  end

  if self.specialTimer < -(5 + 5*self.hp/self.maxHP) then
    self.lag = 1 --seconds
    self.specialTimer = love.math.random(SPECIAL_COOLDOWN)+SPECIAL_COOLDOWN
  end
end

function AndrewLee:move()
  local DIST_FROM_EDGE = 50
  local FLOAT_HEIGHT = 20

  self.pos = self.pos + self.vel
  self.hitbox:move(self.vel.x,self.vel.y)
  if self.pos.x < DIST_FROM_EDGE-BOSS_SIZE/2 then
    self.vel.x = HORIZ_SPEED
    self:faceDirection('right')
  elseif self.pos.x > ORIG_WIDTH-DIST_FROM_EDGE-BOSS_SIZE/2 then
    self.vel.x = -HORIZ_SPEED
    self:faceDirection('left')
  end

  if self.pos.y >= Y_POS then
    self.vel.y = -VERT_SPEED
  elseif self.pos.y < Y_POS - FLOAT_HEIGHT then
    self.vel.y = VERT_SPEED
  end

end

function AndrewLee:faceDirection(direction)
  if direction == 'right' and self.flip == 1 then
    self.flip = -1
  elseif direction == 'left' and self.flip == -1 then
    self.flip = 1
  end
end
