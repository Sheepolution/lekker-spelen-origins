local Player = require "characters.players.player"
local Asset = require "base.asset"
local Entity = require "base.entity"

local Water = Entity:extend("Water")

function Water:new(...)
    Water.super.new(self, ...)

    self.solid = 2
    self.immovable = true
end

function Water:done()
    self.columns = self.width / 32
    self.rows = self.height / 32

    if not self.topWater then
        local water = Water()
        water.topWater = true
        water.width = self.width
        water.height = 32

        water.z = ZMAP.Timon + 1
        water.x = self.x
        water.y = self.y - 8
        self.mapLevel:add(water)

        self.z = ZMAP.Peter - 1
        self:setImage("tilesets/water_center", true)

        self.underWaterSprite = Asset.image("tilesets/water")
    else
        self:setImage("tilesets/water_center_top", true)
    end

    self.width = self.columns * 32
    self.height = self.rows * 32

    if not self.topWater then
        self:addHitbox("detect", 0, 0, self.width, self.height, true)
        if self.back then
            self:addHitbox("solid", 0, -32, self.width, 32, nil, true)
        else
            self:addHitbox("solid", 0, self.height - 64, self.width, 32, nil, true)
        end
    end

    self.solid = 0

    self:delay(1.2, function()
        self.solid = 2
        self.activated = true
    end)
end

function Water:update(dt)
    Water.super.update(self, dt)
end

function Water:draw()
    if self.back then return end

    for i = 0, self.columns - 1 do
        self.offset.x = i * 32
        Water.super.draw(self)
    end

    if not self.topWater then
        love.graphics.draw(self.underWaterSprite, self.x, self.y + 32, 0, self.columns, (self.rows - 1))
    end
end

function Water:onOverlap(i)
    if i.myHitbox.name == "detect" then
        if i.e:is(Player) then
            if self.activated then
                if self.back then
                    self.scene:startWaterTransition(self, i.e, true, self.direction)
                else
                    self.scene:startWaterTransition(self, i.e)
                end
            end
        end

        return false
    end

    return Water.super.onOverlap(self, i)
end

return Water
