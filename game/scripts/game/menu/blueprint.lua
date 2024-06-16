local Text = require "base.text"
local Sprite = require "base.sprite"

local Blueprint = Sprite:extend("Blueprint")

function Blueprint:new(x, y, name, known)
    Blueprint.super.new(self, x, y)
    self.known = known
    self.name = name

    self:setImage("menu/blueprint", true)
    self.anim:set(known and "known" or "secret")

    local text = Text(0, -27, self.known and name or "??-??", 32)
    text:setAlign("center", WIDTH)
    self.text = text
end

function Blueprint:update(dt)
    Blueprint.super.update(self, dt)
end

function Blueprint:draw()
    Blueprint.super.draw(self)
    self.text:drawAsChild(self, true)
end

function Blueprint:select()
    self.anim:set((self.known and "known_" or "secret_") .. "selected")
end

function Blueprint:deselect()
    self.anim:set(self.known and "known" or "secret")
end

return Blueprint
