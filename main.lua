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
  update = function(state, inputs, dt)
    state.player:update(inputs, dt)
  end,
  draw = function(state)
    state.player:draw()
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
