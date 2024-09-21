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
local Slime = require "slime"
local Vector = require "vector"

local tiles

local shot_radius = 2
local entity_radius = 8

-- Example GameState
local player_state = GameState.new {
  enter = function()
    tiles = tiles or love.graphics.newImage("assets/tileset.png")
    local level = Level.new(require "assets.basic_map", tiles)
    return {
      player = Player.init(level.player_spawn),
      enemies = { Slime.init(50, 50), Slime.init(150, 50) },
      dead = {},
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

    -- player should target the closest enemy
    state.player.can_shoot = #state.enemies ~= 0
    if state.player.can_shoot then
      local new_target_pos = state.enemies[1].pos
      local new_target_dist = new_target_pos:dist_square(state.player.pos)
      for _, enemy in pairs(state.enemies) do
        local dist = enemy.pos:dist_square(state.player.pos)
        if dist < new_target_dist then
          new_target_pos = enemy.pos
          new_target_dist = dist
        end
      end
      state.player.shoot_target = new_target_pos + Vector.new(entity_radius, entity_radius)
    end

    -- spawn shots
    if state.player.shoot1 then
      shot = {
        pos = state.player.pos,
        vel = (state.player.shoot_target - state.player.pos):norm() * state.player.shoot_speed,
        alive = state.player.shot_life,
        on_hit = {},
        has_hit = false,
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

    -- check if player shots have hit enemies
    local new_enemies = {}
    local new_dead = {}
    for _, enemy in pairs(state.enemies) do
      local is_dead = false
      for _, shot in pairs(state.player_shots) do
        local dx = math.abs((shot.pos.x + shot_radius) - (enemy.pos.x + entity_radius))
        local dy = math.abs((shot.pos.y + shot_radius) - (enemy.pos.y + entity_radius))
        if dx * dx + dy * dy < 2 + 8 then
          is_dead = true
          shot.has_hit = true
        end
      end
      if is_dead then
        enemy:kill()
        table.insert(new_dead, enemy)
      else
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
      love.graphics.rectangle("fill", shot.pos.x, shot.pos.y, shot_radius * 2, shot_radius * 2)
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
