local Renderer = {}


local w, h = 160, 144
--- @class love.Texture
local buffer
local scale = 3
local shader

local default_pallet = {
  { 23 / 255, 42 / 255, 73 / 255, 1.0 }
, { 255 / 255, 117 / 255, 102 / 255, 1.0 }
, { 242 / 255, 218 / 255, 67 / 255, 1.0 }
, { 215 / 255, 247 / 255, 226 / 255, 1.0 }
}

function Renderer.load()
  buffer = love.graphics.newCanvas(w, h)
  buffer:setFilter("nearest", "nearest")
  shader = love.graphics.newShader("assets/fragment.glsl")
  Renderer.pallet(default_pallet[1], default_pallet[2], default_pallet[3], default_pallet[4])
  love.window.setMode(w * scale, h * scale)
end

function Renderer.pallet(cb, cg, cw, ch)
  shader:sendColor("b", cb)
  shader:sendColor("g", cg)
  shader:sendColor("w", cw)
  shader:sendColor("h", ch)
end

function Renderer.draw(f, ...)
  local canvas = love.graphics.getCanvas()

  -- Explicitly clear with different colors
  love.graphics.setShader(shader)
  love.graphics.setCanvas(buffer)
  love.graphics.clear(unpack(default_pallet[1]))
  f(...)

  love.graphics.setCanvas(canvas)
  love.graphics.clear(unpack(default_pallet[2]))
  local sw, sh = love.graphics.getDimensions()
  love.graphics.draw(buffer, (sw - (w * scale)) / 2, (sh - (h * scale)) / 2, 0, scale)
end

return Renderer
