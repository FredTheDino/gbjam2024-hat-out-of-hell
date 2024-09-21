local Self = {}
Self.__index = Self

function Self.new(time, callback)
  local self = setmetatable({}, Self)
  self.time = time
  self.t = 0
  self.done = false
  self.callback = callback
  return self
end

function Self:cancel()
  self.done = true
  self.callback = function(_) end
end

function Self:update(dt, thing)
  if self.done then return end
  self.t = self.t + dt
  if self.t > self.time then
    self.callback(thing)
    self:cancel()
  end
end

return Self
