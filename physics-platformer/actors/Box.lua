
require('passion.init')
require('actors/Scenery')
require('actors/Categories')

Box = class('Box', Scenery)
function Box:initialize(x, y, width, height)
  super.initialize(self, x, y, x, y-height, x+width, y-height, x+width, y)
end
