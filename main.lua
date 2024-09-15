local Player = require "player"
local _p = require "pprint"
local GameState = require "gamestate"

-- Example GameState
local player_state = GameState.new {
  enter = function()
    return {
      player = Player.init()
    }
  end,
  exit = function() end,
  update = function(x, inputs, dt)
    x.player:update(dt)
  end,
  draw = function(state)
    love.graphics.rectangle("fill", 1, 1, 100, 100)
  end
}


function love.load()
  GameState.change(player_state)
end

function love.update(dt)
  GameState.update(dt)
end

function love.draw()
  GameState.draw()
end
