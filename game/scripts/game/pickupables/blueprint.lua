local Save = require "base.save"
local logs = require "data.logs"
local Document = require "documents.document"
local Pickupable = require "pickupables.pickupable"

local Blueprint = Pickupable:extend("Blueprint")

function Blueprint:new(...)
    Blueprint.super.new(self, ...)
    self:setImage("pickupables/blueprint")
    self.sniffable = true
    self.type = Document.DocumentType.Blueprint

    self.mapDestructionType = Pickupable.mapDestructionType.Permanent
    self.mapPermanentDestruction = true

    self.sfx = "paper"
end

function Blueprint:update(dt)
    Blueprint.super.update(self, dt)
end

function Blueprint:onPickedUp()
    Blueprint.super.onPickedUp(self)

    local blueprints = list(Save:get("documents.blueprints"))

    if not blueprints:contains(self.name) then
        blueprints:add(self.name)
        Save:save("documents.blueprints", blueprints:table())
    end

    self.scene:showDocument(self.name, self.type)
end

return Blueprint
