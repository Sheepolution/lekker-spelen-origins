local Sprite = require "base.sprite"
local Scene = require "base.scene"

local Intro = Scene:extend()

function Intro:new()
    Intro.super.new(self, 0, 0, 1920, 1080)
    self.logo = self:add(Sprite(0, 0, "sheepolution"))
    self:fadeIn(.5)
    self:delay(3, function()
        self:fadeOut(.5, function()
            self.logo.visible = false
            self:delay(.1, function()
                self.scene:toGame()
            end)
        end)
    end)
end

function Intro:draw()
    CANVAS:draw(function() Intro.super.draw(self) end)
end

return Intro
