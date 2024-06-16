local Asset = require "base.asset"
local Class = require "base.class"
local Placement = require "base.components.placement"

local Background = Class:extend("Background")

function Background:new(x, y)
    self.x = x
    self.y = y

    self.images = list()
    self.z = 1000
    self.cache = {}
end

function Background:add(sprite, x, y, flip, moving)
    local image = Asset.image("background/" .. sprite)
    local width = image:getWidth() / 2
    local height = image:getHeight() / 2

    self.images:add({
        sprite = image,
        x = x == true and 0 or x,
        y = x == true and 0 or y,
        width = width,
        height = height,
        flip = flip,
        moving = x == true or moving
    })
end

function Background:update(dt)
    for i, v in ipairs(self.images) do
        if v.moving then
            Placement.update(v, dt)
        end
    end
end

function Background:draw()
    for i, image in ipairs(self.images) do
        love.graphics.draw(image.sprite, self.x + image.x + image.width, self.y + image.y + image.height, 0,
            image.flip and -1 or 1,
            1, image.width, image.height)
    end
end

return Background
