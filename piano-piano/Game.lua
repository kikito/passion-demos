require('Piano')


Game = class('Game', StatefulObject)
Game:includes(Beholder)

-- load some functions using passion's built-in resource manager
Game.fonts = {
  title = passion.fonts.getFont('fonts/broadbay.ttf', 70),
  button = passion.fonts.getFont('fonts/broadbay.ttf', 40)
}

function Game:initialize()
  super.initialize(self)
  self.title = passion.gui.Label:new({
    text='~ Piano Piano ~', 
    x=100, y=20, width=600, align='center', 
    font=Game.fonts.title
  })

  self:observe('keypressed_escape', 'back')
  self:gotoState('MainMenu')
end

function Game:back()
  passion.exit()
end

local MainMenu = Game:addState('MainMenu')

function MainMenu:enterState()
  local game = self
  self.startButton = passion.gui.Button:new({
    text='Play it again, Sam',
    x=150, y=200, width=500,
    cornerRadius=10,
    font=Game.fonts.button,
    onClick = function(b) game:gotoState('Play') end
  })
  
  self.exitButton = passion.gui.Button:new({
    text='Exit',
    x=200, y=400, width=400,
    cornerRadius=10,
    font=Game.fonts.button,
    onClick = function(b) game:back() end
  })
end

function MainMenu:exitState()
  self.startButton:destroy()
  self.startButton = nil
  self.exitButton:destroy()
  self.exitButton = nil
end

local Play = Game:addState('Play')

function Play:enterState()
  local game = self

  self.piano = Piano:new(80,150)
  self:observe('keypressed_tab', function() self.piano:toogleShowKeys() end)

  self.backButton = passion.gui.Button:new({
    text='Back',
    x=200, y=400, width=400,
    cornerRadius=10,
    font=Game.fonts.button,
    onClick = function(b) game:back() end
  })
end

function Play:back()
  self:gotoState('MainMenu')
end

function Play:exitState()

  self.backButton:destroy()
  self.backButton = nil

  self.piano:destroy()
  self.piano = nil
  
  self:stopObserving('keypressed_tab')
end
