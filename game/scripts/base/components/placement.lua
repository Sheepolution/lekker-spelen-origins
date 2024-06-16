local Input = require "base.input"
local Class = require "base.class"

local Placement = Class:extend("Placement")

function Placement:new(...)
    Placement.super.new(self, ...)
end

function Placement:update(dt)
    local x, y = self.x, self.y

    if Input:isDown("lshift") then
        if Input:isPressed("h") then
            self.x = self.x - 1
        elseif Input:isPressed("l") then
            self.x = self.x + 1
        elseif Input:isPressed("j") then
            self.y = self.y + 1
        elseif Input:isPressed("k") then
            self.y = self.y - 1
        end

        if self.angle and Input:isPressed("r") then
            self.angle = self.angle + .1
        end
    else
        local amount = 1

        if Input:isDown("lctrl") then
            amount = 4
        end

        if Input:isDown("h") then
            self.x = self.x - amount
        elseif Input:isDown("l") then
            self.x = self.x + amount
        elseif Input:isDown("j") then
            self.y = self.y + amount
        elseif Input:isDown("k") then
            self.y = self.y - amount
        end

        if Input:isDown("r") then
            self.angle = self.angle + .1
            print(self.angle)
        end
    end

    if self.x ~= x or self.y ~= y then
        print(self.x, self.y)
    end
end

return Placement
