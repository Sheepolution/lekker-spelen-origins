local Object = require "libs.classic"

local Class = Object:extend("Class")

local id = 0

function Class:new()
    self.tag = tostring(self)
    id = id + 1
    self.__id = id
end

function Class:setProperties(properties)
    for k, v in pairs(properties) do
        self[k] = v
    end
    return self
end

function Class:getMetatable()
    return getmetatable(self)
end

function Class:getClassName()
    return tostring(self)
end

return Class
