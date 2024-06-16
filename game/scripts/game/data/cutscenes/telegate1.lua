local function pier_idle(self)
    local pier = self:findEntityWithTag("Pier")
    pier.anim:set("idle")
end

local function pier_meh(self)
    local pier = self:findEntityWithTag("Pier")
    pier.anim:set("meh")
end

local function pier_swing(self)
    local pier = self:findEntityWithTag("Pier")
    pier.anim:set("swing")
end

local SFX = require "base.sfx"
local sfx_drill = SFX("sfx/characters/pier/drill")
local sfx_slime = SFX("sfx/characters/pier/slime")

local Pier = require "characters.pier"

local telegate1 = {
    dialogues = {
        part1 = {
            {
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(-100, true)
                        self.timon:cutsceneWalkTo(-100, true)
                    end,
                },
                character = "peter",
                text = "Hey kijk, Timon, [.2]zo'n apparaat zagen we net ook al staan.[.3] Wat zou het zijn?",
            },
            {
                character = "pier",
                emotion = "secret",
                sound = "laugh",
                text = "Dat is een teleportaal!",
            },
            {
                character = "timon",
                emotion = "sarcastic_extreme",
                text = "Oh god, [.2]daar gaan we weer.",
            },
            {
                character = "pier",
                emotion = "secret",
                sound = "silence",
                functions = {
                    init = function(self)
                        local pier = self:findEntityWithTag("Pier")
                        pier.anim:set("drill")
                        sfx_drill:play("reverb")
                    end,
                },
                text =
                "[2][sound=default][emotion=default]Hallo, beste vrienden! [.3]Wat leuk om jullie nu alweer te kunnen spreken!",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                text = "Hoi Piertje...",
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text = "Nou vertel op, [.2]wat is dit ding?\n[.3]Kunnen we hiermee tijdreizen?",
            },
            {
                character = "peter",
                emotion = "default",
                text = "Of naar een andere dimensie misschien?",
            },
            {
                character = "pier",
                sound = "laugh",
                functions = {
                    init = pier_swing
                },
                text = "Hihi, [.2]nee gekkies! [.3]Hiermee kan je naar een andere verdieping!",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                text = "Oh, [.2]gewoon een lift dus. [.3]Een beetje teleurstellend wel...",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Maar hoe werkt dit ding? [.3]Het lijkt niet veel te doen.",
            },
            {
                character = "pier",
                sound = "laugh",
                functions = {
                    init = pier_idle
                },
                text =
                "Dat komt omdat het nog niet aanstaat, [.2]jij dommie!"
            },
            {
                character = "timon",
                emotion = "angry",
                text = "Hey noem me geen dommie gast! [.3]Ik ben gewoon slim ja!",
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Hoe kunnen we dit ding dan aanzetten?",
            },
            {
                character = "pier",
                text =
                "Dat kan met een pasje! [.3]Maar die ligt helemaal aan de andere kant van deze ruimte.",
            },
            {
                character = "pier",
                text =
                "Zal ik die anders even pakken voor jullie?[.3]\nIk graaf er zo heen en weer terug. [.3]Dan zijn we een echt team! Hihi!",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                text =
                "Nee is al goed, [.2]we doen het zelf wel.",
            },
            {
                character = "timon",
                emotion = "mad",
                text = "Ja super bedankt Piertje, je bent heel aardig maar kut nu maar weer op.",
            },
            {
                character = "pier",
                emotion = "meh",
                sound = "meh",
                text = "Oké.",
                functions = {
                    init = pier_meh
                },
            },
            {
                character = "pier",
                sound = "laugh",
                functions = {
                    init = function(self)
                        local pier = self:findEntityWithTag("Pier")
                        pier.anim:set("dig")
                        sfx_slime:play("reverb")
                    end,
                },
                text =
                "Dan ben ik er weer vandoor. [.3]Toedeledokie!",
            },
            {
                character = "peter",
                emotion = "concerned",
                text =
                "Gaat het, Timon?",
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Het vuile lef... [.3]Mij dom noemen hè! [.3]Jij wist toch ook niet dat-ie uitstond?",
            },
            {
                character = "peter",
                thinking = true,
                sound = "think",
                text =
                "(Nou ik weet niet, [.2]dat was vrij duidelijk... [.3]Maar goed, [.2][emotion=arms_crossed_eyes_closed]als Main Event zie je dat soort dingen.)",
            },
            {
                character = "peter",
                text =
                "Nee zeker niet.",
            },
        },
    },
    functions = {
        init = function(self)
            local pier = self.map:getCurrentLevel():add(Pier(self.timon.x - 300))
            pier:bottom(self.timon:bottom() + 8)
            pier.anim:set("underground")

            self:startDialogue("part1")
            self:onEndCutscene()
            sfx_drill:destroy()
            sfx_slime:destroy()
        end,
    },
    flag = Enums.Flag.cutsceneTelegate1
}

return telegate1
