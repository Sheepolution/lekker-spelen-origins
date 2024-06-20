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
                character = "timon",
                emotion = "determined",
                text = "Dat laatste pasje, Peter! [.3]Het kan niet lang meer duren nu!",
            },
            {
                character = "pier",
                emotion = "secret",
                text = "Wauw! [.3]Jullie hebben al drie pasjes!",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                text = "Oh nee hè...",
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
                "[2][sound=default][emotion=default]Dag, beste vrienden! [.3]Zo te horen gaat het goed met jullie avontuur door het laboratorium!",
            },
            {
                character = "pier",
                functions = {
                    init = pier_swing
                },
                sound = "laugh",
                text = "Wat lief van Horsey dat hij jullie zijn pasje heeft gegeven.",
            },
            {
                character = "timon",
                emotion = "confused",
                settings = {
                    print_speed = .05
                },
                text =
                "Horsey? [.5]Oh je bedoelt dat paard! [.5]Die hebben we-[.3][auto]",
            },
            {
                character = "peter",
                emotion = "arms_crossed_confident",
                text =
                "Ja heel lief! [.3]Wat een topgozer is het toch ook.",
            },
            {
                character = "pier",
                functions = {
                    init = pier_idle
                },
                text = "Precies! [.3]Misschien een beetje gek in dat koppie, [.2]maar met een goed hart!",
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "Piertje, [.2]weet jij misschien meer over\n[.2]\"het ongeluk\"? ",
            },
            {
                character = "pier",
                functions = {
                    init = pier_swing
                },
                sound = "laugh",
                text =
                "Jazeker! [.3]Dat is mijn favoriete dag, [.2]want sindsdien zijn er geen wetenschappers meer! [.3]Ik noem het zelf daarom [.2]\"het geluk\"! [.3]Leuk hè?",
            },
            {
                character = "peter",
                emotion = "thinking_serious",
                text =
                "Maar wat gebeurde er dan op die dag? [.3]Zijn ze gewoon vertrokken?",
            },
            {
                character = "timon",
                emotion = "scared",
                settings = {
                    print_speed = .05
                },
                text =
                "Of misschien.[.1].[.1].[.1] [.3][emotion=frightened]Zijn ze misschien.[.1].[.1].[.1] vermoo-[.3][auto]",
            },
            {
                character = "pier",
                functions = {
                    init = pier_idle
                },
                text =
                "Waarom wil je dat zo graag weten? [.3]Het belangrijkste is toch dat ze er niet meer zijn!",
            },
            {
                character = "peter",
                emotion = "thinking_concerned",
                text =
                "Nou ja, op zich maakt het nu niet meer zoveel uit nee. [.3]Maar we zijn gewoon nieuwsgierig.",
            },
            {
                character = "pier",
                functions = {
                    init = pier_swing
                },
                sound = "laugh",
                text =
                "Je moet niet zoveel in het verleden graven, [.2]en juist genieten van wat je aangeboden krijgt. [.3]Zoals dit laboratorium helemaal voor onszelf!",
            },
            {
                character = "timon",
                emotion = "sarcastic_mad",
                text =
                "Dat zeg je allemaal wel, [.2]maar we gaan nog steeds voor dat laatste pasje.",
            },
            {
                character = "pier",
                emotion = "meh",
                sound = "meh",
                functions = {
                    init = pier_meh
                },
                text =
                "Oké.",
            },
            {
                character = "pier",
                functions = {
                    functions = {
                        init = pier_idle
                    },
                    dig = function(self)
                        local pier = self:findEntityWithTag("Pier")
                        pier.anim:set("dig")
                        sfx_slime:play("reverb")
                    end,
                },
                text =
                "Nou, dan ben ik er weer vandoor! [.3][function=dig]Succes en toedeledokie!"
            },
            {
                character = "peter",
                emotion = "angry",
                text =
                "Timon, [.2]denk jij wat ik denk?",
            },
            {
                character = "timon",
                emotion = "angry",
                text =
                "Die gozer is dus echt helemaal geflipt.",
            },
        },
    },
    functions = {
        init = function(self)
            local pier = self.map:getCurrentLevel():add(Pier(self.timon.x + 354))
            pier:bottom(self.timon:bottom() + 8)
            pier.anim:set("underground")
            pier.flip.x = true

            self:startDialogue("part1")
            self:onEndCutscene()
            sfx_drill:destroy()
            sfx_slime:destroy()
        end,
    },
    flag = Enums.Flag.cutsceneTelegate4
}

return telegate1
