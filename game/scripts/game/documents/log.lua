local Document = require "documents.document"
local logs = require "data.logs"
local Save = require "base.save"
local Text = require "base.text"

local Log = Document:extend("Log")

function Log:new(name)
    Log.super.new(self)

    self.type = Document.DocumentType.Log

    local log = logs[name]
    self.log = log

    self.name = name
    self.special = not log

    if self.special then
        self:setImage("documents/logs/" .. name)
    else
        self:setImage("documents/logs/template_summary")

        self.textTitle = Text(20, 20, log.title, "m5x7_custom_bold")
        self.textTitle:setColor(0, 0, 0)

        self.textContent = Text(20, 60, log.text,
            "m5x7_custom")
        self.textContent.limit = 220
        self.textContent:setColor(0, 0, 0)

        self.textDate = Text(self.width - 30, 8, log.date,
            "m5x7_custom")
        self.textDate:setAlign("right", 220)
        self.textDate:setColor(0, 0, 0)
    end

    self:centerX(WIDTH / 2)
end

function Log:draw()
    Log.super.draw(self)
    if not self.special then
        self.textTitle:drawAsChild(self, nil, nil, true)
        self.textContent:drawAsChild(self, nil, nil, true)
        self.textDate:drawAsChild(self, nil, nil, true)
    end
end

return Log
