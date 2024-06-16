setmetatable(_G, {
  __newindex = function(t, k, v)
      error("Cannot set undefined variable: " .. k, 2)
  end,
  __index = function(t, k)
    error("Cannot get undefined variable: " .. k, 2)
  end
})