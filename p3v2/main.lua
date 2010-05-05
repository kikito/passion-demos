-- Example: Avalanche of passion

require('passion.init')
require('Actors/Scenery')
require('Actors/Box')
require('Actors/Player')


function love.load()
  -- Fat lines.
  love.graphics.setLineWidth(2)

  -- Create the world (and the ground)
  passion.newWorld(2000, 2000)

  local touchingCallback = function(object1,object2,contact)
    t1 = object1.touches
    if(type(t1)=='function') then t1(object1, object2, contact) end
    t2 = object2.touches
    if(type(t2)=='function') then t2(object2, object1, contact) end
  end
  
  local stoppedTouchingCallback = function(object1,object2,contact)
    st1 = object1.stopsTouching
    if(type(t1)=='function') then st1(object1, object2, contact) end
    st2 = object2.stopsTouching
    if(type(t2)=='function') then st2(object2, object1, contact) end
  end

  passion.setCallbacks(
    touchingCallback, --the objects start touching
    nil, --the objects continue touching
    stoppedTouchingCallback --the objects stop touching
  )

  -- Set gravity directly on passion
  passion.setGravity(0, 500)

  -- This generates the floor, ceiling and walls
  Box:new(0,600, 800,16)
  Box:new(0,16, 800,16)
  Box:new(0,600-16, 16,600-32)
  Box:new(800-16,600-16, 16,600-32)
  
  -- Some random scenery stuff
  Box:new(100, 600-16-25, 50, 25)
  Scenery:new( 200,550, 300,500, 300,550 )
  Scenery:new( 300,500, 320,480, 380,460, 420,430, 450,450, 410,470 )

  -- This adds the player
  local player = Player:new(300-16, 500-16)

  local stateText = passion.gui.Label:new({x=100, y=100, fontColor=passion.blue, fontSize=30})
  function stateText:update(dt)
    local playerState = player:getCurrentState()
    if(playerState ~= nil) then self:setText(playerState.name) end
  end

end

function love.run()
  passion:run()
end
