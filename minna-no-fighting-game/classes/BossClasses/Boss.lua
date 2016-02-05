local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

Boss = Class {}

function Boss:init(hp)
  self.alive = false
  self.hp = hp
end



function Boss:draw()

end

function Boss:update(dt)

end

function Boss:hit(damage)
  self.hp = self.hp - damage
  if self.hp <= 0 then
    --self:kill()
  end
end
