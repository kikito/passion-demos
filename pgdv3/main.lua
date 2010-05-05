-- Example: Stateful game

require('passion.init')
require('Game')

function passion:load()
  game = Game:new()
end

function love.run()
  return passion:run()
end
