local gamera = require "libs.gamera"
local Flow = require "base.components.flow"
local Point = require "base.point"
local Class = require "base.class"

local Camera = Class:extend("Camera")

Camera:implement(Flow)

function Camera:__index(k)
    local instanceProperty = rawget(self, k)
    if instanceProperty then
        return instanceProperty
    end

    local classProperty = rawget(Camera, k)
    if classProperty then
        return classProperty
    end

    local camera = rawget(self, 'camera')
    local cameraProperty = camera[k]
    if cameraProperty then
        if type(cameraProperty) == 'function' then
            return function(obj, ...) return cameraProperty(camera, ...) end
        else
            return cameraProperty
        end
    end
end

-- TODO: Improve this class

function Camera:new(x, y, width, height)
    self.camera = gamera.new(x, y, width, height)
    self.camera:setWindow(x, y, width, height)
    self.followPoint = Point(0, 0)
    self.followingOffset = Point(0, 0)
    self.following = false
    self.zoom = 1
    self.lerp = 0
    self.flooring = true
    Flow.new(self)
end

function Camera:update(dt)
    if self.followObject then
        if self.lerp == 0 then
            self.followPoint.x = self.followObject:centerX()
            self.followPoint.y = self.followObject:centerY()
        else
            self.followPoint.x = _.lerp(self.followPoint.x, self.followObject:centerX(), dt * self.lerp)
            self.followPoint.y = _.lerp(self.followPoint.y, self.followObject:centerY(), dt * self.lerp)
        end
    end

    self.camera.scale = self.zoom

    self.camera:setPosition(self.followPoint.x + self.followingOffset.x,
        self.followPoint.y + self.followingOffset.y)

    Flow.update(self, dt)

    if self.flooring then
        self.camera.x = _.round(self.camera.x)
        self.camera.y = _.round(self.camera.y)
    end
end

function Camera:getCamera()
    return self.camera
end

function Camera:follow(e, teleport)
    if not e then
        self.followObject = nil
        self.following = false
        return
    end

    self.followObject = e
    self.following = true
    if teleport then
        self.followPoint.x = e:centerX()
        self.followPoint.y = e:centerY()
    end
end

function Camera:moveToPoint(x, y)
    self.followObject = nil
    self.followPoint.x = x
    self.followPoint.y = y
end

function Camera:moveToRelativePoint(x, y)
    self.followObject = nil
    self.followPoint.x = self.followPoint.x + x
    self.followPoint.y = self.followPoint.y + y
end

function Camera:tweenToPoint(x, y, duration, callback, lockon)
    local followObject = self.followObject

    self.followObject = nil
    self.followPoint:set(self.camera.x, self.camera.y)

    local tween = self:tween(self.followPoint, duration or 1, { x = x or self.x, y = y or self.y })

    tween:oncomplete(function()
        self.followObject = followObject

        if callback then
            callback()
        end
    end)

    return tween
end

function Camera:tweenToRelativePoint(x, y, duration, callback)
    return self:tweenToPoint(self.x + x, self.y + y, duration, callback)
end

function Camera:tweenToObject(obj, duration, callback)
    return self:tweenToPoint(obj:centerX(), obj:centerY(), duration,
        function()
            self:follow(obj)
            if callback then
                callback()
            end
        end)
end

function Camera:zoomTo(zoom, duration)
    if duration then
        local tween = self:tween(self, duration, { zoom = zoom })

        local start = self.zoom
        local target = zoom

        tween:onupdate(function()
            -- I have no idea what I'm doing here but it works
            local p = tween.progress
            p = 1 - p
            p = p * p
            p = 1 - p
            self.zoom = (start ^ (1 - p)) * target ^ p
        end)

        return tween
    else
        self.zoom = zoom
        self.camera.scale = self.zoom
    end
end

function Camera:set(t)
    for k, v in pairs(t) do
        self.camera[k] = v
    end
end

return Camera
