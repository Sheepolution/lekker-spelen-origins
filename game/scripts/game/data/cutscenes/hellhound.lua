local Music = require "base.music"
local SFX = require "base.sfx"

local hellhound = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "frightened",
                text =
                "What the fuck was dat allemaal?!",
            },
            {
                character = "peter",
                emotion = "frightened_mad",
                text = "Dat was helemaal geflipt. [.3][emotion=disgusted_hands]Vooral die eenden waren echt misbaksels.",
            },
            {
                character = "timon",
                emotion = "gross_scared",
                text =
                "Ja heel ranzig. [.3]Waar is dat klotepasje?\n[.3]Dan kunnen we weg hier...",
            },
        },
        part2 = {
            {
                character = "peter",
                emotion = "questioning",
                text = "Huh?!",
            },
            {
                character = "timon",
                emotion = "scared_eyes",
                functions = {
                    init = function(self)
                        self.timon.flip.x = true
                        self.coil.wait(1)
                        self.timon.flip.x = true
                    end
                },
                text = "Wat?! [.3]Wat is er?!",
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Ik... [.5]Ik ben een vampiertje.",
            },
            {
                character = "timon",
                emotion = "questioning",
                sound = "silence",
                text = ".[.1].[.1].[.1][sound=default]Wat?",
            },
            {
                character = "peter",
                emotion = "concerned",
                text =
                "Kijk in de spiegel! [.3]We hebben geen reflectie! [.3][emotion=thinking]\nEn ik heb ook wel trek in bloed, merk ik nu...",
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Is dat niet gewoon een raam?",
            },
            {
                character = "peter",
                text = "Oh. [1]Mag ik alsnog een slokkie uit jouw nek?",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                settings = {
                    print_speed = .05
                },
                functions = {
                    dog = function(self)
                        local sfx = SFX("sfx/cutscenes/hellhound/window_breaking")
                        sfx:play("reverb")
                        sfx:destroy()
                        self.cutsceneData.room.glass.anim:set("break")
                        self.cutsceneData.room.hellhound.visible = true
                    end,
                },
                text = "Peter, ga nou geen [function=dog]grappe-[.2][auto]",
            },
            {
                character = "peter",
                emotion = "scared",
                functions = {
                    init = function(self)
                        self.peter.flip.x = true
                    end
                },
                text = "What the fuck was dat?!",
            },
            {
                character = "timon",
                emotion = "scared_eyes",
                text = "Hallo...?[2][auto]",
            },
        },
        part3 = {
            {
                character = "timon",
                emotion = "shocked_ep_vines",
                settings = {
                    print_speed = .01
                },
                text = "[shiver=2]WHAT THE HEEEEEEEEEELLLLL?!?![/shiver]"
            },
            {
                character = "peter",
                emotion = "shocked_scared",
                settings = {
                    print_speed = .01
                },
                text = "[shiver=2]AAAAAAAAAAAAAAAAHHH!!![/shiver]",
            },
        }
    },
    functions = {
        prepare = function(self)
            -- self.camera:zoomTo(3)
            -- local level = self.map.currentLevel
            -- self.camera:moveToPoint(level.x, level.y + level.height)
        end,
        init = function(self)
            local room = self:findEntityWithTag("HellhoundRoom")
            local sfxBark = SFX("sfx/cutscenes/hellhound/barking")
            self.cutsceneData = { room = room }

            self:startDialogue("part1")

            self.peter:cutsceneWalkTo(390, true)
            self.coil.wait(.2)
            self.timon:cutsceneWalkTo(470, true)
            self.coil.wait(2.7)

            self:startDialogue("part2")

            self.timon:turnFlashlightOn()

            self.coil.wait(.2)

            room.hellhound.active = true
            self:tween(self.timon.flashlight.offset, 5, { x = -200 }):ease("cubicin")

            self.coil.wait(2)
            self.cutsceneData.room.music:play("breathing", 4)
            self.coil.wait(2)

            self:startDialogue("part3")

            -- self.coil.wait(3)

            self.cutsceneData.room.music:stop(.5)
            -- self.cutsceneData.room.hellhound.anim:set("bark")
            -- sfxBark:play("reverb")
            -- sfxBark:destroy()

            -- self.coil.wait(.4)

            -- self.peter.movementDirection = Enums.Direction.Right
            -- self.peter.inputHoldingRun = true
            -- self.timon.movementDirection = Enums.Direction.Right
            -- self.timon.inputHoldingRun = true

            -- -- local door = self:findEntityWithTag("Door", function(e) return not e.flip.x end)
            -- -- door.openEvenInCutscene = true

            -- self.coil.wait(1.4)
            -- self.timon:turnFlashlightOff()

            self.noDoorAccess = true

            self.timon.flashlight.offset:set(0, 0)
            local hellhound_room = self:findEntityWithTag("HellhoundRoom")
            self:onEndCutscene(true)
            hellhound_room:initializeRestart(true)
        end,
    },
    flag = Enums.Flag.cutsceneHellhoundIntro
}

return hellhound
