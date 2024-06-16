local SFX = require "base.sfx"
local Rect = require "base.rect"
local Sprite = require "base.sprite"
local Scene = require "base.scene"

local FightTransition = Scene:extend("Transition")

local Placement = require "base.components.placement"

function FightTransition:new()
    FightTransition.super.new(self, -10, -10, WIDTH * 2 + 40, HEIGHT * 2 + 20)
    self:setBackgroundAlpha(0)
    self.origin:set(0, 0)
    self.scale:set(.5, .5)

    self.peterGray = self:addOverlay(Sprite(20, 20, "transition/fighter/background_left_gray"))
    self.timonGray = self:addOverlay(Sprite(self.width / 2, 20, "transition/fighter/background_right_gray"))
    self.peterGray.z = 10
    self.peterGray.z = 10

    self.peterGray:setStart()
    self.timonGray:setStart()

    self.peterGray.x = -self.peterGray.width
    self.timonGray.x = self.width

    self.peterEyeShine = self:addOverlay(Sprite(259, 185, "transition/fighter/shine_red"))
    self.timonEyeShine = self:addOverlay(Sprite(1055, 162, "transition/fighter/shine_blue"))
    self.peterEyeShine.z = -1
    self.peterEyeShine.alpha = 0
    self.peterEyeShine.scale:set(0, 0)
    self.timonEyeShine.z = -1
    self.timonEyeShine.alpha = 0
    self.timonEyeShine.scale:set(0, 0)

    self.backgroundColored = self:addOverlay(Sprite(20, 20, "transition/fighter/background_color"))
    self.backgroundColored.z = -1
    self.backgroundColored.visible = false

    self.peterColor = self:addOverlay(Sprite(20, 20, "transition/fighter/peter"))
    self.timonColor = self:addOverlay(Sprite(self.width / 2, 20, "transition/fighter/timon"))
    self.peterColor.z = -3
    self.timonColor.z = -3
    self.peterColor.visible = false
    self.timonColor.visible = false

    self.lightning1 = self:addOverlay(Sprite(20, -self.height, "transition/fighter/lightning1"))
    self.lightning2 = self:addOverlay(Sprite(20, -self.height, "transition/fighter/lightning2"))
    self.lightning3 = self:addOverlay(Sprite(20, -self.height, "transition/fighter/lightning3"))

    self.lightningList = list({
        self.lightning1,
        self.lightning2,
        self.lightning3,
    })

    self.lightningList(function(e)
        e:centerX(self.width / 2)
        e.z = -4
        e.alpha = 0
        e.visible = false
    end)

    self.names = self:addOverlay(Sprite(20, 17, "transition/fighter/names"))
    self.names.z = -2
    self.names.visible = false

    self.vs = self:addOverlay(Sprite(0, 0, "transition/fighter/vs"))
    self.vs:center(WIDTH + 17, HEIGHT)
    self.vs.visible = false
    self.vs.z = -10

    self.sfx = SFX("sfx/transition/fighter")

    self.whiteOverlay = self:addOverlay(Rect(0, 0, self.width, self.height))
    self.whiteOverlay:setColor(255, 255, 255)
    self.whiteOverlay.alpha = 0
    self.whiteOverlay.z = -100

    self.overlay(function(e)
        if e:is(Sprite) then
            e:setFilter("linear")
        end
    end)
    self:setFilter("linear")
end

function FightTransition:update(dt)
    FightTransition.super.update(self, dt)
end

function FightTransition:start(callback, short)
    self.inProgress = true
    self.visible = true

    self.sfx:play()

    local speed = .5

    self:tween(self.peterGray, .5, { x = self.peterGray.start.x }):ease("quintin")
    self:tween(self.timonGray, .5, { x = self.timonGray.start.x }):ease("quintin")
        :oncomplete(function()
            self:shake(5, .2)
            self.scene:rumble(.3, .3)
            self:setBackgroundAlpha(1)
            -- self:delay(1, function()
            -- self.scene.music:play("minigames/fighter/transition")
            -- end)
        end)
        :wait(.5, function()
            local duration = 1.3
            self:tween(self.peterEyeShine, duration, { alpha = 1 }):ease("quadin")
            self:tween(self.timonEyeShine, duration, { alpha = 1 }):ease("quadin")
            self:tween(self.peterEyeShine.scale, duration, { x = 1, y = 1 }):ease("backout")
            self:tween(self.timonEyeShine.scale, duration, { x = 1, y = 1 }):ease("backout")
                :after(self.whiteOverlay, .15, { alpha = 1 })
                :delay(.6)
                :oncomplete(function()
                    self.backgroundColored.visible = true
                    self.names.visible = true
                    self.peterColor.visible = true
                    self.timonColor.visible = true
                    self.peterGray.visible = false
                    self.timonGray.visible = false
                    self:shake(10, .3)
                    self.scene:rumble(.5, .6)
                    self.peterColor:shake(20, .3)
                    self.timonColor:shake(20, .3)

                    self.vs.visible = true

                    self.names.visible = true

                    self.lightningList(function(e, i)
                        e.visible = true
                        self:tween(e, i / 10, { y = 0, alpha = 1 })
                            :after(.2, { alpha = 0 })
                    end)
                end)
                :after(self.whiteOverlay, .1, { alpha = 0 })
        end)

    local delay = short and 11.5 or 11.5

    self:delay(delay, callback)
end

function FightTransition:finish(fromLeft, callback)
    local speed = .3
    if fromLeft then
        for i, v in ipairs(self.rectangles) do
            self:tween(v, _.random(speed), { x = WIDTH })
        end
    else
        for i, v in ipairs(self.rectangles) do
            self:tween(v, _.random(speed), { x = -WIDTH })
        end
    end

    self:delay(speed, function()
        if callback then callback() end
        self.inProgress = false
        self.visible = false
    end)
end

function FightTransition:isInProgress()
    return self.inProgress
end

return FightTransition
