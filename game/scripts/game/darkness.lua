local Input = require "base.input"
local lightShader = require "shaders.light"
local Rect = require "base.rect"
local Circle = require "base.circle"
local Point = require "base.point"
local Flow = require "base.components.flow"

local Darkness = Rect:extend("Darkness")

Darkness:implement(Flow)

function Darkness:new()
    Darkness.super.new(self, 0, 0, WIDTH, HEIGHT)
    self:setColor(0, 0, 0)
    self.alpha = .8
    self.lightSources = list()
end

function Darkness:update(dt)
    self.lightSources:filter_inplace(function(e)
        return (not e.destroyed)
            and (e.overlay or self.scene.entities:contains(e.parent))
            and (not e.overlay or self.scene.overlay:contains(e.parent))
    end)

    Flow.update(self, dt)
end

function Darkness:draw()
    if not self.visible or self.alpha == 0 then
        return
    end

    local cameras = self.scene.splitScreen and { self.scene.cameraPeter, self.scene.cameraTimon } or
        { self.scene.camera }

    local activeLightSources = self.lightSources:filter(function(e) return e.visible and (e.radiusX or e.radius) > 0 end)

    for i, v in _.ripairs(activeLightSources) do
        if v.repeating then
            for j = 1, v.repeating do
                activeLightSources:add(v)
            end
        end
    end

    if #activeLightSources == 0 then
        Darkness.super.draw(self)
        return
    end

    for i, camera in ipairs(cameras) do
        self:set(camera:getWindow())
        lightShader:send("lightPositions",
            unpack(activeLightSources:map(function(e)
                local x = e:centerX() + e.offset.x
                local y = e:centerY() + e.offset.y
                return e.overlay and { x, y } or
                    { camera:toScreen(x, y) }
            end)))
        lightShader:send("lightRadii",
            unpack(activeLightSources:map(function(e)
                return e.radiusX and { e.radiusX * camera.zoom, e.radiusY * camera.zoom } or
                    { e.radius * camera.zoom, e.radius * camera.zoom }
            end)))
        lightShader:send("lightOpacity", unpack(activeLightSources:map(function(e) return e.alpha end)))
        lightShader:send("lightCount", #activeLightSources)
        lightShader:send("gradientDefault", self.alpha)
        love.graphics.setShader(lightShader)
        Darkness.super.draw(self)
        love.graphics.setShader()
    end
end

function Darkness:addLightSource(parent, radiusX, radiusY, overlay)
    local lightSource = Circle(parent:center())
    lightSource.offset = Point()
    lightSource.parent = parent
    lightSource.overlay = overlay

    if radiusY then
        lightSource.radiusX = radiusX
        lightSource.radiusY = radiusY
    else
        lightSource.radius = radiusX
    end

    self.lightSources:add(lightSource)

    return lightSource
end

Darkness.setDarkness = Darkness.setAlpha

function Darkness:toDarkness(darkness, duration)
    self:tween(duration or 1, { alpha = darkness })
end

return Darkness
