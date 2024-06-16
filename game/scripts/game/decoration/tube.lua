local FlagManager = require "flagmanager"
local Sprite = require "base.sprite"

local Tube = Sprite:extend("Tube")

function Tube:new(...)
    Tube.super.new(self, ...)
    self.offset.y = 0
end

function Tube:done()
    self:setImage("decoration/tube_" .. self.player:lower(), true)

    if self.scene.inMenu then
        self.anim:set("idle_off")
    else
        self.empty = true
        self.anim:set("empty")
    end

    if not self.empty then
        self.topLightSource = self.scene:addLightSource(self, 75, 35)
        self.topLightSource:centerY(self:top() + 16)
        self.topLightSource.visible = false

        self.bottomLightSource = self.scene:addLightSource(self, 75, 35)
        self.bottomLightSource:centerY(self:bottom() - 16)
        self.bottomLightSource.visible = false

        self.dimLightSource = self.scene:addLightSource(self, 0, 0)
        self.dimLightSource:center(self:center())
        self.dimLightSource.visible = false

        self.overallLightSource = self.scene:addLightSource(self, 100, 150)
        self.overallLightSource:center(self:center())
        self.overallLightSource.visible = false

        self.anim:getAnimation("startup")
            :onFrame(2, self.wrap(self.topLightSource, { visible = true }))
            :onFrame(3, self.wrap(self.bottomLightSource, { visible = true }))
            :onFrame(6, function()
                self.overallLightSource.visible = true
            end)
            :onFrame(7, self.wrap(self.overallLightSource, { visible = false }))
            :onFrame(8, function()
                self.overallLightSource.visible = true
                self.dimLightSource.visible = false
                self.bottomLightSource.visible = false
                self.topLightSource.visible = false
                self.overallLightSource.radiusX = 80
                self.overallLightSource.radiusY = 120
                self.scene:addLightSource(self, 80, 120)
            end)
    end
end

-- USE THIS FOR THE TRAILER
-- function Tube:startUp()
--     self:tween(self.dimLightSource, 2, { radiusX = 50, radiusY = 75 }):onstart(function()
--         self.dimLightSource.visible = true
--     end)
--         :oncomplete(function()
--             self.anim:set("startup")
--         end)
-- end

function Tube:startUp()
    -- self:tween(self.dimLightSource, .5, { radiusX = 50, radiusY = 75 }):onstart(function()
    --     self.dimLightSource.visible = true
    -- end)

    -- local showLight = function()
    self.dimLightSource.radiusX = 50
    self.dimLightSource.radiusY = 75
    self.dimLightSource.visible = true
    self.dimLightSource.alpha = 0

    self:tween(self.dimLightSource, .3, { alpha = 1 })
    -- end

    -- if self.player == "Peter" then
    --     self:delay(.05, showLight)
    -- else
    --     showLight()
    -- end

    self.anim:set("startup")
end

function Tube:spawnPlayer()
    self.anim:set("empty")

    if self.player:lower() == "peter" then
        local peter = self.scene:spawnPeter(self:centerX(), self.y)
        peter.inCutscene = true
    else
        local timon = self.scene:spawnTimon(self:centerX(), self.y)
        timon.flip.x = true
        timon.inCutscene = true
    end
end

return Tube
