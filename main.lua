local Player = require "player"
--local _p = require "pprint"
local peachy = require "peachy"
local GameState = require "gamestate"
local Renderer = require "renderer"
local Metronome = require "items.metronome"
local Fridge = require "items.fridge"
local Level = require "level"
local Joe = require "joe"
local Vec = require "vector"
local inspect = require "inspect"

local tiles

-- Example GameState
local player_state = GameState.new {
  enter = function()
    tiles = tiles or love.graphics.newImage("assets/tileset.png")
    local level = Level.new(require "assets.basic_map", tiles)
    return {
      player = Player.init(level.player_spawn),
      player_shots = {},
      items = { Fridge.init() },
      level = level,
    }
  end,
  exit = function() end,
  update = function(state, inputs, dt)
    state.player:update(inputs, dt)
    state.player.pos, state.player.vel = state.level:contain(
      state.player.pos,
      Vec.new(16, 16),
      state.player.vel
    )

    -- spawn shots
    if state.player.shoot1 then
      shot = {
        pos = state.player.pos,
        vel = (state.player.shoot_target - state.player.pos):norm() * state.player.shoot_speed,
        alive = state.player.shot_life,
        on_hit = {},
      }
      table.insert(state.player_shots, shot)
      for _, item in pairs(state.items) do
        if item.on_shoot1 then
          item:on_shoot1(shot)
        end
      end
    end

    -- TODO: if state.player.shoot2

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

    for _, item in pairs(state.items) do
      item:update(dt)
    end
  end,
  draw = function(state)
    love.graphics.push()
    love.graphics.translate(
      Joe.round(-state.player.pos.x + Renderer.w / 2 - 8),
      Joe.round(-state.player.pos.y + Renderer.h / 2 - 8)
    )
    state.level:draw()
    love.graphics.setColor(0, 0, 0)
    for _, shot in pairs(state.player_shots) do
      love.graphics.rectangle("fill", shot.pos.x, shot.pos.y, 4, 4)
    end
    love.graphics.setColor(1, 1, 1)
    state.player:draw()
    for _, item in pairs(state.items) do
      item:draw()
    end
    love.graphics.pop()
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
