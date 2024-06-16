local Point = require "base.point"
local Interactable = require("interactable", ...)

local Wall = Interactable:extend("Wall")

local function lazy()
    local Enemy = require "creatures.enemy"
    Wall:addExclusiveOverlap(Enemy)
    lazy = nil
end

Wall.offAlpha = .1
Wall.onAlpha = .7

function Wall:new(...)
    Wall.super.new(self, ...)

    if lazy then
        lazy()
    end

    self:setImage("interactables/tile", true)
    self:addOffset(0, -8)
    self.solid = 2
    self.tileSize = self.width
    self.immovable = true
    self.unsafeForPlayer = false
    self.tweens = list()

    self.sfx = {
        on = "hologram_activate",
        off = "hologram_deactivate",
    }
    self.z = 1
end

function Wall:done()
    Wall.super.done(self)
    self.columns = self.width / self.tileSize
    self.rows = self.height / self.tileSize
    self:clearHitboxes()
    self.hitbox = self:addHitbox(self.width, self.height)
    self.data = {}

    for i = 1, self.rows do
        for j = 1, self.columns do
            self.data[i .. "_" .. j .. "_alpha"] = self.on and self.onAlpha or self.offAlpha
        end
    end

    self.linePosition = Point(self:center())
end

function Wall:update(dt)
    Wall.super.update(self, dt)
end

function Wall:draw()
    for i = 1, self.rows do
        for j = 1, self.columns do
            self.offset.x = (j - 1) * self.tileSize
            self.offset.y = (i - 1) * self.tileSize

            if i == 1 then
                if self.rows == 1 then
                    self.anim:set("on_top" .. (self.player and ("_" .. self.player:lower()) or ""))
                else
                    self.anim:set("on_half" .. (self.player and ("_" .. self.player:lower()) or ""))
                end
            else
                self.anim:set("on" .. (self.player and ("_" .. self.player:lower()) or ""))
            end

            self.alpha = self.data[i .. "_" .. j .. "_alpha"]

            Wall.super.draw(self)
        end
    end
end

function Wall:onStateChanged()
    Wall.super.onStateChanged(self)
    self.tweens:foreach(function(t) t:stop() end):clear()

    for k, v in pairs(self.data) do
        self.tweens:add(self:tween(self.data, .5,
            { [k] = self.on and self.onAlpha or self.offAlpha })):ease("circout")
    end
end

function Wall:onOverlap(i)
    if not self.on then
        return false
    end

    if self.player then
        if i.e.tag == self.player then
            return false
        end
    end

    Wall.super.onOverlap(self, i)
end

return Wall
