local Text = require "base.text"
local json = require "libs.json"
local Sprite = require "base.sprite"

local Television = Sprite:extend("Television")

function Television:new(...)
    Television.super.new(self, ...)
    self:setImage("bosses/horsey/television")
    self.x = self.x + WIDTH / 2 - self.width / 2
    self.y = self.y + HEIGHT / 2 - self.height / 2 - 80

    self.directions = list()

    self.text = Text(-80, -16, "", "sansserifbldflf", 40)
    self.text:setFilter("linear")
    self.textSmall = Text(0, 0, "", "sansserifbldflf", 18)
    self.textSmall:setFilter("linear")
    self.arrowSmall = Sprite(-70, 5, "bosses/horsey/arrow", true)
    self.arrowSmall.scale:set(.8, .8)
    self.arrowSmall:setFilter("linear", "linear")
    self.arrowSmall.scale:set(.2, .2)

    self.arrowBig = Sprite(-150, 5, "bosses/horsey/arrow", true)
    self.arrowBig.scale:set(.8, .8)
    self.arrowBig:setFilter("linear", "linear")
    self.arrowBig.scale:set(.8, .8)
    self.arrowBig.offset:set(20, 0)
    self.arrowBig.visible = false

    self.maxTextWidth = 240
    self.maxSmallTextWidth = 1000

    self.monitor = Sprite(-243, 5, "bosses/horsey/monitor", true)

    self.hearts = list()
    for i = 0, 2 do
        local heart = self.hearts:add(Sprite(-271 + i * 28, 4, "bosses/horsey/heart", true))
        heart.anim:set("filled")
    end

    self.battery = Sprite(242, 5, "bosses/horsey/battery")

    self.batteryFill = Sprite()
    self.batteryFill:set(512, 36, self.battery.width - 1, self.battery.height)
    self.batteryFill:setColor(255, 100, 100)
    -- self.batteryFill.alpha = .5
    self.batteryFill.defaultHeight = self.batteryFill.height
    self.batteryFill.height = 0

    self.batteryButtonPressed = false

    self.batteryAmount = 0

    self.batteryText = Text(244, 50, "0%", "sansserifbldflf", 18)
    self.batteryText:setAlign("center", 200)

    self.showDirections = false

    self.directionCount = {
        left = 0,
        right = 0,
        up = 0,
        total = 0,
    }

    self.textMonitorTotalUp = Text(-260, 28, "0", "monogram_extended_custom", 16)
    self.textMonitorTotalLeft = Text(-260, 46, "0", "monogram_extended_custom", 16)
    self.textMonitorTotalRight = Text(-260, 65, "0", "monogram_extended_custom", 16)
    self.textMonitorTotal = Text(-260, 84, "0", "monogram_extended_custom", 16)

    self.textMonitorPercentUp = Text(-208, 28, "0%", "monogram_extended_custom", 16)
    self.textMonitorPercentLeft = Text(-208, 46, "0%", "monogram_extended_custom", 16)
    self.textMonitorPercentRight = Text(-208, 65, "0%", "monogram_extended_custom", 16)
    self.textMonitorPercents = list({
        self.textMonitorPercentUp,
        self.textMonitorPercentLeft,
        self.textMonitorPercentRight,
    })

    self.textMonitorPercents:setAlign("right", 200)

    self.textMonitorList = list({
        self.textMonitorTotalUp,
        self.textMonitorTotalLeft,
        self.textMonitorTotalRight,
        self.textMonitorTotal
    })

    self.textMonitorHash = {
        up = self.textMonitorTotalUp,
        left = self.textMonitorTotalLeft,
        right = self.textMonitorTotalRight,
        total = self.textMonitorTotal,
    }

    self.textMonitorHashPercent = {
        up = self.textMonitorPercentUp,
        left = self.textMonitorPercentLeft,
        right = self.textMonitorPercentRight,
    }

    self.textConnection = Text(0, -40, "- ERROR -\n\nCONNECTION LOST", "sansserifbldflf", 30)
    self.textConnection:setAlign("center", 600)
end

function Television:update(dt)
    Television.super.update(self, dt)

    self.monitor:update(dt)
end

function Television:draw()
    Television.super.draw(self)
    if self.showDirections then
        self.textSmall.offset.x = -50
        for i, v in ipairs(self.directions) do
            if i == 5 or i == 6 then
                goto continue
            end

            -- 1 and list length have max alpha, center of list 0 alpha. Gradient.
            self.textSmall.alpha = 1 - (math.abs(i - (#self.directions + 1) / 2) / (#self.directions + 1) * 2)

            self.textSmall:write(v.user)

            local width = self.textSmall:getWidth()
            if width > self.maxSmallTextWidth then
                self.textSmall.scale:set(self.maxSmallTextWidth / width)
            else
                self.textSmall.scale:set(1, 1)
            end

            self.textSmall.offset.y = 105 - 20 * i
            self.textSmall:drawAsChild(self)

            self.arrowSmall.alpha = self.textSmall.alpha
            self.arrowSmall.anim:set(v.direction)
            self.arrowSmall.offset.y = 110 - 20 * i
            self.arrowSmall:drawAsChild(self)

            ::continue::
        end

        self.text:drawAsChild(self)
        self.arrowBig:drawAsChild(self)
    end

    if self.horseyDefeated then
        self.textConnection:drawAsChild(self)
    end

    self.monitor:drawAsChild(self)
    self.hearts:drawAsChild(self)

    -- Set the offset of batteryFill to the bottom of the battery
    self.batteryFill.offset.y = self.batteryFill.defaultHeight - self.batteryFill.height
    self.batteryFill:drawAsChild(self, nil, nil, true)
    self.battery:drawAsChild(self)

    self.batteryText:drawAsChild(self)

    self.textMonitorList:drawAsChild(self)
    self.textMonitorPercents:drawAsChild(self)
end

function Television:addDirection(user, direction)
    if self.horseyDefeated then return end
    self.directionCount[direction] = self.directionCount[direction] + 1
    self.directionCount.total = self.directionCount.total + 1
    self.textMonitorHash[direction]:write(self.directionCount[direction])
    self.textMonitorHash.total:write(self.directionCount.total)

    for k, v in pairs(self.textMonitorHashPercent) do
        local percent = _.round((self.directionCount[k] / self.directionCount.total) * 100)
        v:write(percent .. "%")
    end

    self.showDirections = true
    self.directions:unshift({
        user = user,
        direction = direction
    })

    if #self.directions > 10 then
        self.directions:pop()
    end
end

function Television:showPickedDirection(name, direction)
    self.text:write(name)
    self.arrowBig.anim:set(direction)
    self.arrowBig.visible = true

    local width = self.text:getWidth()
    if width > self.maxTextWidth then
        self.text.origin.y = self.text:getHeight() / 2
        self.text.scale:set(self.maxTextWidth / width)
    else
        self.text.scale:set(1, 1)
    end

    self:tween(self.arrowBig.scale, .2, { x = self.arrowBig.scale.x, y = self.arrowBig.scale.y })
    self.arrowBig.scale.x = self.arrowBig.scale.x * 1.2
    self.arrowBig.scale.y = self.arrowBig.scale.y * 1.2
end

function Television:updateHorseyHealth(health)
    self.hearts[3 - health].anim:set("empty")
end

function Television:onHorseyDead()
    self.horseyDefeated = true
    self.showDirections = false
    self.monitor.anim:set("off")
end

return Television
