local Player = require "player"
local GameState = require "gamestate"
local Renderer = require "renderer"
local Level = require "level"
local Joe = require "joe"
local Vec = require "vector"
local Slime = require "slime"
local Timer = require "timer"

-- Items
local Metronome = require "items.metronome"
local Fridge = require "items.fridge"
local Usa = require "items.usa"
local Drill = require "items.drill"
local Fork = require "items.fork"
local ItemSlime = require "items.slime"

local tiles

local item_frame = love.graphics.newImage("assets/item-frame.png")

-- Example GameState

local function spawn(state)
  local at = Joe.random_from(state.level.spawns) + Vec(love.math.random(-3, 3), love.math.random(-3, 3))
  table.insert(state.enemies, Slime.init(at))
  table.insert(state.timers, Timer.new(1, spawn))
end

local player_state = GameState.new {
  enter = function()
    tiles = tiles or love.graphics.newImage("assets/tileset.png")
    local level = Level.new(require "assets.basic_map", tiles)
    local player = Player.init(level.player_spawn)
    table.insert(player.items, Fork.init())
    table.insert(player.items, Fork.init())
    table.insert(player.items, Fork.init())
    table.insert(player.items, Fork.init())
    table.insert(player.items, ItemSlime.init())
    table.insert(player.items, ItemSlime.init())
    local self = {
      player = player,
      enemies = {},
      dead = {},
      player_shots = {},
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


    local actions = {
      shoot = function(s) table.insert(state.player_shots, s) end
    }

    -- update shots
    for _, shot in pairs(state.player_shots) do
      shot:update(dt)
      local dp, dv = state.level:contain(
        shot:center() - shot:radius(),
        shot:radius() * 2,
        shot.vel,
        -1
      )
      if dp.x ~= 0 or dp.y ~= 0 then
        shot.pos = shot.pos + dp
        shot.vel = shot.vel * dv
        shot.has_hit = true
        shot:hit(nil, actions)
      end
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
      for _, shot in pairs(state.player_shots) do
        if shot.has_hit then goto continue end
        if enemy:is_dead() then goto continue end
        if shot.pos:dist_square(enemy:center()) < shot:radius().x ^ 2 + enemy:radius().x ^ 2 then
          shot:hit(enemy, actions)
          shot.has_hit = true
        end
        ::continue::
      end
      if enemy:is_dead() then
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
      if shot:keep() then
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
    for _, item in pairs(state.player.items) do
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
      shot:draw()
    end
    love.graphics.setColor(1, 1, 1)
    state.player:draw()
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
