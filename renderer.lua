local Renderer = {}


local w, h = 160, 144
--- @class love.Texture
local buffer
local scale = 3

local palette = { { 0.0, 0.0, 0.0 }, { 0.5, 0.5, 0.5 }, { 1.0, 1.0, 1.0 }, { 0.3, 0.7, 0.7 } }

function Renderer.load()
  buffer = love.graphics.newCanvas(w, h)
  buffer:setFilter("nearest", "nearest")
end

function Renderer.draw(f, ...)
  local canvas = love.graphics.getCanvas()

  -- TODO: Force the palette
  -- Explicitly clear with different colors
  love.graphics.setCanvas(buffer)
  love.graphics.clear(unpack(palette[1]))
  f(...)

  love.graphics.setCanvas(canvas)
  love.graphics.clear(unpack(palette[2]))
  local sw, sh = love.graphics.getDimensions()
  love.graphics.draw(buffer, (sw - (w * scale)) / 2, (sh - (h * scale)) / 2, 0, scale)
end

return Renderer
