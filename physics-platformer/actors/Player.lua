require('passion.init')
require('actors/Pawn')

Player = class('Player', Pawn)
function Player:initialize(x, y)
  super.initialize(self, x, y, 32, 50, passion.colors.white)

  self.wantsJump=false
  self.wantsLeft=false
  self.wantsRight=false

  self:observe('keypressed_up',    function(obj) obj.wantsJump=true end)
  self:observe('keypressed_right', function(obj) obj.wantsRight=true end)
  self:observe('keypressed_left',  function(obj) obj.wantsLeft=true end)

  self:observe('keyreleased_up',    function(obj) obj.wantsJump=false end)
  self:observe('keyreleased_right', function(obj) obj.wantsRight=false end)
  self:observe('keyreleased_left',  function(obj) obj.wantsLeft=false end)
end


function Player:wantLeft()
  return self.wantsLeft==true
end

function Player:wantRight()
  return self.wantsRight==true
end

function Player:wantJump()
  return self.wantsJump==true
end
