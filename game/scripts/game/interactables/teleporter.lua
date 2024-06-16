local Interactable = require("interactable", ...)

local Teleporter = Interactable:extend("Teleporter")

function Teleporter:new(...)
    Teleporter.super.new(self, ...)
    self:setImage("interactables/teleporter", true)
    self.inputInteractable = true

    self.offset.y = 8

    self.sfx = {
        on = "teleporter_on",
        off = "teleporter_off",
    }
end

function Teleporter:done()
    Teleporter.super.done(self)
    self.lightSource = self.scene:addLightSource(self, 100, 50)
    self.lightSource.visible = false
end

function Teleporter:onStateChanged()
    Teleporter.super.onStateChanged(self)
    self.lightSource.visible = self.on
end

function Teleporter:onInteract(e)
    if not self.on then return end
    if e.teleporterJustUsed == self then
        return
    end

    local otherTeleporter = self:getOtherTeleporter()

    e:teleportByPlatform(self, otherTeleporter)
end

function Teleporter:getOtherTeleporter()
    return self.scene:findEntity(function(v)
        return v.mapEntityId == self.otherTeleporter.entityId
    end)
end

return Teleporter
