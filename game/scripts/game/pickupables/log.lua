local logs = require "data.logs"
local Document = require "documents.document"
local Save = require "base.save"
local Pickupable = require "pickupables.pickupable"

local Log = Pickupable:extend("Log")

function Log:new(...)
    Log.super.new(self, ...)
    self:setImage("pickupables/log")
    self.type = Document.DocumentType.Log
    self.mapDestructionType = Pickupable.mapDestructionType.Permanent
    self.mapPermanentDestruction = true
    self.sfx = "paper"
end

function Log:update(dt)
    Log.super.update(self, dt)
end

function Log:onPickedUp()
    Log.super.onPickedUp(self)
    if not self:isSpecial() then
        self.scene:showDocument(self.name, self.type)
    end

    local owned_logs = list(Save:get("documents.logs"))

    if not owned_logs:contains(self.name) then
        owned_logs:add(self.name)
        Save:save("documents.logs", owned_logs:table())
    end
end

function Log:isSpecial()
    return logs[self.name].special
end

return Log
