local Text = require "base.text"
local Sprite = require "base.sprite"

local Star = Sprite:extend("Blueprint")

function Star:new(x, y, name)
    Star.super.new(self, x, y)
    self.name = name

    self:setImage("menu/star", true)
    self.anim:set("default")

    local text = Text(0, -15, name, 32)
    text:setAlign("center", WIDTH)
    text:setColor(255, 66, 0)
    self.text = text
end

function Star:update(dt)
    Star.super.update(self, dt)
end

function Star:draw()
    Star.super.draw(self)
    self.text:drawAsChild(self, true)
end

function Star:select()
    self.anim:set("selected")
end

function Star:deselect()
    self.anim:set("default")
end

return Star
