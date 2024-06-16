local Sprite = require "base.sprite"

local Logo = Sprite:extend("Logo")

function Logo:new(x, y)
    Logo.super.new(self)
    self:setImage("menu/logo", true)
    self.anim:set("off")

    self:center(WIDTH / 2, HEIGHT / 2)
    self.scale:set(2)

    self.z = 10

    self.cables = Sprite(-2, 0, "menu/dark_cables")
    self.cables.origin:set(0, 0)

    self.mask = Sprite(0, 0, "menu/logo_gradient")
    self.cables:addMask(self.mask)

    self.fillValue = 0
    self.fillTube = false
    self.visible = false
end

function Logo:done()
    Logo.super.done(self)
    self.lightSourceAll = self.scene:addLightSource(self, 120, 110, true)
    self.lightSourceAll:set(self:getRelativePosition(0, -40))
    self.lightSourceAll.visible = false

    self.lightSourceAll2 = self.scene:addLightSource(self, 120, 110, true)
    self.lightSourceAll2:set(self:getRelativePosition(0, -40))
    self.lightSourceAll2.visible = false

    self.lightSourceBottom = self.scene:addLightSource(self, 80, 30, true)
    self.lightSourceBottom:set(self:getRelativePosition(0, 100))
    self.lightSourceBottom.visible = false

    self.lightSourceLeft = self.scene:addLightSource(self, 8, 8, true)
    self.lightSourceLeft:set(self:getRelativePosition(-140, -60))
    self.lightSourceLeft.visible = false

    self.lightSourceRight = self.scene:addLightSource(self, 8, 8, true)
    self.lightSourceRight:set(self:getRelativePosition(140, -60))
    self.lightSourceRight.visible = false

    self.anim:getAnimation("startup2")
        :onFrame(2, self.wrap(self.lightSourceBottom, { visible = true }))
        :onFrame(3, self.wrap(self.lightSourceBottom, { visible = false }))
        :onComplete(self.wrap(self.lightSourceBottom, { visible = true }))
end

function Logo:update(dt)
    Logo.super.update(self, dt)
    if self.fillTube then
        self.lightSourceLeft.visible = true
        self.lightSourceRight.visible = true

        self.fillValue = self.fillValue + dt
        self.cables:send("mask_gradient_threshold", self.fillValue)

        if self.fillValue >= 1 then
            self.fillTube = false

            if not self.hidden then
                self:tween(self.lightSourceLeft, .2, { alpha = 0 })
                self:tween(self.lightSourceRight, .2, { alpha = 0 })
                self:delay(.2, function()
                    self.anim:set("startup2")

                    self.lightSourceBottom.visible = true
                    self.lightSourceLeft.visible = false
                    self.lightSourceRight.visible = false
                    self.lightSourceAll.alpha = 1
                    self.lightSourceAll2.visible = true
                end)
            else
                self.lightSourceLeft.alpha = 0
                self.lightSourceRight.alpha = 0
            end
        end

        local leftY = -60 + 160 * self.fillValue
        local rightY = -60 + 120 * self.fillValue
        self.lightSourceLeft:set(self:getRelativePosition(-150, leftY))
        self.lightSourceRight:set(self:getRelativePosition(140, rightY))
    end
end

function Logo:draw()
    if not self.visible then return end
    Logo.super.draw(self)
    self.cables:drawAsChild(self, nil, nil, false)
end

function Logo:startUp()
    if self.hidden then return end
    self.visible = true
    -- self:setColor(150, 150, 150)
    self.anim:set("startup")
    self.lightSourceAll.visible = true
    self.lightSourceAll2.visible = false
    self.lightSourceAll.alpha = 0
    self.lightSourceAll2.alpha = 0
    self.lightSourceAll1Tween = self:tween(self.lightSourceAll, .5, { alpha = 1 })
    self.lightSourceAll2Tween = self:tween(self.lightSourceAll2, .5, { alpha = 1 })
    -- self:delay(.1, self.wrap(self.lightSourceAll2, { visible = true }))
    self:delay(1, self.wrap({ fillTube = true }))
end

function Logo:hide()
    local duration = .3

    self.fillValue = 1

    if self.lightSourceAll1Tween then
        self.lightSourceAll1Tween:stop()
        self.lightSourceAll2Tween:stop()
    end

    self.hidden = true

    self:tween(duration, { alpha = 0 })
    self:tween(self.lightSourceAll, duration, { alpha = 0 })
    self:tween(self.lightSourceAll2, duration, { alpha = 0 })
    self:tween(self.lightSourceBottom, duration, { alpha = 0 })
    return duration
end

return Logo
