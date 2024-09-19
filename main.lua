local Player = require "player"
--local _p = require "pprint"
local peachy = require "peachy"
local GameState = require "gamestate"
local Renderer = require "renderer"
local Metronome = require "items.metronome"

local anim

-- Example GameState
local player_state = GameState.new {
  enter = function()
    local sprite = love.graphics.newImage("assets/sample.png")
    anim = peachy.new("assets/sample.json", sprite, "loop")
    return {
      player = Player.init(),
      player_shots = {},
      metronome = Metronome.init(),
    }
  end,
  exit = function() end,
  update = function(state, inputs, dt)
    state.player:update(inputs, dt)

    -- spawn shots
    if state.player.shoot1 then
      table.insert(state.player_shots, {
        pos = state.player.pos,
        vel = (state.player.shoot_target - state.player.pos):norm() * state.player.shoot_speed,
        alive = state.player.shot_life
      })
      state.metronome:on_shoot()
    end

    -- update shots
    for _, shot in pairs(state.player_shots) do
      shot.pos = shot.pos + shot.vel * dt
      shot.alive = shot.alive - dt
    end

    -- remove unalive shots
    local new_shots = {}
    for _, shot in pairs(state.player_shots) do
      if shot.alive > 0.0 then
        table.insert(new_shots, shot)
      end
    end
    state.player_shots = new_shots

    anim:update(dt)
    state.metronome:update(dt)
  end,
  draw = function(state)
    state.player:draw()
    for _, shot in pairs(state.player_shots) do
      love.graphics.rectangle("fill", shot.pos.x, shot.pos.y, 5, 5)
    end
    anim:draw(100, 100)
    state.metronome:draw(dt)
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
