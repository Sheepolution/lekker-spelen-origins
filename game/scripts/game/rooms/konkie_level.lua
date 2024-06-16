local Cart = require "characters.players.konkie.cart"
local Entity = require "base.entity"
local Scene = require "base.scene"

local KonkieLevel = Scene:extend("KonkieLevel")

function KonkieLevel:new(x, y, mapLevel)
    KonkieLevel.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function KonkieLevel:done()
    self.background:add("sets/bureau4", 540, 788)
    self.background:add("sets/chemistry2", 1641, 776)
    self.background:add("flora/set/4", 768, 884)
    self.background:add("sets/bureau6", 2292, 813)
    self.background:add("flora/set/7", 3448, 864)
    self.background:add("flora/set/5", 6929, 864)
    self.background:add("flora/set/2", 7094, 893)
    self.background:add("deur_planken", 9106, 753)
    self.background:add("sets/bureau7", 9989, 794)
    self.background:add("bord_cart", 13620, 496)
    self.background:add("sets/bureau10", 12986, 532)

    local rail = self.scene:findEntityWithTag("Rail")
    rail:buildStraight(2000)
    rail:buildFinish()
    local path = rail:getPath()
    local cart = self.mapLevel:add(Cart(rail.x + path[1].x, rail.y + path[1].y))
    cart:setPath(rail, path)
    self.cart = cart
    self.cart.capturesPlayers = true
end

function KonkieLevel:update(dt)
    KonkieLevel.super.update(self, dt)
    if self.cart.x > self.mapLevel.x + self.mapLevel.width then
        -- scene.map.useTransition = false
        if not self.transitionEvent then
            self.transitionEvent = self.scene:event(function()
                local scene = self.scene
                scene.transitionBars:start(false, scene.map)
                self.scene.coil.wait(.4)
                scene.map:follow()
                scene.map.useTransition = false
                scene:setLevel("Konkie_cart")
                scene.map.useTransition = true
                scene.transitionBars:finish(false)
            end, nil, 1)
        end
    end
end

return KonkieLevel
