local Enemy = require "creatures.enemy"

local LekkerChatCart = Enemy:extend("LekkerChatCart")

function LekkerChatCart:new(cart, x)
    LekkerChatCart.super.new(self, x, 0)
    self:setImage("creatures/enemies/lekkerchat", true)
    self:addHitbox(self.width * .8, self.height * .8)
    self.cart = cart
    self.distance = 600
    self.angle = _.randomAngle()
    self.moveDir = _.scoin()
    self.autoFlip.x = false

    self.changeDirectionInterval = step.every(3, 10)
    self.hurtsPlayer = true
end

function LekkerChatCart:update(dt)
    LekkerChatCart.super.update(self, dt)

    if self.changeDirectionInterval(dt) then
        self.moveDir = _.scoin()
    end

    if not self.died then
        self.distance = self.distance - 30 * dt

        self.angle = self.angle + dt * .8 * self.moveDir
        self.angleOffset = -self.angle

        local x = self.x
        local dx = _.cos(self.angle)
        local dy = _.sin(self.angle)

        self.x = self.cart:centerX() + self.distance * dx
        self.y = self.cart:centerY() + self.distance * dy

        -- Flip when on the left half angle
        self:lookAt(self.cart)
    end
end

return LekkerChatCart
