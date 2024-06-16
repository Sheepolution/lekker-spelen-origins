local SFX = require "base.sfx"
local sfx_lamp_break = SFX("sfx/cutscenes/intro/lamp_break_on_keyboard")
local sfx_computer = SFX("sfx/cutscenes/intro/computer")
local sfx_drain_left = SFX("sfx/cutscenes/intro/drain1")
local sfx_drain_right = SFX("sfx/cutscenes/intro/drain2")

local intro = {
    dialogues = {
        intro = {
            {
                character = "timon",
                emotion = "confused_tongue",
                text = "Hallo[.2].[.2].[.2].[.2]?"
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Hey[.2].[.2].[.2].[.5]\nWie ben jij?"
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Dat wilde ik jou net vragen.[.3] Wie ben ik?[.3] Ik heb namelijk geen flauw idee."
            },
            {
                character = "peter",
                emotion = "thinking",
                text =
                "Ik weet het van mezelf ook niet.[.3] Ik weet ook niet waar we zijn. [.3][emotion=thinking_concerned]Ik weet eigenlijk helemaal niet zoveel als ik erover nadenk."
            },
            {
                character = "timon",
                emotion = "default",
                functions = {
                    walkRight = function(self)
                        self.timon:cutsceneWalkTo(80, true)
                    end,
                    peterWalkLeft = function(self)
                        self.peter:cutsceneWalkTo(-80, true)
                        self.peter.looking = false
                    end
                },
                sound = "silence",
                text =
                "[function=walkRight][.5][sound=default]Kijk, [.2]er staat iets op de buis waar ik uitkwam. [1][emotion=confused]'[b]T[.3]1[.3][function=peterWalkLeft]-[.2]M[.3]N[/b]'."
            },
            {
                character = "peter",
                emotion = "questioning",
                functions = {
                    turnAround = function(self)
                        self.timon.flip.x = true
                        self.coil.wait(.5)

                        self.timon:cutsceneWalkTo(-80, true)
                        self.coil.wait(.2)

                        self.peter.flip.x = false
                        self.coil.wait(.5)

                        self.peter:cutsceneWalkTo(80, true, function()
                            self.peter.looking = true
                        end)
                    end
                },
                text =
                "En bij mij staat '[b][.3]P[.3]3[.2]-[.3]T[.3]R[.2]'.[function=turnAround]\n[1][emotion=thinking][/b]Zouden dat onze namen zijn?"
            },
            {
                character = "timon",
                emotion = "questioning",
                text = "Ze rollen niet echt lekker over dat tongetje."
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "Inderdaad. [.5][emotion=happy]Noem mij anders maar [b]Peter[/b]!\n[.3]Hoe klinkt dat?"
            },
            {
                character = "timon",
                emotion = "happy_tongue",
                text = "Ja nice! [.3]En noem mij dan maar [b][bounce]T-Dog![/bounce][/b]"
            },
            {
                character = "peter",
                emotion = "concerned",
                text = "Ik zat eerder te denken aan [b]Timon[/b]."
            },
            {
                character = "timon",
                emotion = "smug",
                text = "Of wat dacht je van [b][shake]Timmermale![/shake][/b]"
            },
            {
                character = "peter",
                emotion = "sarcastic",
                sound = "silence",
                text =
                "[.2].[.2].[.2].[1][sound=default]Ik noem je wel gewoon Timon. [.5][emotion=default]Ik denk dat we maar gewoon rond moeten lopen op zoek naar informatie,[.2] Timon."
            },
            {
                character = "timon",
                emotion = "tired_mad",
                sound = "silence",
                text = "[.2].[.2].[.2].[1][sound=default][emotion=confused_tongue][b][swing]T-Bar[/swing][/b]?"
            }
        }
    },
    functions = {
        init = function(self)
            self.coil.wait(3)
            local lightbulb = self:findEntityWithTag("Lightbulb")
            lightbulb:fall()
        end,
        zoomIn = function(self)
            local computer = self:findEntityWithTag("Computer")
            computer.anim:set("turn_on")
            sfx_lamp_break:play("reverb")
            sfx_computer:play("reverb")
            self.music:pause(10)
            self.coil.wait(.8)
            -- self.camera:tweenToRelativePoint(0, 0, 4):ease("quartout")
            self.camera:zoomTo(6, 4)
            self.coil.wait(8.3)
            local drain_sound_left = sfx_drain_left:play("reverb")
            drain_sound_left:setPosition(-.01, 0, 0)
            self.coil.wait(.2)
            local drain_sound_right = sfx_drain_right:play("reverb")
            drain_sound_right:setPosition(.01, 0, 0)
            local hibernationTubes = self:findEntitiesWithTag("Tube")
            for i, v in ipairs(hibernationTubes) do
                v:spawnPlayer()
            end

            self.coil.wait(9.5)
            -- self.camera:tweenToRelativePoint(0, -100, 4):ease("quadin")
            self.camera:zoomTo(1, 4):ease("quartout")

            self.coil.wait(5)

            local distance = self.peter:getDistanceX(self.timon)
            self.peter:cutsceneWalkTo(self.peter:centerX() + (distance / 2) - 50, false,
                function()
                    self.peter.looking = true
                end)

            self.timon:cutsceneWalkTo(self.timon:centerX() - (distance / 2) + 50, false,
                function()
                    self.timon.looking = true
                end)

            self.coil.wait(2)
            -- self.music:stop(1)
            self:startDialogue("intro")
            self.peter.looking = false
            self.timon.looking = false
            self:configurePlayerFollowing()
            self.music:play("mystery", 3)
            self:onEndCutscene()

            sfx_computer:destroy()
            sfx_drain_left:destroy()
            sfx_drain_right:destroy()
        end
    },
    flag = Enums.Flag.cutsceneIntro
}

return intro
