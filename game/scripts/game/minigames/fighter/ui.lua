local Rect = require "base.rect"
local Direction = (require "base.enums").Direction
local Sprite = require "base.sprite"
local Colors = require "base.colors"
local Input = require "base.input"
local Scene = require "base.scene"

local UI = Scene:extend("UI")

function UI:new(...)
    UI.super.new(self, ...)
    self:setBackgroundAlpha(0)

    self.healthBarFullWidth = 359

    self.healthBarPeter = self:add(Sprite())
    self.healthBarPeter:set(19, 15, self.healthBarFullWidth, 30)
    self.healthBarPeter:setStart()
    self.healthBarPeter.visible = false
    self.healthBarPeter.direction = Direction.Left
    self.healthBarTimon = self:add(Sprite())
    self.healthBarTimon:set(555, 15, self.healthBarFullWidth, 30)
    self.healthBarTimon.visible = false
    self.healthBarTimon.direction = Direction.Right

    self.healthBarPeter:setStart()
    self.healthBarTimon:setStart()

    self.healthBarPeter:setColor(Colors("peter"))
    self.healthBarTimon:setColor(Colors("timon"))

    self.graphic = self:add(Sprite(0, 0, "minigames/fighter/ui_no_stars"))

    self.rects = list({ self.healthBarPeter, self.healthBarTimon })

    self.peterStar = self:add(Sprite(412, 15, "minigames/fighter/star", true))
    self.timonStar = self:add(Sprite(510, 15, "minigames/fighter/star", true))

    self.dataMap = {
        peter = {
            healthBar = self.healthBarPeter,
            health = 100,
            side = Direction.Left,
            wins = 0,
            star = self.peterStar
        },
        timon = {
            healthBar = self.healthBarTimon,
            health = 100,
            side = Direction.Right,
            wins = 0,
            star = self.timonStar
        }
    }

    self.winningStar = self:add(Sprite(452, 20, "minigames/fighter/star_big", true))

    self.peterStar.z = -10
    self.timonStar.z = -10
    self.winningStar.z = -10
    self.peterStar.visible = false
    self.timonStar.visible = false
    self.winningStar.visible = false
end

function UI:update(dt)
    self.rects:filter_inplace(function(rect)
        return not rect.destroyed
    end)
    UI.super.update(self, dt)
end

function UI:draw()
    self.rects(function(rect)
        self:drawPolygon(rect)
    end)
    UI.super.draw(self)
end

function UI:drawPolygon(rect)
    local r, g, b = rect:getColor()
    love.graphics.setColor(r / 255, g / 255, b / 255)
    local x, y = rect.x + rect.offset.x, rect.y + rect.offset.y
    if rect.direction == Direction.Right then
        love.graphics.polygon("fill",
            x, y,
            x + rect.width, y,
            x + rect.width + rect.height, y + rect.height,
            x + rect.height, y + rect.height
        )
    else
        love.graphics.polygon("fill",
            x + rect.height, y,
            x + rect.width + rect.height, y,
            x + rect.width, y + rect.height,
            x, y + rect.height
        )
    end
end

function UI:decreaseHealth(player, decrease)
    local data = self.dataMap[player]

    local new_health = _.max(0, data.health - decrease)

    local rect = self:add(Sprite())
    rect.y = data.healthBar.y
    rect.height = data.healthBar.height
    rect.direction = data.side
    rect.visible = false

    if data.side == Direction.Left then
        rect.x = data.healthBar.x
        rect.width = self:getHealthToRectWidth(decrease)
        data.healthBar.x = data.healthBar.x + rect.width
        data.healthBar.width = data.healthBar.width - rect.width
    else
        rect.x = data.healthBar.x + self:getHealthToRectWidth(new_health)
        rect.width = self:getHealthToRectWidth(decrease)
        -- rect.x = rect.x - rect.width
        data.healthBar.width = data.healthBar.width - rect.width
    end

    data.health = new_health

    rect:shake(3, .5)
    self:delay(.5, function()
        rect:destroy()
    end)

    self.rects:add(rect)
end

function UI:getHealthToRectWidth(health)
    return self.healthBarFullWidth * self:getHealthRatio(health)
end

function UI:getHealthRatio(health)
    return health / 100
end

function UI:addWin(tag)
    local data = self.dataMap[tag]
    data.wins = data.wins + 1

    local star
    if data.wins == 1 then
        star = data.star
    else
        star = self.winningStar
    end

    star.anim:set(tag)
    star.visible = true
    star.scale:set(0, 0)
    self:tween(star.scale, .2, { x = 1, y = 1 }):ease("backout")
end

function UI:resetHealth()
    self.dataMap.peter.health = 100
    self.dataMap.timon.health = 100
    self.healthBarPeter:set(7, 12, self.healthBarFullWidth, 37)
    self.healthBarPeter:resetToStart()
    self.healthBarTimon:set(538, 12, self.healthBarFullWidth, 37)
    self.healthBarTimon:resetToStart()
end

function UI:addStars()
    self.graphic:destroy()
    self.graphic = self:add(Sprite(0, 0, "minigames/fighter/ui"))
end

return UI
