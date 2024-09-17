local joe = {}

--- @param cond boolean
--- @param a any
--- @param b any
--- @return any
function joe.iff(cond, a, b)
  if cond then return a else return b end
end

--- @param a number
--- @return number
function joe.round(a)
  return math.floor(a + 0.5)
end

return joe
