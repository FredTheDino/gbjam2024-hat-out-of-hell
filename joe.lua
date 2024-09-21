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

--- @param a boolean
--- @return number
function joe.asInt(a)
  if a then return 1.0 else return 0.0 end
end

function joe.asInt(a)
  if a then return 1.0 else return 0.0 end
end

-- Function to pick a random element from a table
function joe.random_from(t)
    if #t == 0 then return nil end
    return t[math.random(1, #t)]
end

return joe

