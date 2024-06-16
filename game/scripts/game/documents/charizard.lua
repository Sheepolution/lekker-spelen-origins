local Document = require "documents.document"

local Charizard = Document:extend("Charizard")

function Charizard:new()
    Charizard.super.new(self)
    self:setImage("documents/charizard")
    self.name = "charizard"
    self.charizard = true
    self:centerX(WIDTH / 2)
end

return Charizard
