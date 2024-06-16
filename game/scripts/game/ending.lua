---@diagnostic disable: inject-field
local Rect = require "base.rect"
local Music = require "base.music"
local Sprite = require "base.sprite"
local Scene = require "base.scene"

local Ending = Scene:extend()

-- local Placement = require "base.components.placement"

function Ending:new(...)
    Ending.super.new(self, 0, 0, 1920, 1080)

    self.graphics = list({
        {
            "background"
        },
        {
            "background",
            "peter_timon",
            "wood_left",
            "wood_right",
            "orange",
        },
        {
            "timon",
            "peter",
        },
        {
            "peter_timon"
        },
        {
            "sunset"
        },
        {
            "wall",
            "explosion_background",
            "debris_1",
            "explosion_1",
            "debris_2",
            "explosion_2",
            "debris_3",
            "explosion_3",
        },
        {
            "peter_timon"
        },
        {
            "background",
            "debris_3",
            "debris_4",
            "debris_2",
            "snes",
            "debris_1",
            "debris_5",
        },
        {
            "background",
            "peter",
            "timon"
        },
        {
            "snes",
            "snes_blur"
        }
    })

    self.sprites = list()

    self.camera.flooring = false
end

function Ending:update(dt)
    if self.graphics then
        if #self.graphics > 0 then
            local graphics = self.graphics:shift()
            local sprites = {}
            self.sprites:add(sprites)
            for i, v in ipairs(graphics) do
                local sprite = self:add(Sprite(0, 0, "cutscenes/ending/" .. #self.sprites .. "/" .. v))
                sprite.z = -i - (#self.sprites * 10)
                sprite.visible = false
                sprite:setFilter("linear")
                sprite.rounding = false
                sprites[v] = sprite
            end
        else
            self.graphics = nil
            self:delay(.1, function()
                self.music = Music("music/cutscenes/ending")
                self.music:play("ending"):setLooping(false)
                self:scene1()
            end)
        end
        return
    end

    Ending.super.update(self, dt)
end

function Ending:draw()
    CANVAS:draw(function()
        Ending.super.draw(self)
    end)
end

function Ending:scene1()
    local background = self.sprites[1].background
    background.visible = true
    background.alpha = 0
    self:tween(background, 3, { alpha = 1 })

    self:delay(5.74, function()
        background.visible = false
        self:scene2()
    end)
end

function Ending:scene2()
    local background = self.sprites[2].background
    background.visible = true

    local peter_timon = self.sprites[2].peter_timon
    peter_timon.visible = true

    local wood_left = self.sprites[2].wood_left
    wood_left.visible = true

    local wood_right = self.sprites[2].wood_right
    wood_right.visible = true

    local orange = self.sprites[2].orange
    orange.visible = true
    orange.alpha = .001

    self.camera:moveToPoint(960, 540)
    self.camera:zoomTo(1.05, .1):ease("linear")

    peter_timon:set(937, 439)
    self:tween(peter_timon, 3.78, { y = 429 }):ease("quintout")
    self:tween(peter_timon.scale, 3.78, { x = 1.04 }):ease("quintout")

    wood_left:set(338, 248)
    self:tween(wood_left, 3.78, { x = 318 }):ease("quintout")

    wood_right:set(1379, 292)
    self:tween(wood_right, 3.78, { x = 1399 }):ease("quintout")

    self:delay(3.68, function()
        self:scene3()
    end)
end

function Ending:scene3()
    local timon = self.sprites[3].timon
    timon.visible = true

    local peter = self.sprites[3].peter
    peter.visible = true
    peter:set(1058, 404)
    self:tween(peter, 3.78, { y = 431 }):ease("quintout")

    self.camera:moveToPoint(970, 540)
    self.camera:tweenToPoint(950, 540, 3):ease("quintout")

    self:delay(3.64, function()
        self:scene4()
    end)
end

function Ending:scene4()
    local peter_timon = self.sprites[4].peter_timon
    peter_timon.visible = true
    peter_timon.alpha = 0
    self:tween(peter_timon, 1, { alpha = 1 })

    self:delay(3.94, function()
        self:scene5()
    end)
end

function Ending:scene5()
    local sunset = self.sprites[5].sunset
    sunset.visible = true

    self.camera:moveToPoint(960, 540)
    self.camera:zoomTo(1)
    self.camera:zoomTo(1.05, 13):ease("linear")

    self:delay(13, function()
        self:scene6()
    end)
end

function Ending:scene6()
    local wall = self.sprites[6].wall
    wall.visible = true
    wall.alpha = 0
    wall:bottom(1080)
    self:tween(wall, .5, { alpha = 1 })
    self:tween(wall, 1, { y = 0 }):ease("linear")

    self:delay(.8, function()
        self.camera:zoomTo(1)
        local explosion_background = self.sprites[6].explosion_background
        explosion_background.visible = true

        local explosion_1 = self.sprites[6].explosion_1
        explosion_1.visible = true

        local explosion_2 = self.sprites[6].explosion_2
        explosion_2.visible = true

        local explosion_3 = self.sprites[6].explosion_3
        explosion_3.visible = true

        local debris_1 = self.sprites[6].debris_1
        debris_1.visible = true

        local debris_2 = self.sprites[6].debris_2
        debris_2.visible = true

        local debris_3 = self.sprites[6].debris_3
        debris_3.visible = true

        self:tween(debris_1.scale, 3.9, { x = 1.05, y = 1.05 }):ease("quintout")
        self:tween(debris_2.scale, 3.9, { x = 1.1, y = 1.1 }):ease("quintout")
        self:tween(debris_3.scale, 3.9, { x = 1.15, y = 1.15 }):ease("quintout")
        self:delay(3.5, function()
            self:fadeOut(1.7, function()
                self:delay(1.1, function()
                    for i, v in ipairs(self.sprites) do
                        for k, w in pairs(v) do
                            if type(k) == "string" then
                                w.visible = false
                            end
                        end
                    end
                    self:scene7()
                end)
            end, false)
        end)
    end)

    -- self:delay(13, function()
    --     self:scene5()
    -- end)
end

function Ending:scene7()
    self:fadeIn(.8, nil, false)

    self.camera:zoomTo(1.02)

    self.camera:moveToPoint(950, 540)
    self.camera:tweenToPoint(970, 540, 3):ease("quintout")

    local rect = self:add(Rect(0, 0, 1920, 1080))
    rect:setColor(255, 200, 200)
    rect.alpha = 0
    rect.z = -5000

    local timer = step.every(.05, .1)

    self:tween(rect, 5.5, { width = 1930 })
        :onupdate(function(dt)
            if timer(dt) then
                rect.alpha = _.random(0.01, .025)
            end
        end)

    local peter_timon = self.sprites[7].peter_timon
    peter_timon.visible = true

    self:delay(4.9, function()
        self:fadeOut(.5, function()
            self:delay(.7, function()
                peter_timon.visible = false
                rect.alpha = 0
                rect:destroy()
                self:scene8()
            end)
        end, false)
    end)
end

function Ending:scene8()
    self:fadeIn(.8, nil, false)
    self.camera:zoomTo(1)

    local background = self.sprites[8].background
    background.visible = true

    local snes = self.sprites[8].snes
    snes.visible = true

    local debris_1 = self.sprites[8].debris_1
    debris_1.visible = true

    local debris_2 = self.sprites[8].debris_2
    debris_2.visible = true

    local debris_3 = self.sprites[8].debris_3
    debris_3.visible = true

    local debris_4 = self.sprites[8].debris_4
    debris_4.visible = true

    local debris_5 = self.sprites[8].debris_5
    debris_5.visible = true


    snes:set(521, -241)
    snes.angle = -2
    self:tween(snes, .4, { x = 702, y = 321, angle = -1.1 })
        :after(5, { x = 841, y = 552, angle = -.7 }):ease("linear")
        :after(.2, { x = 1020, y = 1100, angle = 0 }):ease("quadin")

    debris_1:set(-200, -800)
    debris_1.angle = 1.5
    self:tween(debris_1, .4, { x = -75, y = 30, angle = 1.6 })
        :after(5, { x = 50, y = 600, angle = 1.7 }):ease("linear")
        :after(.2, { x = 125, y = 1600, angle = 1.9 }):ease("quadin")

    debris_2:set(200, -400)
    debris_2.angle = 1.5
    self:tween(debris_2, .4, { x = 338, y = 35, angle = 1.6 })
        :after(5, { x = 451, y = 301, angle = 1.7 }):ease("linear")
        :after(.2, { x = 500, y = 1100, angle = 1.9 }):ease("quadin")


    debris_3:set(-200, -800)
    debris_3.angle = 2.65
    self:tween(debris_3, .4, { x = 107, y = -355 })
        :after(5, { x = 290, y = -150, angle = 2.8 }):ease("linear")
        :after(.2, { x = 330, y = 1200, angle = 2.9 }):ease("quadin")

    debris_4:set(-200, -700)
    debris_4.angle = 2.65
    self:tween(debris_4, .4, { x = 107, y = -455 })
        :after(5, { x = 107, y = -450, angle = 2.8 }):ease("linear")
        :after(.5, { x = 530, y = 1400, angle = 2.9 }):ease("quadin")

    debris_5:set(100, -900)
    self:tween(debris_5, .5, { x = 430, y = 1400 }):ease("quadin"):delay(5.5)

    self:delay(2, function()
        self.camera:moveToPoint(960, 540)
        self.camera:zoomTo(2)
    end)
        :after(3.5, function()
            self.camera:zoomTo(1, 1.5):ease("quadout")
            self:fadeOut(1.5, function()
                self:delay(.9, function()
                    for i, v in ipairs(self.sprites) do
                        for k, w in pairs(v) do
                            if type(k) == "string" then
                                w.visible = false
                            end
                        end
                    end
                    self:scene9()
                end)
            end, false)
        end)
end

function Ending:scene9()
    self:fadeIn(.8, nil, false)

    local background = self.sprites[9].background
    background.visible = true

    local peter = self.sprites[9].peter
    peter.visible = true

    local timon = self.sprites[9].timon
    timon.visible = true

    timon:set(1031, 310)
    self:tween(timon, 4, { x = 1010, y = 284 })

    peter:set(0, 596)
    self:tween(peter, 4, { x = 26, y = 564 })

    self:delay(5.5, function()
        self:fadeOut(1, function()
            self:delay(.3, function()
                for i, v in ipairs(self.sprites) do
                    for k, w in pairs(v) do
                        if type(k) == "string" then
                            w.visible = false
                        end
                    end
                    self:scene10()
                end
            end)
        end, false)
    end)
end

function Ending:scene10()
    self:fadeIn(2.5, nil, false)
    self.camera:moveToPoint(960, 540)
    self.camera:zoomTo(1.05, 5.4)

    local snes = self.sprites[10].snes
    snes.visible = true

    local snes_blur = self.sprites[10].snes_blur
    snes_blur.visible = true

    self:tween(snes_blur, 3.2, { alpha = 0 }):ease("quintin"):delay(2.2)
    self:delay(9.6, function()
        self:setBackgroundColor(23, 23, 23)
        snes.visible = false
        self:delay(2, function()
            self.music:stop()
            self.scene:goToCredits()
        end)
    end)
end

return Ending
