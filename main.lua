local Player = require "player"
local GameState = require "gamestate"
local Renderer = require "renderer"
local Metronome = require "items.metronome"
local Fridge = require "items.fridge"
local Level = require "level"
local Joe = require "joe"
local Vec = require "vector"
local Slime = require "slime"
local Vector = require "vector"
local Timer = require "timer"

local tiles

local SHOT_RADIUS = 2
local item_frame = love.graphics.newImage("assets/item-frame.png")

-- Example GameState

local function spawn(state)
  local at = Joe.random_from(state.level.spawns)
  table.insert(state.enemies, Slime.init(at))
  table.insert(state.timers, Timer.new(1, spawn))
end

local player_state = GameState.new {
  enter = function()
    tiles = tiles or love.graphics.newImage("assets/tileset.png")
    local level = Level.new(require "assets.basic_map", tiles)
    local player = Player.init(level.player_spawn)
    table.insert(player.items, Fridge.init())
    table.insert(player.items, Fridge.init())
    local self = {
      player = Player.init(level.player_spawn),
      enemies = { Slime.init(Vec.new(50, 50)) },
      dead = {},
      player_shots = {},
      items = {},
      level = level,
      timers = {},
    }
    spawn(self)
    return self
  end,
  exit = function() end,
  update = function(state, inputs, dt)
    state.player:update(inputs, dt, state.player_shots)
    local pp, vv                       = state.level:contain(
      state.player.pos,
      Vec.new(16, 16),
      state.player.vel
    )
    state.player.pos, state.player.vel = state.player.pos + pp, state.player.vel * vv

    -- update shots
    for _, shot in pairs(state.player_shots) do
      shot.pos = shot.pos + shot.vel * dt
      shot.alive = shot.alive - dt
    end

    local new_timers = {}
    for _, timer in pairs(state.timers) do
      timer:update(dt, state)
      if not timer.done then
        table.insert(new_timers, timer)
      end
    end
    state.timers = new_timers

    -- check if player shots have hit enemies
    local new_enemies = {}
    local new_dead = {}
    for _, enemy in pairs(state.enemies) do
      local is_dead = false
      for _, shot in pairs(state.player_shots) do
        if shot.pos:dist_square(enemy:center()) < SHOT_RADIUS ^ 2 + enemy:radius().x ^ 2 then
          is_dead = true
          shot.has_hit = true
        end
      end
      if is_dead then
        enemy:kill()
        table.insert(new_dead, enemy)
      else
        local pp, vv = state.level:contain(
          enemy:center() - enemy:radius(),
          enemy:radius() * 2,
          enemy.vel,
          -1
        )
        enemy.pos = enemy.pos + pp
        enemy.vel = enemy.vel * vv
        table.insert(new_enemies, enemy)
      end
    end
    for _, thing in pairs(state.dead) do
      if not thing.gone then
        table.insert(new_dead, thing)
      end
    end
    state.enemies = new_enemies
    state.dead = new_dead

    -- remove unalive shots
    local new_shots = {}
    for _, shot in pairs(state.player_shots) do
      if shot.alive > 0.0 and not shot.has_hit then
        table.insert(new_shots, shot)
      end
    end
    state.player_shots = new_shots

    -- player vs enemies
    for _, enemy in pairs(state.enemies) do
      state.player:check_hit(enemy)
    end

    -- update enemies
    for _, enemy in pairs(state.enemies) do
      enemy:update(dt, state.player.pos)
    end

    -- update dead
    for _, thing in pairs(state.dead) do
      thing:update(dt, state.player.pos)
    end

    -- update items
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
      love.graphics.circle("fill", math.floor(shot.pos.x), math.floor(shot.pos.y), SHOT_RADIUS)
    end
    love.graphics.setColor(1, 1, 1)
    state.player:draw()
    for _, item in pairs(state.items) do
      item:draw()
    end
    for _, enemy in pairs(state.enemies) do
      enemy:draw()
    end
    for _, enemy in pairs(state.dead) do
      enemy:draw()
    end
    love.graphics.pop()

    -- draw currently picked up items
    love.graphics.draw(item_frame, 0, Renderer.h - 17)
    for i, item in pairs(state.player.items) do
      item:draw((i - 1) * 16 + 1, Renderer.h - 17 + 1)
    end
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
