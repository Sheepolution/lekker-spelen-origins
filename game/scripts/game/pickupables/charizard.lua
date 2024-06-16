local logs = require "data.logs"
local Document = require "documents.document"
local Save = require "base.save"
local Pickupable = require "pickupables.pickupable"

local Charizard = Pickupable:extend("Charizard")

function Charizard:new(...)
    Charizard.super.new(self, ...)
    self:setImage("pickupables/charizard")
    self.type = Document.DocumentType.Charizard
    -- self.mapDestructionType = Pickupable.mapDestructionType.Permanent
    -- self.mapPermanentDestruction = true
    self.sfx = "paper"
    self.name = "charizard"

    self.pickupable = not Save:get("documents.charizard")
end

function Charizard:update(dt)
    Charizard.super.update(self, dt)
end

function Charizard:onPickedUp()
    self.pickupable = false
    -- self.visible = false
    self.scene:showDocument(self.name, self.type)
    Save:save("documents.charizard", true)
end

return Charizard
