local Cart = require "characters.players.konkie.cart"
local Entity = require "base.entity"
local Scene = require "base.scene"

local KonkieLevel2 = Scene:extend("KonkieLevel2")

function KonkieLevel2:new(x, y, mapLevel)
    KonkieLevel2.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function KonkieLevel2:done()
    self.background:add("flora/set/3", 4028, 573)
    self.background:add("flora/set/4", 4098, 573)
    self.background:add("plafond_slierten4", 4277, 376)
    self.background:add("cam_links_diagonaal", 4515, 404)

    local rail = self.scene:findEntityWithTag("Rail")
    rail:buildStraight(300)
    rail:buildFinish()
    local path = rail:getPath()
    local cart = self.mapLevel:add(Cart(rail.x + path[1].x, rail.y + path[1].y))
    cart:setPath(rail, path)
    cart:positionCart()
    cart.anim:set("peter")
    cart.hasTimon = true
    self.cart = cart
    self.cart.driving = not self.scene.doorTransition

    if not self.scene.doorTransition then
        self.scene.map:follow(self.scene.cameraFollow)
        self.scene.camera:zoomTo(1)
        self.scene.camera.lerp = CAMERA_LERP

        if not self.scene.peter then
            self.scene:spawnPeter(0, 0)
        end

        if not self.scene.timon then
            self.scene:spawnTimon(0, 0)
        end

        self.scene.players:center(self.cart:centerX() + 10, self.cart:centerY())
        self.scene.players:teleport()
        self.scene.cameraFollow:center(self.scene.peter:center())
        self.scene.camera:follow(self.scene.cameraFollow, true)
        self.scene.splitScreen = false

        self.scene.players(function(e)
            e.inControl = true
            e.visible = false
            e:stopMoving()
        end)
    end
end

function KonkieLevel2:update(dt)
    KonkieLevel2.super.update(self, dt)
    if self.cart.x > self.mapLevel.x + 130 and self.cart.driving then
        self.cart.driving = false
        self.cart:stopMoving()
        self.scene.players:center(self.cart:centerX() + 100, self.cart:centerY())
        self.scene.players:teleport()
        self.scene.players(function(e)
            e.visible = true
            e.solid = 1
        end)

        self.cart.anim:set("empty")
        self.cart.hasTimon = false
    end
end

return KonkieLevel2
