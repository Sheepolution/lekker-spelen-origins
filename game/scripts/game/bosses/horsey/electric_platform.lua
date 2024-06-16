local Input = require "base.input"
local Player = require "characters.players.player"
local Entity = require "base.entity"

local ElectricPlatform = Entity:extend("ElectricPlatform")

function ElectricPlatform:new(...)
    ElectricPlatform.super.new(self, ...)
    self:setImage("bosses/horsey/electric_platform", true)

    self.standby = true

    if self.standby then
        self.anim:set("standby")
    else
        self.anim:set("off")
    end

    self.solid = 0
end

function ElectricPlatform:update(dt)
    if self.on then
        self.anim:set("on")
    elseif self.standby then
        self.anim:set("standby")
    else
        self.anim:set("off")
    end

    ElectricPlatform.super.update(self, dt)
end

function ElectricPlatform:onOverlap(i)
    if self.on then
        if i.e:is(Player) then
            if not i.e:isElectrified() then
                i.e:electrify()
            end
        end
    end
    return ElectricPlatform.super.onOverlap(self, i)
end

function ElectricPlatform:turnOn()
    if self.standby then
        self.on = true
    end
end

function ElectricPlatform:stop()
    self.on = false
end

return ElectricPlatform
