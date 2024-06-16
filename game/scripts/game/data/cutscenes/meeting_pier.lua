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

local meeting_pier = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                text = "Oké, [.2]waar is die uitgang?",
            },
            {
                character = "pier",
                emotion = "secret",
                sound = "laugh",
                text = "Oh, [.3]wie hoor ik daar?",
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Huh? [.4]Wie zei dat?",
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
                "[2][sound=default][emotion=default]Ik! [.3]P1-ER. [.3]Maar zeg gerust Pier. [.3]Wat leuk om na al die jaren weer nieuwe gezichten te zien!",
            },
            {
                character = "timon",
                emotion = "wink",
                text = "Mag ik je ook Piertje noemen?",
            },
            {
                character = "pier",
                sound = "laugh",
                functions = {
                    init = pier_swing
                },
                text = "Natuurlijk mag dat! [.3]Jullie zijn tenslotte mijn nieuwe beste vrienden!",
            },
            {
                character = "peter",
                text = "We dachten dat we alleen waren hier.",
            },
            {
                character = "pier",
                text = "Zeker niet! [.3]Dit laboratorium zit vol fantastische dieren!",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Maar hoe zit het dan met de wetenschappers? [.3]Waar zijn die heen?",
            },
            {
                character = "pier",
                functions = {
                    init = pier_idle
                },
                text =
                "De mensen bedoel je? [.3]Die zijn er niet meer!\n[.3]Leuk hè? [.2]Dan hebben we heel het laboratorium voor onszelf!"
            },
            {
                character = "peter",
                emotion = "concerned",
                text = "Wat is er met ze gebeurd dan?",
            },
            {
                character = "pier",
                sound = "laugh",
                functions = {
                    init = pier_swing
                },
                text =
                "Dat is toch helemaal niet belangrijk!\n[.3]Het belangrijkste is dat we samen dolle pret gaan beleven!",
            },
            {
                character = "timon",
                text = "Eigenlijk wilden wij juist weggaan.\n[.3]We hebben hier niks te zoeken.",
            },
            {
                character = "pier",
                emotion = "meh",
                sound = "meh",
                text = "Oh.",
                functions = {
                    init = pier_meh
                },
            },
            {
                character = "pier",
                functions = {
                    init = pier_swing,
                    camera = function(self)
                        self.camera:follow()
                        self.camera:tweenToRelativePoint(1000, 0, 3)
                    end,
                },
                text =
                "Helaas zal dat niet gaan! [.2][function=camera]De uitgang ligt achter gesloten deuren. [.2]Vier om precies te zijn.",
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "En waar zijn de sleutels?",
            },
            {
                character = "pier",
                functions = {
                    init = pier_idle
                },
                text =
                "De toegangspasjes bedoel je? [.3]Die liggen verspreid over het hele laboratorium."
            },
            {
                character = "pier",
                functions = {
                    init = function(self)
                        self.camera:tweenToObject(self.cameraFollow, .5)
                    end,
                },
                text =
                "Om die allemaal te pakken zou heel lang duren, [.2]en het is ook nog eens heel gevaarlijk!"
            },
            {
                character = "timon",
                emotion = "confused_sarcastic",
                text =
                "Ik denk dat we toch maar een poging wagen."
            },
            {
                character = "pier",
                emotion = "meh",
                sound = "meh",
                functions = {
                    init = pier_meh
                },
                text = "Oké.",
            },
            {
                character = "pier",
                functions = {
                    init = pier_idle
                },
                text =
                "In dat geval succes! [.3]Laat me maar weten wanneer jullie vragen hebben, [.2]of wanneer jullie van gedachten veranderen.",
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
                "Toedeledokie!",
            },
            {
                character = "peter",
                text =
                "Timon, [.2]ik heb twee vragen.\n[.5][emotion=mad]Hebben wormen een nek, [.3]en is die breekbaar?"
            },
            {
                character = "timon",
                emotion = "suspicious",
                text =
                "Maar echt. [.3]Dit was dus niet te doen. [.3]Laten we zo snel mogelijk die klotesleutels vinden voordat die geflipte terugkomt.",
            },
        },
    },
    functions = {
        init = function(self)
            local pier = self.map:getCurrentLevel():add(Pier(self.timon.x + 150))
            pier:bottom(self.timon:bottom() + 8)
            pier.anim:set("underground")
            pier.flip.x = true

            self:startDialogue("part1")
            self:onEndCutscene()
            sfx_drill:destroy()
            sfx_slime:destroy()
        end,
    },
    flag = Enums.Flag.cutsceneMeetingPier
}

return meeting_pier
