local Player = require "player"
--local _p = require "pprint"
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
      player = Player.init(),
      player_shots = {},
    }
  end,
  exit = function() end,
  update = function(state, inputs, dt)
    state.player:update(inputs, dt)
    if state.player.shoot1 then
      table.insert(state.player_shots, {
        pos = state.player.pos,
        vel = (state.player.shoot_target - state.player.pos):norm() * state.player.shoot_speed,
      })
    end

    -- update shots
    for _, shot in pairs(state.player_shots) do
      shot.pos = shot.pos + shot.vel * dt
    end
    anim:update(dt)
  end,
  draw = function(state)
    state.player:draw()
    for _, shot in pairs(state.player_shots) do
      love.graphics.rectangle("fill", shot.pos.x, shot.pos.y, 5, 5)
    end
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
