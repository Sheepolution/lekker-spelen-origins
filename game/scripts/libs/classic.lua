--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

local Object = {}
Object.__index = Object
Object.__id = 0

function Object:new()
end

function Object:done()
end

local ids = 0

function Object:extend(name)
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  cls.__name = name
  ids = ids + 1
  cls.__uuid = ids
  setmetatable(cls, self)
  return cls
end

function Object:implement(...)
  for _, cls in pairs({ ... }) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end

function Object:duplicate(a)
  for k, v in pairs(self) do
    a[k] = self[k]
  end
end

function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

function Object:__tostring()
  return self.__name or "Object"
end

function Object:__call(...)
  local obj = setmetatable({}, self)
  obj.__class = self

  obj:new(...)

  if obj.postNew then obj:postNew() end

  return obj
end

return Object
