local Enum = {}
local Meta = {
   __index    = function(_, k) error("Attempt to index non-existant enum '" .. tostring(k) .. "'.", 2) end,
   __newindex = function() error("Attempt to write to static enum", 2) end,
}

local ids = {}

function Enum.new(...)
   local values = { ... }

   if type(values[1]) == "table" then
      values = values[1]
   end

   local enum = {}

   local id
   repeat
      id = math.random(10000, 99999)
   until not ids[id]

   ids[id] = true
   id = "_" .. tostring(id)

   for i = 1, #values do
      enum[values[i]] = values[i] .. id
   end

   return setmetatable(enum, Meta)
end

return setmetatable(Enum, {
   __call = function(_, ...) return Enum.new(...) end,
})
