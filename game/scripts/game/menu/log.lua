local Text = require "base.text"
local Sprite = require "base.sprite"

local logs = require "data.logs"

local Log = Sprite:extend("Log")

function Log:new(x, y, name, known)
    Log.super.new(self, x, y)
    self.known = known
    self.name = name

    self:setImage("menu/log", true)
    self.anim:set(known and "known" or "secret")

    self:setStart()
end

function Log:update(dt)
    Log.super.update(self, dt)
end

function Log:draw()
    Log.super.draw(self)
end

function Log:select()
    self.anim:set((self.known and "known_" or "secret_") .. "selected")
end

function Log:deselect()
    self.anim:set(self.known and "known" or "secret")
end

function Log:getName()
    return logs[self.name].title
end

return Log
