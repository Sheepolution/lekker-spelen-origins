local Enum = require "libs.enum"
local Sprite = require "base.sprite"

local Document = Sprite:extend("Document")

Document.DocumentType = Enum("Log", "Blueprint", "Charizard")

function Document:new(...)
    Document.super.new(self, ...)
    self.z = ZMAP.Document
end

function Document:update(dt)
    Document.super.update(self, dt)
end

return Document
