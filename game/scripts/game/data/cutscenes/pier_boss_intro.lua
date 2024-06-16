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

local function pier_angry(self)
    local pier = self:findEntityWithTag("Pier")
    pier.anim:set("angry")
end

local SFX = require "base.sfx"
local sfx_drill = SFX("sfx/characters/pier/drill")

local Pier = require "characters.pier"

local pier_boss_intro = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "questioning",
                text = "Oké, is hier dan die uitgang?",
            },
            {
                character = "peter",
                emotion = "questioning",
                functions = {
                    init = function(self)
                        self.camera:tweenToRelativePoint(650, -75, 3)
                    end
                },
                text = "Huh, [.2]is daar nou nog zo'n gesloten deur?",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text =
                "Hey inderdaad! [.3]En daar hebben we geen pasje voor.",
            },
            {
                character = "peter",
                emotion = "thinking",
                functions = {
                    init = function(self)
                        self.camera:tweenToRelativePoint(-500, 0, 3)
                        self.camera:zoomTo(2, 1)
                    end
                },
                text = "Hoe kan dat nou? [.3]Ik dacht dat we ze allemaal al hadden...",
            },
            {
                character = "pier",
                emotion = "secret",
                sound = "laugh",
                text = "Oei, [.2]wat vervelend nou.",
            },
            {
                character = "timon",
                emotion = "angry",
                text = "Klote-Pier! [.3]Waarom zei je niks over deze deur?!",
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
                "[2][sound=default][emotion=default]Helaas, [.2]jullie kunnen toch niet naar buiten.\n[.3]Al die moeite voor niks!",
            },
            {
                character = "pier",
                sound = "laugh",
                functions = {
                    init = pier_swing
                },
                text =
                "Maar dat betekent wel dat ik een hoop dolle pret kan beleven samen met mijn beste vrienden![.3]\nWat leuk!",
            },
            {
                character = "timon",
                emotion = "angry_teeth",
                text = "Verdomme Pier! [.3]We zijn je beste vrienden niet!",
            },
            {
                character = "pier",
                functions = {
                    init = pier_idle
                },
                text = "Haha oké, [.2]gewoon vrienden dan. [.3]Ook goed!\n[.3]Zolang we maar samen lol hebben.",
            },
            {
                character = "peter",
                emotion = "angry",
                text =
                "Nee ook geen vrienden! [.3]Gewoon niks! [.3]Hoe is het nog niet duidelijk voor je dat we je helemaal niet mogen?!",
            },
            {
                character = "pier",
                sound = "meh",
                emotion = "meh",
                functions = {
                    init = pier_meh
                },
                text = "Oké."
            },
            {
                character = "peter",
                emotion = "arms_crossed_tired",
                text = "Nou vertel op, [.2]waar ligt dat laatste pasje?"
            },
            {
                character = "timon",
                emotion = "suspicious",
                text = "Ja, [.2]dan kunnen we eindelijk weg uit dit geflipte laboratorium."
            },
            {
                character = "pier",
                sound = "meh",
                emotion = "meh",
                text = "Nee."
            },
            {
                character = "peter",
                emotion = "arms_crossed_frustrated",
                text = "Nee?[.2] Hoezo nee?[.2] Wat nee?"
            },
            {
                character = "pier",
                emotion = "angry",
                sound = "angry",
                functions = {
                    init = function(self)
                        pier_angry(self)
                        self.noDoorAccess = true
                    end
                },
                text =
                "NEE! [.3]Ik vertel helemaal niks! [.3]Het wordt tijd dat ik duidelijk maak dat jullie geen kans maken dit laboratorium ooit te verlaten!",
            },
            {
                character = "timon",
                emotion = "shocked_surprised",
                text =
                "What the hell?!"
            },
            {
                character = "pier",
                emotion = "angry",
                sound = "angry",
                functions = {
                    init = function(self)
                        local level = self.map:getCurrentLevel()
                        self.camera:tweenToPoint(level.x + level.width / 2, level.y + level.height / 2)
                        self.camera:zoomTo(1, 1)
                    end
                },
                text =
                "En als jullie dat eenmaal doorhebben, [.2][emotion=angry_smile]dan kunnen we eindelijk beste vrienden worden!"
            },

        },
    },
    functions = {
        prepare = function(self)
            self.camera:zoomTo(3)
            local level = self.map.currentLevel
            self.camera:moveToPoint(level.x, level.y + level.height)
        end,
        init = function(self)
            local room = self:findEntityWithTag("PierRoom")
            local pier = self:add(Pier(room.x + 438.5))
            pier:bottom(self.timon:bottom() + 8)
            pier.anim:set("underground")
            pier.flip.x = true

            self:startDialogue("part1")
            pier:destroy()
            self.camera:follow(self.cameraFollow)
            self:onEndCutscene()

            room:initializeRestart()

            sfx_drill:destroy()
        end,
    },
    flag = Enums.Flag.cutscenePierBossIntro
}

return pier_boss_intro
