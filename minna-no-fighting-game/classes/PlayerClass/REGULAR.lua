local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/PlayerClass/PlayerClass"
RegularPlayerClass = Class {__includes = PlayerClass}

function RegularPlayerClass:init(imageLocation)
  PlayerClass.init(self, imageLocation, REGULAR_CLASS, NO_RANGE)

  self.front = anim8.newAnimation(self.grid(1,1),0.1)
  self.hitstun = anim8.newAnimation(self.grid('2-3', 1), 0.1)
  self.shield = anim8.newAnimation(self.grid(4, 1), 0.1)
  self.idle = anim8.newAnimation(self.grid('5-8', 1, '1-2', 2), 0.2)
end
