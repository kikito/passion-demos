-- Example: Avalanche of passion

require('passion/init.lua')

Ball = passion.physics.Actor:subclass('Ball') -- hasImage isn't needed here; shown for informational purposes

Ball:load({
  images = {
    big = '/images/big_love_ball.png',
    small = '/images/love_ball.png',
    green = '/images/green_ball.png'
  }
})

function Ball:initialize(image, radius)
  super.initialize(self)
  self.image = image
  self.radius = radius
  self:newBody(math.random(0, 400), -math.random(100, 1500))
  self:newCircleShape(radius)
  self:setMassFromShapes()
end
function Ball:update(dt)
  local x, y = self.body:getPosition()
  if x > 850 or y > 650 then
    self:setPosition(math.random(0, 400), -math.random(100, 1500))
  end
end
function Ball:draw()
  local x, y = self:getPosition()
  local angle = self:getAngle()
  local r = self.radius
  love.graphics.draw(self.image, x,y, angle, 1,1, r+5, r+5)
end


BigBall = Ball:subclass('BigBall')
function BigBall:initialize() super.initialize(self, Ball.images.big, 44) end

SmallBall = Ball:subclass('SmallBall')
function SmallBall:initialize() super.initialize(self, Ball.images.small, 28) end

GreenBall = Ball:subclass('GreenBall')
function GreenBall:initialize() super.initialize(self, Ball.images.green, 31) end

Box = passion.physics.Actor:subclass('Box')
function Box:initialize(ground, offsetX, offsetY)
  super.initialize(self)
  self:setBody(ground)
  self.shape = self:newRectangleShape(offsetX, offsetY, 50, 50)
end
function Box:draw()
  love.graphics.polygon('line', self.shape:getPoints())
end

function love.load()
    -- Fat lines.
    love.graphics.setLineWidth(2)
    
    -- Create the world (and the ground)
    passion.physics.newWorld(2000, 2000)
    
    -- Set gravity directly on passion
    passion.physics.setGravity(0, 50)
    
    -- This generates the terrain.
    for i = 0, 10 do Box:new(passion.physics.getGround(), i*50, i*50+100) end
    
    -- This adds all the balls.
    for i=1,5 do  BigBall:new() end  -- Add 5 big
    for i=1,25 do SmallBall:new() end -- Add 25 pink
    for i=1,25 do GreenBall:new() end -- Add 25 green

end
