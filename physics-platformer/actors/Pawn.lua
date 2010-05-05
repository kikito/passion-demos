
require('passion.init')
require('actors/Scenery')
require('actors/Categories')

Pawn = class('Pawn', passion.physics.Actor)
function Pawn:initialize(x, y, width, height, color)
  super.initialize(self)
  
  self.width = width
  self.width_2 = width/2.0
  self.height = height
  self.color = color

  self:newBody(x,y)
  self:setAllowSleeping(false)
  
  local feet_height = math.min(width/2.0, height/2.0)

  -- x, y will be located on the lower-center corner of the shapes (instead of centered on them). That's why the height/2
  self.shape = self:newRectangleShape(0, -height/2.0-feet_height/2, width, height-width/2.0)
  self.shape:setCategory(CAT_PLAYER_BODY)
  --self.shape:setGroupIndex(GR_PLAYER)
  self.shape:setMask(CAT_SCENERY, CAT_PLAYER_FEET)

  --feet are an inverted triangle with the lower corner in 0,0
  self.feet = self:newPolygonShape(2,0, -2,0, -self.width_2,-feet_height, self.width_2,-feet_height)
  self.shape:setCategory(CAT_PLAYER_FEET)
  --self.shape:setGroupIndex(GR_FEET) --feet don't collide with body
  self.shape:setMask(CAT_PLAYER_BODY)

  self:setMassFromShapes()
  local m, i = self:getMass()
  self:setMass(x,y,m,math.huge) --set inertia to math.huge (body hardly rotates)

  self.contacts = {}
  self.contact_count = 0
  
  self:observe('keypressed_t', 'dump')
  
  self:gotoState('Air')
end

function Pawn:dump()
  passion.dumpTable(self)
end

function Pawn:update()
  if(self.contact_count == 0) then self:gotoState('Air') end
  
  self:setAngle(0) -- FIXME remove this
  vx, vy = self:getLinearVelocity()
  if(self:wantLeft()) then
    self:setLinearVelocity(-100, vy)
  elseif(self:wantRight()) then
    self:setLinearVelocity(100, vy)
  end
  
  if(self:wantJump()) then self:jump() end

end

function Pawn:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.polygon('line', self.shape:getPoints())
  love.graphics.polygon('line', self.feet:getPoints())

  for _,contact in pairs(self.contacts) do
    self:drawPoint(contact.x, contact.y)
    love.graphics.line(contact.x, contact.y, contact.x+contact.nx, contact.y+contact.ny)
  end
end

function Pawn:drawPoint(x,y)
  love.graphics.circle('line', x, y, 3, 10)
end

function Pawn:wantLeft()
  error("Override Pawn:wantLeft() to a function that returns true when the pawn wants to move left")
end

function Pawn:wantRight()
  error("Override Pawn:wantLeft() to a function that returns true when the pawn wants to move right")
end

function Pawn:wantJump()
  error("Override Pawn:wantJump() to a function that returns true when the pawn wants to jump")
end

function Pawn:touches(other, contact)
  if(instanceOf(Scenery, other)) then

    local cx, cy = contact:getPosition()
    local x, y = self:getPosition()
    local nx, ny = contact:getNormal()

    local maxStep = 2

    local xd = cx - x
    local yd = cy - y
    if( (xd*xd + yd*yd) > maxStep*maxStep) then -- if the contact step is near the feet
      self:gotoState('Ground')
      self.contacts[other]= {x=cx, y=cy, nx=nx, ny=ny}
      self.contact_count = self.contact_count + 1
    end
  end
end

function Pawn:stopsTouching(other, contact)
  if(instanceOf(Scenery, other)) then
    if(self.contacts[other]~=nil) then
      self.contacts[other]= nil
      self.contact_count = self.contact_count - 1
    end
  end
end


function Pawn:jump() end -- do nothing

Pawn:addState('Ground')
function Pawn.states.Ground:jump()
  local vx, vy = self:getLinearVelocity()
  self:setLinearVelocity(vx, -250)
  self:gotoState('Air')
end

Pawn:addState('Air')



