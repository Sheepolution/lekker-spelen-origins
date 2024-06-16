local Input = require "base.input"
local Entity = require "base.entity"

local Dancer = Entity:extend("Dancer")

function Dancer:new(...)
    Dancer.super.new(self, ...)
    self.solid = 0

    self.inControl = false
    self.lastDirection = "down"
end

function Dancer:update(dt)
    Dancer.super.update(self, dt)
end

function Dancer:danceNeutral()
    self.anim:set("neutral" .. (self.dance and "_dance" or ""))
end

function Dancer:danceLeft()
    self.anim:set("left" .. (self.dance and "_dance" or ""))
    self:onDanceMove()
end

function Dancer:danceRight()
    self.anim:set("right" .. (self.dance and "_dance" or ""))
    self:onDanceMove()
end

function Dancer:danceUp()
    self.anim:set("up" .. (self.dance and "_dance" or ""))
    self:onDanceMove()
end

function Dancer:danceDown()
    self.anim:set("down" .. (self.dance and "_dance" or ""))
    self:onDanceMove()
end

function Dancer:danceTo(direction)
    if direction == "left" then
        self:danceLeft()
    elseif direction == "right" then
        self:danceRight()
    elseif direction == "up" then
        self:danceUp()
    elseif direction == "down" then
        self:danceDown()
    else
        self:danceNeutral()
    end
end

function Dancer:onDanceMove()
    self.scale:set(1.05)
    self:tween(self.scale, .1, { x = 1, y = 1 }):ease("quadin")
end

function Dancer:doRandomDanceMove()
    local moves = { "left", "right", "up", "down" }

    -- Remove last dance position
    if self.lastDirection then
        for i = #moves, 1, -1 do
            if moves[i] == self.lastDirection then
                table.remove(moves, i)
                break
            end
        end
    end

    local move = moves[math.random(#moves)]
    self.lastDirection = move
    self:danceTo(move)
end

return Dancer
