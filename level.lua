local Self = {}
local Vec = require "vector"
Self.__index = Self
local inspect = require "inspect"
local Joe = require "joe"

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

function Self:contain(p, size, v)
  v = v or Vec.new()
  local correction
  for _, a in pairs(self.walkables) do
    local lo, hi = a.at + Vec.new(size.x, 0), a.at + a.size - Vec.new(0, size.y)
    if lo.x < p.x and p.x < hi.x and lo.y < p.y and p.y < hi.y then
      -- We are infact on walkable
      return p, v
    end
    -- TODO: Double check these
    local diff_a = (lo - p):max(0)
    local diff_b = (hi - p):min(0)
    local diff = Vec.new(
      Joe.iff(diff_a.x > 0, diff_a.x, diff_b.x),
      Joe.iff(diff_a.y > 0, diff_a.y, diff_b.y)
    )
    local best_diff
    if math.abs(diff.x) > math.abs(diff.y) then
      best_diff = Vec.new(diff.x, 0)
    else
      best_diff = Vec.new(0, diff.y)
    end
    if correction == nil or best_diff:magSq() < correction:magSq() then
      correction = best_diff
    end
  end
  correction = correction or Vec.new()
  return p + correction, v * Vec.new(Joe.asInt(correction.x == 0), Joe.asInt(correction.y == 0))
end

function Self:draw()
  for _, w in pairs(self.walls) do
    love.graphics.draw(self.tiles, w.quad, w.x, w.y)
  end
end

return Self
