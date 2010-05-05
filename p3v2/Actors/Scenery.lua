
require('passion.init')

Scenery = class('Scenery',passion.ActorWithBody)
function Scenery:initialize(...)
  super.initialize(self)
  self:setBody(passion:getGround())
  
  self.shape = self:newPolygonShape(...)
  self.shape:setCategory(CAT_SCENERY)
  self.shape:setMask(CAT_SCENERY)
  --self.shape:setGroupIndex(GR_SCENERY) --scenery doesn't collide with itself
  --self.shape:setFriction(0) uncomment for ice

  self.color = passion.white
end
function Scenery:touches(other, contact)
  if(instanceOf(Player, other)) then
    self.color = passion.green
  end
end
function Scenery:stopsTouching(other, contact)
  if(instanceOf(Player, other)) then
    self.color = passion.white
  end
end
function Scenery:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.polygon('line', self.shape:getPoints())
end
