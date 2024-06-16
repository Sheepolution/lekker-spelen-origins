local Text = require "base.text"
local Sprite = require "base.sprite"

local Credit = Sprite:extend("Credit")

function Credit:new(y, name, code, credits, noPortrait)
    Credit.super.new(self)
    if noPortrait then
        self:setImage("credits/textbox_no_portrait")
    else
        self:setImage("credits/textbox_no_portrait")

        self.title = Text(-338, -108, name, "BebasNeue", 64)
        self.titleCode = Text(345, -98, code, "bebas_light", 64)
        self.titleCode:setAlign("right", WIDTH)
    end

    if noPortrait then
        self:setImage("credits/textbox_no_portrait")
    else
        self:setImage("textbox/textbox")
        self.portrait = Sprite(
            name == "moederwasbeer" and 6 or 8,
            name == "specifiek_roos" and 39 or 40,
            "credits/portraits/" .. name)

        self.title = Text(-338, -108, name, "BebasNeue", 64)
        self.titleCode = Text(345, -98, code, "bebas_light", 64)
        self.titleCode:setAlign("right", WIDTH)
    end

    self.noPortrait = noPortrait

    self.text = Text(51, 8, credits, 32)
    self.text = Text(0, 8, credits, 32)
    self.text:setAlign("center", 640)
    self.text.align.y = "center"

    if noPortrait then
        self.text.x = 0
    end

    self:center(WIDTH / 2, y)
end

function Credit:update(dt)
    Credit.super.update(self, dt)
end

function Credit:draw()
    Credit.super.draw(self)
    self.text:drawAsChild(self)
    if not self.noPortrait then
        self.portrait:drawAsChild(self, nil, nil, true)
        self.title:drawAsChild(self)
        self.titleCode:drawAsChild(self)
    end
end

return Credit
