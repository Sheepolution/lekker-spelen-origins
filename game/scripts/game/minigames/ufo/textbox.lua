local Text = require "libs.text"
local Asset = require "base.asset"
local Sprite = require "base.sprite"
local Input = require "base.input"
local SFX = require "base.sfx"
local Scene = require "base.scene"
local Placement = require "base.components.placement"

local Textbox = Scene:extend("Textbox")

Textbox.Fonts = {
    monogram = Asset.font("m5x7_custom", 16)
}

Textbox.Audio = {
    computer = {
        finally = Asset.audio("sfx/textbox/computer/ufo/finally"),
        boss = Asset.audio("sfx/textbox/computer/ufo/boss"),
    },
}

Textbox.Images = {
    peter = Sprite(0, 0, "minigames/ufo/textbox/portraits/peter", true),
    timon = Sprite(0, 0, "minigames/ufo/textbox/portraits/timon", true),
    computer = Sprite(0, 0, "minigames/ufo/textbox/portraits/computer", true),
}

Text.configure.font_table(Textbox.Fonts)

Textbox.defaultHeight = 10
Textbox.hideHeight = -100
Textbox.audioPeter = Asset.audio("sfx/textbox/char_peter")
Textbox.audioTimon = Asset.audio("sfx/textbox/char_timon")
Text.configure.add_text_sound(Textbox.audioPeter, 0.2)
Text.configure.add_text_sound(Textbox.audioTimon, 0.2)

local default_settings = {
    autotags = "",                      -- This string is added at the start of every textbox, can include tags.
    font = Textbox.Fonts.monogram,      -- Default font for the textbox, love font object.
    color = { 1, 1, 1, 1 },             -- Default text color.
    shadow_color = { 1, 1, 1, 1 },      -- Default Drop Shadow Color.
    print_speed = 0.2,                  -- How fast text prints.
    adjust_line_height = 0,             -- Adjust the default line spacing.
    default_strikethrough_position = 0, -- Adjust the position of the strikethough line.
    default_underline_position = 0,     -- Adjust the position of the underline line.
    character_sound = false,            -- Use a voice when printing characters? True or false.
    sound_number = 1,                   -- What voice to use when printing characters.
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
    self:setBackgroundImage("minigames/ufo/textbox/textbox")
    self.width = self.backgroundImage.width
    self.height = self.backgroundImage.height
    self:centerX((WIDTH / 2) / 2)
    self.x = math.floor(self.x)

    self.y = Textbox.hideHeight
    self.backgroundAlpha = 0

    self.currentCharacter = "timon"

    self.inDialogue = false
    self.dialogueStarted = false
    self.dialogueNumber = 0

    self.indicator = self:add(Sprite(252, 44, "minigames/ufo/textbox/indicator", true))
    self.indicator.anim:set("next")

    self.onLastDialogue = false

    self.timer = 0
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

        Textbox.Images[self.currentCharacter].anim:update(dt)

        if self.onLastDialogue then
            self.indicator.offset.y = 0
            self.indicator.rotation = 10
        else
            self.timer = self.timer + dt
            self.indicator.rotation = 0
            self.indicator.angle = 0
            self.indicator.offset.y = math.cos(self.timer * PI * 4) * 2
        end
    end
end

function Textbox:drawInCanvas()
    Textbox.super.drawInCanvas(self)
    self.textbox:draw(54, 2)
    local avatar = Textbox.Images[self.currentCharacter]
    avatar.offset:set(3, 3)
    avatar:draw()
    self.indicator:draw()
end

function Textbox:appear(dialogueData, onComplete)
    self.inDialogue = true
    self.indicator.visible = false
    self.onLastDialogue = false
    self.onComplete = onComplete

    self.textbox:send("", 200)

    self.currentDialogue = dialogueData
    local dialogue = self.currentDialogue[1]
    self.currentCharacter = dialogue.character
    Textbox.Images[self.currentCharacter].anim:set(dialogue.emotion or "default")
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

    if self.onLastDialogue then
        self:disappear()
        return
    end

    local volume = CONFIG.defaultSFXVolume * SFX.maxVolume * .18
    Textbox.audioPeter:setVolume(volume)
    Textbox.audioTimon:setVolume(volume)
    volume = CONFIG.defaultSFXVolume * SFX.maxVolume * .6

    local dialogue = self.currentDialogue[self.dialogueNumber]
    self.currentCharacter = dialogue.character
    Textbox.Images[self.currentCharacter].anim:set(dialogue.emotion or "default")
    self:onChangePortrait()
    if Textbox.Audio[self.currentCharacter] then
        if dialogue.sound then
            local audio = Textbox.Audio[self.currentCharacter][dialogue.sound or "default"]
            audio:setEffect("reverb")
            audio:setVolume(volume)
            audio:play()
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
            Textbox.Images[self.currentCharacter].anim:set(emotion)
            self:onChangePortrait()
        end

        return "[function=emotion_" .. emotion .. "]"
    end)

    text = text:gsub('%[sound=(.-)%]', function(sound)
        functions["sound_" .. sound] = function()
            -- Textbox.Audio[self.currentCharacter][sound]:play()
        end

        return "[function=sound_" .. sound .. "]"
    end)

    text = text:gsub('%[auto%]', function(sound)
        functions["auto_next_dialogue"] = function()
            self:nextDialogue()
        end

        return "[function=auto_next_dialogue]"
    end)

    if dialogue.thinking then
        text = "[color=#FFFFFFAA]" .. text .. "[/color]"
    end

    Text.configure.function_table(functions)

    self.textbox:send(text, 200)
end

function Textbox:onChangePortrait()
    -- local portrait = Textbox.Images[self.currentCharacter]
    -- portrait.y = 10
    -- self:tween(portrait, .2, { y = 0 }):ease("backout")
end

return Textbox
