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
  self.alive = true
  local g = anim8.newGrid(SPRITE_SIZE,SPRITE_SIZE,self.img:getWidth(),self.img:getHeight())
  self.running = anim8.newAnimation(g('1-8',1),0.1)
  self.punch = anim8.newAnimation(g('1-8',2),0.1)
  self.hitstun = anim8.newAnimation(g('1-2',3),0.1)
  self.idle = anim8.newAnimation(g('3-8',3,'1-6',4),0.1)
  self.animation = self.running
  --self.animation:flipH()
end

function Enemy:update(dt)
  self.animation:update(dt)
  if self.pos <= WINDOW_WIDTH then
    self.pos = self.pos + 1
  else
    self.pos = -25
  end

end

function Enemy:draw()
  love.graphics.setShader(Enemy.pixelShader)

  if self.alive then
    self.animation:draw(self.img, self.pos, HORIZONTAL_PLANE)
  end

  love.graphics.setShader()
end

function Enemy:spawn(pos)
  self.alive = true
end

function Enemy:kill()
  self.alive = false
end
