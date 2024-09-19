local Self = {}
local Vec = require "vector"
Self.__index = Self
local inspect = require "inspect"

local TILE_SIZE = 16

function Self.new(map, tiles)
  local self = setmetatable({}, { __index = Self })
  self.tiles = tiles

  local keys = {}

  self.walls = {}
  self.spawns = {}
  self.walkables = {}
  for _, layer in pairs(map.layers) do
    if layer.type == "tilelayer" then
      for _, c in pairs(layer.chunks) do
        for i, key in pairs(c.data) do
          if key ~= 0 then
            if keys[key] == nil then
              keys[key] = love.graphics.newQuad(
                (key - 1) * 16,
                0,
                TILE_SIZE,
                TILE_SIZE,
                tiles
              )
            end
            local x = (c.x + (i % c.width)) * TILE_SIZE
            local y = (c.y + math.floor(i / c.height)) * TILE_SIZE
            table.insert(self.walls, {
              -- Grid coordinates
              x = x,
              y = y,
              quad = keys[key],
              key = key
            })
          end
        end
      end
    elseif layer.type == "objectgroup" then
      for _, o in pairs(layer.objects) do
        local at = Vec.new(o.x, o.y)
        if o.name == "player" and o.shape == "point" then
          self.player_spawn = at
        elseif o.name == "spawn" and o.shape == "point" then
          table.insert(self.spawns, at)
        elseif o.name == "walkable" and o.shape == "rectangle" then
          table.insert(self.walkables, {
            at = at,
            size = Vec.new(o.width, o.height)
          })
        end
      end
    end
  end
  return self
end

function Self:draw()
  for _, w in pairs(self.walls) do
    love.graphics.draw(self.tiles, w.quad, w.x, w.y)
  end
end

return Self
