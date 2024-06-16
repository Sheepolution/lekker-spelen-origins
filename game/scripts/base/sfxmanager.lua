local SFX = require "base.sfx"
local Class = require "base.class"

local SFXManager = Class:extend("SFXManager")

function SFXManager:new(directory)
    SFXManager.super.new(self)

    self.directory = directory
    self.sfx = {}

    self.id = _.random(0, 9999)
end

function SFXManager:play(path, effect)
    if not self.sfx[path] then
        self:add(path)
    end

    return self.sfx[path]:play(effect and "SFX_" .. self.id .. effect or nil)
end

function SFXManager:stop()
    for k, v in pairs(self.sfx) do
        v:stop()
    end
end

function SFXManager:add(path, max, props)
    if self.sfx[path] then return end

    self.sfx[path] = SFX(self.directory .. "/" .. path, max, props)
end

function SFXManager:createEffect(name, settings)
    love.audio.setEffect("SFX_" .. self.id .. name, settings)
end

return SFXManager
