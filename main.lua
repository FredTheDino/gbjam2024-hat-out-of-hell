local Player = require "player"
local i = require "inspect"
local peachy = require "peachy"
local GameState = require "gamestate"
local Renderer = require "renderer"

local anim

-- Example GameState
local player_state = GameState.new {
  enter = function()
    local sprite = love.graphics.newImage("assets/sample.png")
    anim = peachy.new("assets/sample.json", sprite, "loop")
    return {
      player = Player.init()
    }
  end,
  exit = function() end,
  update = function(state, inputs, dt)
    state.player:update(inputs, dt)
    anim:update(dt)
  end,
  draw = function(state)
    state.player:draw()
    anim:draw(100, 100)
  end
}


function love.load()
  Renderer.load()
  GameState.change(player_state)
end

function love.update(dt)
  GameState.update(dt)
end

function love.draw()
  Renderer.draw(function()
    GameState.draw()
  end)
end
