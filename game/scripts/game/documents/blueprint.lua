local Document = require "documents.document"

local Blueprint = Document:extend("Blueprint")

function Blueprint:new(name)
    Blueprint.super.new(self)
    self:setImage("documents/blueprints/" .. name)
    self.name = name
    self:centerX(WIDTH / 2)
end

return Blueprint
