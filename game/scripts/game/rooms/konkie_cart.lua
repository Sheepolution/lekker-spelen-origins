local CartBackground = require "decoration.cart_background"
local Cart = require "characters.players.konkie.cart"
local Entity = require "base.entity"
local Rail = require "tiles.rail"
local LekkerChatCart = require "creatures.enemies.lekkerchat_cart"
local GoochemCart = require "creatures.enemies.goochem_cart"
local Scene = require "base.scene"

local KonkieCart = Scene:extend("KonkieCart")

function KonkieCart:new(x, y, mapLevel)
    KonkieCart.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function KonkieCart:done()
    self.cart = self.mapLevel:add(Cart(0, 0))

    self:createRails()
    self.rails[#self.rails]:buildFinish()
    local rail = self.rails[1]

    local path = rail:getPath()

    self.cart:setPath(rail, path)
    self.cart.driving = true
    self.cart.anim:set("heart_3")
    self.cart.inControl = true
    self.cart.hasTimon = true
    self.cart.timon.anim:set("wind")
    self.cart.room = self

    self.mapLevel.width = self.rails[#self.rails]:endX() - self.mapLevel.x - 500

    local x, y, w, h = self.scene.camera:getWorld()
    self.scene.camera:setWorld(x, y, self.mapLevel.width, h)

    self.cameraFollow = Entity()
    self.cameraFollow:set(0, 0, 1, 1)
    self.cameraFollow:center(self.cart:center())
    self.scene.camera:follow(self.cameraFollow, true)
    self.scene.camera.lerp = 0

    self.cartDistanceX = 450
    self.cartDistanceY = 150
    self.cartZoom = .5
    self.timer = 0

    self.background = self.mapLevel:add(CartBackground(self.mapLevel.x, self.mapLevel.y))
    self.background.z = 10000

    self.lekkerChatCartInterval = step.every(2, 4)
    self.scene.peter.visible = true
    self.scene.timon.visible = true

    self.scene.map:follow()

    self.forwardX = 0
    self:tween(5, { forwardX = 75 })

    self.scene.camera.flooring = false
end

function KonkieCart:update(dt)
    self.cartDistanceX = self.cartDistanceX - self.cartDistanceX * dt
    self.cartDistanceY = self.cartDistanceY - self.cartDistanceY * dt
    self.cartZoom = self.cartZoom - self.cartZoom * dt

    self.timer = self.timer + dt

    local x, y = self.cart:center()
    self.cameraFollow.x = x + _.sin(self.timer * PI) * self.cartDistanceX + self.forwardX
    self.cameraFollow.y = y - _.cos(self.timer * PI * .5) * self.cartDistanceY

    local zoom = _.sin(self.timer * PI * .5) * self.cartZoom

    self.scene.camera:zoomTo(1 + zoom)

    if self.lekkerChatCartInterval(dt) then
        -- FINAL: Turn back on
        if not DEBUG then
            self.mapLevel:add(LekkerChatCart(self.cart))
        end
    end

    if self.cart.x > self.mapLevel.x + self.mapLevel.width then
        if not self.transitionEvent then
            self.transitionEvent = self:event(function()
                local scene = self.scene
                scene.transitionBars:start(false, scene.map)
                self.coil.wait(.4)
                scene.map:follow()
                scene.map.useTransition = false
                self.scene.camera.flooring = true
                scene:setLevel("Konkie_level2")
                scene.map.useTransition = true
                scene.transitionBars:finish(false)
            end, nil, 1)
        end
    end

    if self.cart.y > self.mapLevel.y + self.mapLevel.height then
        self:die()
    end

    KonkieCart.super.update(self, dt)
end

function KonkieCart:createRails()
    self.rails = {}

    local rail = self:createRail(self.mapLevel.x, self.mapLevel.y + self.mapLevel.height / 2)
    rail:buildStraight(2000)
    rail:buildCurveUp(800, 500)

    rail = self:createRail(0, 300)
    rail:buildCurveUp(400, 250)
    rail:buildStraight(500)

    rail = self:createRail(250, 0)
    rail:buildStraight(300)

    rail = self:createRail(250, 0)
    rail:buildStraight(300)

    rail = self:createRail(250, 0)
    rail:buildStraight(200)
    rail:buildCurveDown(400, 600)
    rail:buildStraight(500)
    rail:buildCurveUp(500, 300)

    rail = self:createRail(250, -100)
    rail:buildCurveUp(500, 300)

    rail = self:createRail(250, -100)
    rail:buildStraight(500)
    rail:buildCurveDown(200, 300)
    rail:buildStraight(100)

    rail = self:createRail(1000, -150)
    rail:buildStraight(750)
    self:addGoochem(rail, 749)

    rail = self:createRail(-1750, 150)
    rail:buildStraight(4000)

    self:addGoochem(rail, 3000)

    rail = self:createRail(350, 100)
    rail:buildCurveDown(200, 300)
    rail:buildStraight(200)

    rail = self:createRail(350, 100)
    rail:buildCurveDown(200, 300)
    rail:buildStraight(200)

    rail = self:createRail(0, 0)
    rail:buildStraight(2500)

    self:addGoochem(rail, 1500)

    rail = self:createRail(-200, -150)
    rail:buildStraight(1000)
    self:addGoochem(rail, 600)

    rail = self:createRail(-200, -150)
    rail:buildStraight(1000)
    self:addGoochem(rail, 600)

    rail = self:createRail(-200, -150)
    rail:buildStraight(1000)
    self:addGoochem(rail, 600)

    rail = self:createRail(-200, -150)
    rail:buildStraight(2000)

    rail = self:createRail(250, 0)
    rail:buildStraight(200)

    rail = self:createRail(250, 0)
    rail:buildStraight(200)

    rail = self:createRail(250, 0)
    rail:buildStraight(200)

    rail = self:createRail(250, 0)
    rail:buildStraight(1000)
    self:addGoochem(rail, 600)
    rail:buildCurveDown(700, 800)
    rail:buildStraight(200)
    rail:buildCurveUp(400, 200)

    rail = self:createRail(325, 0)
    rail:buildCurveUp(400, 300)

    rail = self:createRail(325, 0)
    rail:buildCurveUp(400, 300)

    rail = self:createRail(325, 0)
    rail:buildCurveUp(400, 300)

    rail = self:createRail(325, 100)
    rail:buildStraight(1000)
    rail:buildCurveDown(700, 800)
    self:addGoochem(rail, 600)
    rail:buildStraight(1000)
    rail:buildLooping(400)
    rail:buildStraight(1500)

    rail = self:createRail(350, 0)
    rail:buildStraight(1300)
    self:addGoochem(rail, 800)
end

function KonkieCart:createRail(x, y)
    local last = self.rails[#self.rails]
    if last then last:buildFinish() end
    local rail = self.mapLevel:add(Rail(last and (last:endX() + (x or 0)) or x, last and (last:endY() + (y or 0)) or y))
    table.insert(self.rails, rail)
    return rail
end

function KonkieCart:addGoochem(rail, position, section)
    local goochem_cart = self.mapLevel:add(GoochemCart(self.cart))
    local path = rail:getPath()
    goochem_cart:setPath(rail, path)
    goochem_cart.pathPosition = position
    goochem_cart.pathIndex = section or 1
    goochem_cart:positionCart()
end

function KonkieCart:die()
    if self.died then return end
    self.died = true
    if not self.scene.peter then
        self.scene:spawnPeter(self.cart:center())
    end

    if not self.scene.timon then
        self.scene:spawnTimon(self.cart:center())
    end

    self.scene.peter.died = true
    self.scene.timon.died = true

    self.scene.players:center(self.cart:center())
end

return KonkieCart
