local Text = require "libs.text"
local Asset = require "base.asset"
local Sprite = require "base.sprite"
local Input = require "base.input"
local SFX = require "base.sfx"
local Scene = require "base.scene"

local Textbox = Scene:extend("Textbox")

Textbox.Fonts = {
    m5x7 = Asset.font("m5x7_custom", 32)
}

Textbox.Audio = {
    peter = {
        default = Asset.audio("sfx/textbox/peter/squeak"),
        think = Asset.audio("sfx/textbox/peter/squeak_think"),
        squeak_pitched = Asset.audio("sfx/textbox/peter/squeak_pitched"),
    },
    timon = {
        default = Asset.audio("sfx/textbox/timon/bark"),
        think = Asset.audio("sfx/textbox/timon/bark_think"),
        bark_pitched = Asset.audio("sfx/textbox/timon/bark_pitched"),
    },
    computer = {},
    pier = {
        default = Asset.audio("sfx/textbox/pier/laugh_soft"),
        laugh = Asset.audio("sfx/textbox/pier/laugh_loud"),
        meh = Asset.audio("sfx/textbox/pier/meh"),
        angry = Asset.audio("sfx/textbox/pier/angry"),
    },
    horsey = {
        default = Asset.audio("sfx/textbox/horsey/default"),
        short = Asset.audio("sfx/textbox/horsey/short"),
        long = Asset.audio("sfx/textbox/horsey/long"),
    },
    panda = {
        default = Asset.audio("sfx/textbox/panda/yeah"),
        cool = Asset.audio("sfx/textbox/panda/cool"),
        sad = Asset.audio("sfx/textbox/panda/sad"),
        frustrated = Asset.audio("sfx/textbox/panda/frustrated"),
        angry = Asset.audio("sfx/textbox/panda/angry"),
    },
    cat = {
        default = Asset.audio("sfx/textbox/cat/meow"),
    },
    sicko = {
        default = Asset.audio("sfx/textbox/sicko/yo"),
    },
    gier = {
        default = Asset.audio("sfx/textbox/gier/euros"),
    }
}

Textbox.Images = {
    peter = Sprite(0, 0, "textbox/portraits/peter", true),
    timon = Sprite(0, 0, "textbox/portraits/timon", true),
    pier = Sprite(0, 0, "textbox/portraits/pier", true),
    gier = Sprite(0, 0, "textbox/portraits/gier", true),
    computer = Sprite(0, 0, "textbox/portraits/computer", true),
    horsey = Sprite(0, 0, "textbox/portraits/horsey", true),
    panda = Sprite(0, 0, "textbox/portraits/panda", true),
    cat = Sprite(0, 0, "textbox/portraits/cat", true),
    sicko = Sprite(0, 0, "textbox/portraits/sicko", true),
    secret = Sprite(0, 0, "textbox/portraits/secret"),
}

Text.configure.font_table(Textbox.Fonts)

Textbox.defaultHeight = -10
Textbox.hideHeight = -200

local default_settings = {
    autotags = "",                      -- This string is added at the start of every textbox, can include tags.
    font = Textbox.Fonts.m5x7,          -- Default font for the textbox, love font object.
    color = { 1, 1, 1, 1 },             -- Default text color.
    shadow_color = { 1, 1, 1, 1 },      -- Default Drop Shadow Color.
    print_speed = 0.2,                  -- How fast text prints.
    adjust_line_height = 0,             -- Adjust the default line spacing.
    default_strikethrough_position = 0, -- Adjust the position of the strikethough line.
    default_underline_position = 0,     -- Adjust the position of the underline line.
    character_sound = false,            -- Use a voice when printing characters? True or false.
    sound_number = 0,                   -- What voice to use when printing characters.
    sound_every = 2,                    -- How many characters to wait before making another noise when printing text.
    default_warble = 0                  -- How much to adjust the voice when printing each character.
}

function Textbox:new(...)
    Textbox.super.new(self, ...)
    self.settings = _.copy(default_settings)
    self.settings.print_speed = .027
    self.settings.adjust_line_height = 2
    self.settings.character_sound = true
    self.usesDefaultSettings = true
    self.textbox = Text.new("left", self.settings)
    self:setBackgroundImage("textbox/textbox")
    self.width = self.backgroundImage.width
    self.height = self.backgroundImage.height
    self:centerX(WIDTH / 2)
    self.x = math.floor(self.x)

    self.y = Textbox.hideHeight
    self.backgroundAlpha = 0

    self.currentCharacter = "timon"

    self.inDialogue = false
    self.dialogueStarted = false
    self.dialogueNumber = 0

    self.indicator = self:add(Sprite(670, 126, "textbox/indicator", true))
    self.indicator.anim:set("next")
    self.indicator.visible = false

    self.onLastDialogue = false

    self.timer = 0

    love.audio.setEffect("reverb", {
        type = "reverb",
        decaytime = .7
    })
end

function Textbox:update(dt)
    Textbox.super.update(self, dt)

    if not self.inDialogue then
        return
    end

    self.textbox:update(dt)

    if self.inDialogue then
        if self.dialogueStarted then
            if self.textbox:is_finished() then
                self.indicator.visible = true
                if Input:isPressed("z", "s", "space", "c1_a", "c2_a") or Input:isDown("c1_back", "c2_back", "backspace") then
                    self:nextDialogue()
                end
            else
                self.indicator.visible = false
            end
        end

        if not self.secretPortrait then
            Textbox.Images[self.currentCharacter].anim:update(dt)
        end

        if self.onLastDialogue then
            self.indicator.offset.y = 0
            self.indicator.rotation = 10
        else
            self.timer = self.timer + dt
            self.indicator.rotation = 0
            self.indicator.angle = 0
            self.indicator.offset.y = math.cos(self.timer * PI * 4) * 4
        end
    end
end

function Textbox:drawInCanvas()
    Textbox.super.drawInCanvas(self)
    self.textbox:draw(130, 42)
    local avatar = Textbox.Images[self.secretPortrait and "secret" or self.currentCharacter]
    avatar.offset:set(8, 40)
    avatar:draw()
    self.indicator:draw()
end

function Textbox:appear(dialogueData, onComplete)
    self.inDialogue = true
    self.indicator.visible = false
    self.onLastDialogue = false
    self.onComplete = onComplete

    self.textbox:send("", 540)

    self.currentDialogue = dialogueData
    local dialogue = self.currentDialogue[1]
    self.currentCharacter = dialogue.character
    self.secretPortrait = dialogue.emotion == "secret"
    if not self.secretPortrait then
        Textbox.Images[self.currentCharacter].anim:set(dialogue.emotion or "default")
    end
    -- self:onChangePortrait()
    self.dialogueNumber = 0

    self.indicator.anim:set("next")

    self:tween(.2, { y = Textbox.defaultHeight }):oncomplete(function()
        self.dialogueStarted = true
        self:nextDialogue()
    end)
end

function Textbox:disappear()
    self.dialogueStarted = false
    self:tween(.2, { y = Textbox.hideHeight }):oncomplete(function()
        self.inDialogue = false
        if self.onComplete then
            self.onComplete()
            self.onComplete = nil
        end
    end)
end

function Textbox:nextDialogue()
    self.dialogueNumber = self.dialogueNumber + 1

    if Input:isDown("c1_back", "c2_back", "backspace") then
        if self.lastSound then
            self.lastSound:stop()
            self.lastSound = nil
        end
    end

    if self.onLastDialogue then
        self:disappear()
        return
    end

    local dialogue = self.currentDialogue[self.dialogueNumber]
    self.currentCharacter = dialogue.character

    self.secretPortrait = dialogue.emotion == "secret"
    if not self.secretPortrait then
        Textbox.Images[self.currentCharacter].anim:set(dialogue.emotion or "default")
    end

    self:onChangePortrait()
    if Textbox.Audio[self.currentCharacter] then
        if dialogue.sound ~= "silence" then
            local sound = Textbox.Audio[self.currentCharacter][dialogue.sound or "default"]
            if not sound then
                -- Add sound
                Textbox.Audio[self.currentCharacter][dialogue.sound or "default"] = Asset.audio("sfx/textbox/" ..
                    self.currentCharacter .. "/" .. (dialogue.sound or "default"))
            end
            -- TODO: Make this proper
            local audio = Textbox.Audio[self.currentCharacter][dialogue.sound or "default"]
            audio:setEffect("reverb")
            local volume = CONFIG.defaultSFXVolume * SFX.maxVolume
            audio:setVolume(volume)
            audio:play()
            self.lastSound = audio
        end
    end

    if dialogue.settings then
        local settings = _.copy(self.settings)
        for k, v in pairs(dialogue.settings) do
            settings[k] = v
        end
        self.textbox = Text.new("left", settings)
        self.usesDefaultSettings = false
    else
        if not self.usesDefaultSettings then
            self.usesDefaultSettings = true
            self.textbox = Text.new("left", self.settings)
        end
    end

    local functions = {}
    if dialogue.functions then
        functions = _.copy(dialogue.functions)
        for k, v in pairs(functions) do
            functions[k] = function()
                self.scene:event(function()
                    v(self.scene)
                end, nil, 1)
            end
        end
        if functions.init then
            functions.init()
        end
    end

    self.onLastDialogue = self.dialogueNumber == #self.currentDialogue

    if self.onLastDialogue then
        self.indicator.anim:set("done")
    end

    local text = dialogue.text

    text = text:gsub("%[(%d*%.?%d*)%]", "[pause=%1]")

    text = text:gsub('%[emotion=(.-)%]', function(emotion)
        functions["emotion_" .. emotion] = function()
            if emotion == "secret" then
                self.secretPortrait = true
            else
                Textbox.Images[self.currentCharacter].anim:set(emotion)
                self.secretPortrait = false
                self:onChangePortrait()
            end
        end

        return "[function=emotion_" .. emotion .. "]"
    end)

    text = text:gsub('%[sound=(.-)%]', function(sound)
        functions["sound_" .. sound] = function()
            local audio = Textbox.Audio[self.currentCharacter][sound]
            local volume = CONFIG.defaultSFXVolume * SFX.maxVolume
            audio:setVolume(volume)
            audio:setEffect("reverb")
            audio:play()
        end

        return "[function=sound_" .. sound .. "]"
    end)

    text = text:gsub('%[auto%]', function(sound)
        functions["auto_next_dialogue"] = function()
            self:cb(function()
                self:nextDialogue()
            end)
        end

        return "[function=auto_next_dialogue]"
    end)

    if dialogue.thinking then
        text = "[color=#FFFFFFAA]" .. text .. "[/color]"
    end

    Text.configure.function_table(functions)

    self.textbox:send(text, 540)
end

function Textbox:onChangePortrait()
    -- local portrait = Textbox.Images[self.currentCharacter]
    -- portrait.y = 10
    -- self:tween(portrait, .2, { y = 0 }):ease("backout")
end

return Textbox
