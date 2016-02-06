local Class = require "libraries/hump.class"
local anim8 = require "libraries/anim8"

require "classes/PlayerClass/PlayerClass"
AnimalPlayerClass = Class {__includes = PlayerClass}

function AnimalPlayerClass:init(imageLocation)
  PlayerClass.init(self, imageLocation, ANIMAL_CLASS, CLOSE_RANGE)

  self.running = anim8.newAnimation(self.grid('1-8',1), 0.1)
  self.punch1 = anim8.newAnimation(self.grid('1-7', 2), 0.02, 'pauseAtEnd')
  self.punch2 = anim8.newAnimation(self.grid('1-8', 3), 0.02, 'pauseAtEnd')
  self.punch3 = anim8.newAnimation(self.grid('4-5', 4, '4-8', 5), 0.02, 'pauseAtEnd')

  self.damageValues = {punch1 = 3, punch2 = 4, punch3 = 5}
end
