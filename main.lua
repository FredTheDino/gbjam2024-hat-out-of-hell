local player = require"player"
local state = {
  player = player.init()
}

function love.load()
end

function love.update(dt)
  state.player:update(dt)
end

function love.draw()
  love.graphics.rectangle("fill", 1, 1, 100, 100)
end
