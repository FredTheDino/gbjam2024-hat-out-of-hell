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

function Metronome:draw()
  -- TODO: draw in icon grid
  self.anim:draw(50, 50)
  if self.good_shot then
    love.graphics.rectangle("fill", 50, 66, 4, 4)
  end

  if self:_is_on_beat() then
    love.graphics.rectangle("fill", 60, 66, 4, 4)
  end
end

function Metronome:on_shoot()
  self.good_shot = self:_is_on_beat()
  self.last_shot = love.timer.getTime()
  -- TODO: manipulate the shot in some way
end

return Metronome
