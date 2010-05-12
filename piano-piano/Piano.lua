require('passion.init')


Piano = class('Piano', passion.gui.Panel)

-- private function

local _resetSource = function(source)
  love.audio.stop(source)
  source:setVolume(1)
end

-- key stuff
local Key = class('Key', passion.gui.Button)

local notes = {
  'O1C', 'O1C#', 'O1D', 'O1D#', 'O1E', 'O1F', 'O1F#', 'O1G', 'O1G#', 'O1A', 'O1A#', 'O1B',
  'O2C', 'O2C#', 'O2D', 'O2D#', 'O2E', 'O2F', 'O2F#', 'O2G', 'O2G#', 'O2A', 'O2A#', 'O2B',
  'O3C'
}

local sources = {}

-- load sounds & images
for _,name in ipairs(notes) do
  sources[name] = passion.audio.getSource('sounds/' .. name .. '.mp3', 'static', 3)
end

local image = passion.graphics.getImage('images/pianoKeys.png')

function Key:initialize(piano, name, key, x, y, quadX, quadY, width, height )
  super.initialize(self, {
    width=width, height=height, x=x, y=y,
    focus=false, borderColor=false, fontColor=passion.colors.green})
  self.name = name
  self.source = sources[name]
  self.quadX = quadX
  self.quadY = quadY
  self.piano = piano
  self:calculateQuads()
  self.key = key
  self:observe('keypressed_' .. key, 'keypressed')
  self:observe('keyreleased_' .. key, 'keyreleased')
  self:setDrawOrder(0)
end

function Key:getText()
  if(self.piano.showKeys == true) then
    return self.key or ''
  end
  return ''
end

function Key:calculateQuads()
  local width, height = self:getWidth(), self:getHeight()

  self.releasedQuad = passion.graphics.newQuad(image, self.quadX, self.quadY, width, height)
  self.pressedQuad = passion.graphics.newQuad(image, self.quadX, self.quadY+256, width, height)
end

function Key:draw()
  passion.graphics.drawq(self.releasedQuad, self:getPosition())
  super.draw(self)
end

function Key:keypressed()
  self:pushState('KeyboardPressed')
end
function Key:keyreleased()
end

function Key:destroy()
  self:stopObserving('keypressed_' .. self.key)
  self:stopObserving('keyreleased_' .. self.key)
  super.destroy(self)
end

-- The KeyboardPressed state handles keyboard interaction. It is not provided by PÄSSION.
local KeyboardPressed = Key:addState('KeyboardPressed')

function KeyboardPressed:enterState()
  self:onPress()
end

function KeyboardPressed:keypressed() end
function KeyboardPressed:keyreleased()
  self:popState('KeyboardPressed')
end

function KeyboardPressed:draw()
  passion.graphics.drawq(self.pressedQuad, self:getPosition())
  super.draw(self)
end

function KeyboardPressed:exitState()
  self:onRelease()
end

-- the Pressed state is directly provided by PÄSSION. It handles mouse interaction
-- it also calls onPress and onRelease
Key.states.Pressed.draw = KeyboardPressed.draw

function Key:onPress()
  self.playingSource = passion.audio.play(self.source)
end

function Key:onRelease()
  if(self.playingSource~=nil) then
    passion.timer.effect(self.playingSource, 0.3, {volume=0}, nil, _resetSource, self.playingSource)
  end
end

--Lkey stuff

local LKey = class('LKey', Key) -- defined later, too

function LKey:initialize(piano, name, key, x, y, quadX, quadY, width, height, topX, topWidth, topHeight )
  self.topX = topX
  self.topWidth = topWidth
  self.topHeight = topHeight
  super.initialize(self, piano, name, key, x, y, quadX, quadY, width, height)
  self:setDrawOrder(1)
end

function LKey:calculateQuads()
  local x, y = self.quadX, self.quadY
  local width, height = self:getWidth(), self:getHeight()
  local twidth, theight = self.topWidth, self.topHeight
  local topX = self.topX

  self.topReleasedQuad = passion.graphics.newQuad( image, x+topX, y, twidth, theight)
  self.releasedQuad = passion.graphics.newQuad( image, x, y+theight, width, height-theight)

  self.topPressedQuad = passion.graphics.newQuad( image, x+topX, y+256, twidth, theight)
  self.pressedQuad = passion.graphics.newQuad( image, x, y+theight+256, width, height-theight)
end

function LKey:draw()
  local x,y = self:getPosition()
  passion.graphics.drawq(self.topReleasedQuad, x+self.topX, y)
  passion.graphics.drawq(self.releasedQuad, x, y+self.topHeight)
  passion.gui.Button.draw(self)
end

function LKey.states.KeyboardPressed:draw()
  local x,y = self:getPosition()
  passion.graphics.drawq(self.topPressedQuad, x+self.topX, y)
  passion.graphics.drawq(self.pressedQuad, x, y+self.topHeight)
  passion.gui.Button.draw(self)
end

LKey.states.Pressed.draw = LKey.states.KeyboardPressed.draw

function LKey:checkPoint(mx, my)
  mx,my = self:getCamera():invert(mx,my)
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
  
  self.showKeys = true
  
  local owidth=291

  --                            name   key          x,y   cx,cy   w,h   topx, tw,th
  self:addChild( LKey:new(self, 'O1C' , 'a',          0,0,   0,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O1C#', 'b',         26,0,  26,0,  22,95) )
  self:addChild( LKey:new(self, 'O1D' , 'c',         41,0,  41,0,  42,175,  7,  29,95) )
  self:addChild(  Key:new(self, 'O1D#', 'd',         77,0,  77,0,  22,95) )
  self:addChild( LKey:new(self, 'O1E' , 'e',         83,0,  83,0,  42,175, 16,  26,95) )
  self:addChild( LKey:new(self, 'O1F' , 'f',        125,0, 125,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O1F#', 'g',        151,0, 151,0,  22,95) )
  self:addChild( LKey:new(self, 'O1G' , 'h',        166,0, 166,0,  42,175,  7,  24,95) )
  self:addChild(  Key:new(self, 'O1G#', 'i',        197,0, 197,0,  23,95) )
  self:addChild( LKey:new(self, 'O1A' , 'j',        208,0, 208,0,  41,175, 12,  25,95) )
  self:addChild(  Key:new(self, 'O1A#', 'k',        245,0, 245,0,  22,95) )
  self:addChild( LKey:new(self, 'O1B' , 'l',        249,0, 249,0,  42,175, 18,  24,95) )
  self:addChild( LKey:new(self, 'O2C' , 'm',   owidth+0,0,   0,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O2C#', 'n',  owidth+26,0,  26,0,  22,95) )
  self:addChild( LKey:new(self, 'O2D' , 'o',  owidth+41,0,  41,0,  42,175,  7,  29,95) )
  self:addChild(  Key:new(self, 'O2D#', 'p',  owidth+77,0,  77,0,  22,95) )
  self:addChild( LKey:new(self, 'O2E' , 'q',  owidth+83,0,  83,0,  42,175, 16,  26,95) )
  self:addChild( LKey:new(self, 'O2F' , 'r', owidth+125,0, 125,0,  41,175,  0,  26,95) )
  self:addChild(  Key:new(self, 'O2F#', 's', owidth+151,0, 151,0,  22,95) )
  self:addChild( LKey:new(self, 'O2G' , 't', owidth+166,0, 166,0,  42,175,  7,  24,95) )
  self:addChild(  Key:new(self, 'O2G#', 'u', owidth+197,0, 197,0,  23,95) )
  self:addChild( LKey:new(self, 'O2A' , 'v', owidth+208,0, 208,0,  41,175, 12,  25,95) )
  self:addChild(  Key:new(self, 'O2A#', 'w', owidth+245,0, 245,0,  22,95) )
  self:addChild( LKey:new(self, 'O2B' , 'x', owidth+249,0, 249,0,  42,175, 18,  24,95) )
  self:addChild(  Key:new(self, 'O3C' , 'y', owidth+291,0, 291,0,  40,175) )
end

function Piano:toogleShowKeys()
  self.showKeys = not self.showKeys
end



