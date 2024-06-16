local Input = require "base.input"
local Save = require "base.save"
local Dancer = require("dancer", ...)

local Player = Dancer:extend("Peter")

Player.keys = {
    {
        left = { "c1_left_left", "c1_dpleft", "c1_x" },
        right = { "c1_left_right", "c1_dpright", "c1_b" },
        up = { "c1_left_up", "c1_dpup", "c1_y" },
        down = { "c1_left_down", "c1_dpdown", "c1_a" },
    },
    {
        left = { "a", "left", "c2_left_left", "c2_dpleft", "c2_x" },
        right = { "d", "right", "c2_left_right", "c2_dpright", "c2_b" },
        up = { "w", "up", "c2_left_up", "c2_dpup", "c2_y" },
        down = { "s", "down", "c2_left_down", "c2_dpdown", "c2_a" },
    }
}

if DEBUG then
    Player.keys = {
        {
            left = { "left", "c1_left_left", "c1_dpleft", "c1_x" },
            right = { "right", "c1_left_right", "c1_dpright", "c1_b" },
            up = { "up", "c1_left_up", "c1_dpup", "c1_y" },
            down = { "down", "c1_left_down", "c1_dpdown", "c1_a" },
        },
        {
            left = { "a", "c2_left_left", "c2_dpleft", "c2_x" },
            right = { "d", "c2_left_right", "c2_dpright", "c2_b" },
            up = { "w", "c2_left_up", "c2_dpup", "c2_y" },
            down = { "s", "c2_left_down", "c2_dpdown", "c2_a" },
        }
    }
end

function Player:new(...)
    Player.super.new(self, ...)
    self.inControl = true
end

function Player:update(dt)
    self.controllerId = Save:get("settings.controls." .. self.tag:lower() .. ".player1") and 1 or 2

    Player.super.update(self, dt)
    if self.inControl then
        if Input:isPressed(self.keys[self.controllerId].left) then
            self:danceLeft()
        elseif Input:isPressed(self.keys[self.controllerId].right) then
            self:danceRight()
        elseif Input:isPressed(self.keys[self.controllerId].up) then
            self:danceUp()
        elseif Input:isPressed(self.keys[self.controllerId].down) then
            self:danceDown()
        end
    end
end

function Player:giveControl()
    self.inControl = true
end

function Player:takeControl()
    self.inControl = false
end

function Player:danceLeft()
    Player.super.danceLeft(self)
    self.scene:onDanceMove(self, "left")
end

function Player:danceRight()
    Player.super.danceRight(self)
    self.scene:onDanceMove(self, "right")
end

function Player:danceUp()
    Player.super.danceUp(self)
    self.scene:onDanceMove(self, "up")
end

function Player:danceDown()
    Player.super.danceDown(self)
    self.scene:onDanceMove(self, "down")
end

return Player
