require('passion.init')


Piano = class('Piano', passion.gui.Pannel)

-- key stuff
local Key = class('Key', passion.gui.Button)

local notes = {
  'O1C', 'O1C#', 'O1D', 'O1D#', 'O1E', 'O1F', 'O1F#', 'O1G', 'O1G#', 'O1A', 'O1A#', 'O1B',
  'O2C', 'O2C#', 'O2D', 'O2D#', 'O2E', 'O2F', 'O2F#', 'O2G', 'O2G#', 'O2A', 'O2A#', 'O2B',
  'O3C'
}

-- make sounds['01C'] = 'sounds/01C.mp3', etc
local sources = {}
for _,note in ipairs(notes) do sources[note] = 'sounds/' .. note .. '.mp3' end

Key:load({
  images = { image = 'images/pianoKeys.png' },
  sources = sources
})

function Key:initialize(piano, name, x, y, quadX, quadY, width, height )
  super.initialize(self, {width=width, height=height, x=x, y=y, focus=false})
  self.name = name
  self.source = Key.sources[name]
  self.quadX = quadX
  self.quadY = quadY
  self.piano = piano
  self:calculateQuads()
end

function Key:calculateQuads()
  local width, height = self:getWidth(), self:getHeight()
  local rwidth, rheight = Key.images.image:getWidth(), Key.images.image:getHeight()
  
  self.releasedQuad = love.graphics.newQuad( self.quadX, self.quadY, width, height, rwidth, rheight)
  self.pressedQuad = love.graphics.newQuad( self.quadX, self.quadY+256, width, height, rwidth, rheight)
end

function Key:draw()
  local x,y= self:getPosition()
  love.graphics.drawq(Key.images.image, self.releasedQuad, x, y)
end

function Key.states.Pressed:draw()
  local x,y= self:getPosition()
  love.graphics.drawq(Key.images.image, self.pressedQuad, x, y)
end

function Key:onPress()
  love.audio.stop(self.source)
  love.audio.play(self.source)
end
function Key:onRelease()
  love.audio.stop(self.source)
end

function Key:destroy()
  super.destroy(self)
end

--Lkey stuff

local LKey = class('LKey', Key) -- defined later, too

function LKey:initialize(piano, name, x, y, quadX, quadY, width, height, topX, topWidth, topHeight )
  self.topX = topX
  self.topWidth = topWidth
  self.topHeight = topHeight
  super.initialize(self, piano, name, x, y, quadX, quadY, width, height)
end

function LKey:calculateQuads()
  local x, y = self.quadX, self.quadY
  local width, height = self:getWidth(), self:getHeight()
  local rwidth, rheight = Key.images.image:getWidth(), Key.images.image:getHeight()
  local twidth, theight = self.topWidth, self.topHeight
  local topX = self.topX

  self.topReleasedQuad = love.graphics.newQuad( x+topX, y, twidth, theight, rwidth, rheight)
  self.releasedQuad = love.graphics.newQuad( x, y+theight, width, height-theight, rwidth, rheight)

  self.topPressedQuad = love.graphics.newQuad( x+topX, y+256, twidth, theight, rwidth, rheight)
  self.pressedQuad = love.graphics.newQuad( x, y+theight+256, width, height-theight, rwidth, rheight)
end

function LKey:draw()
  local x,y = self:getPosition()
  love.graphics.drawq(Key.images.image, self.topReleasedQuad, x+self.topX, y)
  love.graphics.drawq(Key.images.image, self.releasedQuad, x, y+self.topHeight)
end

function LKey.states.Pressed:draw()
  local x,y = self:getPosition()
  love.graphics.drawq(Key.images.image, self.topPressedQuad, x+self.topX, y)
  love.graphics.drawq(Key.images.image, self.pressedQuad, x, y+self.topHeight)
end

function LKey:checkPoint(mx, my)
  local x, y = self:getPosition()
  local width = self:getWidth()
  local height = self:getHeight()
  
  local twidth, theight = self.topWidth, self.topHeight
  local topX = self.topX
  
  if(mx < x + topX or mx > x+twidth+topX or my < y or my > y + theight) and
    (mx < x or mx > x+width or my < y+theight or my > y+height) then 
    return false
  end
  
  return true
end


-- a piano is a group of keys
function Piano:initialize(x,y)
  super.initialize(self, { 
    x=x, y=y, width=640, height=200, cornerRadius=7, padding={9,9,12,6},
    backgroundColor = passion.black, borderColor=passion.white, borderWidth=2
  })
  
  local owidth=291

  --                            name             x,y   cx,cy   w,h   topx, tw,th
  self:addChild( LKey:new(self, 'O1C' ,          0,0,   0,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O1C#',         26,0,  26,0,  22,95) )
  self:addChild( LKey:new(self, 'O1D' ,         41,0,  41,0,  42,175,  7,  29,95) )
  self:addChild(  Key:new(self, 'O1D#',         77,0,  77,0,  22,95) )
  self:addChild( LKey:new(self, 'O1E' ,         83,0,  83,0,  42,175, 16,  26,95) )
  self:addChild( LKey:new(self, 'O1F' ,        125,0, 125,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O1F#',        151,0, 151,0,  22,95) )
  self:addChild( LKey:new(self, 'O1G' ,        166,0, 166,0,  42,175,  7,  24,95) )
  self:addChild(  Key:new(self, 'O1G#',        197,0, 197,0,  23,95) )
  self:addChild( LKey:new(self, 'O1A' ,        208,0, 208,0,  41,175, 12,  25,95) )
  self:addChild(  Key:new(self, 'O1A#',        245,0, 245,0,  22,95) )
  self:addChild( LKey:new(self, 'O1B' ,        249,0, 249,0,  42,175, 18,  24,95) )
  self:addChild( LKey:new(self, 'O2C' ,   owidth+0,0,   0,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O2C#',  owidth+26,0,  26,0,  22,95) )
  self:addChild( LKey:new(self, 'O2D' ,  owidth+41,0,  41,0,  42,175,  7,  29,95) )
  self:addChild(  Key:new(self, 'O2D#',  owidth+77,0,  77,0,  22,95) )
  self:addChild( LKey:new(self, 'O2E' ,  owidth+83,0,  83,0,  42,175, 16,  26,95) )
  self:addChild( LKey:new(self, 'O2F' , owidth+125,0, 125,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O2F#', owidth+151,0, 151,0,  22,95) )
  self:addChild( LKey:new(self, 'O2G' , owidth+166,0, 166,0,  42,175,  7,  24,95) )
  self:addChild(  Key:new(self, 'O2G#', owidth+197,0, 197,0,  23,95) )
  self:addChild( LKey:new(self, 'O2A' , owidth+208,0, 208,0,  41,175, 12,  25,95) )
  self:addChild(  Key:new(self, 'O2A#', owidth+245,0, 245,0,  22,95) )
  self:addChild( LKey:new(self, 'O2B' , owidth+249,0, 249,0,  42,175, 18,  24,95) )
  self:addChild(  Key:new(self, 'O3C' , owidth+291,0, 291,0,  40,175) )

end



