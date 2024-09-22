local peachy = require "peachy"

local cycle_length = 0.9

---@class Metronome
local Metronome = {}

---@return Metronome
function Metronome.init()
  local self = setmetatable({}, { __index = Metronome })
  self.sprite = love.graphics.newImage("assets/metronome.png")
  self.anim = peachy.new("assets/metronome.json", self.sprite, "loop")
  self.start_t = love.timer.getTime()
  self.good_shot = false
  self.last_shot = 0.0
  self.last_sync = 0.0
  return self
end

function Metronome:update(dt)
  self.anim:update(dt)
  local t = love.timer.getTime()
  if t - self.last_sync > 1.0 and self:_get_beat_offset() < 0.05 then
    self.last_sync = t
    self.anim:setFrame(2)
  end
end

function Metronome:_get_beat_offset()
  local time = love.timer.getTime()
  local deltatime = time - self.start_t
  return math.fmod(deltatime, cycle_length)
end

function Metronome:_is_on_beat()
  local offset = self:_get_beat_offset()
  return offset > (cycle_length / 2.0) - 0.1 and offset < (cycle_length / 2.0) + 0.1
end

function Metronome:draw(x, y)
  self.anim:draw(x, y)
end

function Metronome:on_shoot(shots)
  self.good_shot = self:_is_on_beat()
  self.last_shot = love.timer.getTime()
  local out = {}
  if self.good_shot then
    for _, s in pairs(shots) do
      table.insert(out, s)
      local ss = s:clone()
      ss.vel = -ss.vel
      table.insert(out, ss)
    end
  else
    out = shots
  end
  return out
end

return Metronome
