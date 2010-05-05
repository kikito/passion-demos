Scenery = class('Scenery', passion.physics.Actor)
function Scenery:initialize(...)
  super.initialize(self)
  self:setBody(passion.physics.getGround())
  
  self.shape = self:newPolygonShape(...)
  self.shape:setCategory(CAT_SCENERY)
  self.shape:setMask(CAT_SCENERY)
  self.shape:setGroupIndex(GR_SCENERY)
  --self.shape:setFriction(0) uncomment for ice

  self.color = passion.colors.white
end
function Scenery:touches(other, contact)
  if(instanceOf(Player, other)) then
    self.color = passion.colors.green
  end
end
function Scenery:stopsTouching(other, contact)
  if(instanceOf(Player, other)) then
    self.color = passion.colors.white
  end
end
function Scenery:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.polygon('line', self.shape:getPoints())
end
