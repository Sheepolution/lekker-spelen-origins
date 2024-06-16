local PeterOnTimon = require "characters.players.peter_on_timon"

local self_destruct = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "happy_tongue",
                functions = {
                    init = function(self)
                        self.coil.wait(.5)
                        self.camera:tweenToRelativePoint(900, 100, .5)
                        self.coil.wait(.5)
                        self.peter:cutsceneWalkTo(120, true)
                        self.timon:cutsceneWalkTo(120, true)
                    end
                },
                text =
                "Kijk, [.2]de trap naar beneden! [.3]We zijn bijna buiten, Peter!",
            },
            {
                character = "peter",
                emotion = "happy",
                functions = {
                    init = function(self)
                        self.coil.wait(.5)
                        self.camera:tweenToRelativePoint(-750, -100, .5)
                    end,
                },
                text = "Ja! [.3]Hey maar hier is [emotion=thinking]ook weer zo'n knop.",
            },
            {
                character = "timon",
                emotion = "tired",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(190, true)
                    end
                },
                text =
                "Laten we nou niet dezelfde fout maken als de vorige keer. [.3]Gewoon doorlopen.",
            },
            {
                character = "peter",
                emotion = "default",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(90, true)
                    end
                },
                text = "Nee tuurlijk niet. [.3]Ik vraag me gewoon [emotion=thinking]af wat het zou doen.",
            },
            {
                character = "timon",
                emotion = "frustrated",
                text = "Blijf er nou maar van af.",
                functions = {
                    init = function(self)
                        self.timon.flip.x = true
                    end
                },
            },
            {
                character = "peter",
                emotion = "default",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(150, true)
                        self.peter:cutsceneWalkTo(200, true)
                        self.timon.flip.x = false
                    end
                },
                text = "Ja ja. [.3]Kom, dan zijn [emotion=happy]we weg hier.",
            },
        },
        part2 = {
            {
                character = "peter",
                emotion = "arms_crossed_confident",
                functions = {
                    self_destruct = function(self)
                        self.cutsceneData.room.button.anim:set("on")
                        local SFX = require "base.sfx"
                        local announcer = SFX("sfx/cutscenes/self_destruct/announcement")
                        announcer:play()
                        announcer:destroy()
                        self.coil.wait(3)
                        self.cutsceneData.room:startCountdown()
                    end
                },
                text = "Ach, [.2]kan geen kwaad toch?[1][function=self_destruct][3][auto]",
            },
            {
                character = "timon",
                emotion = "shocked_mad",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(200, true, nil, true)
                    end
                },
                text = "PETER JIJ JOCH![2][auto]",
            },
            {
                character = "peter",
                emotion = "scared_sweat",
                functions = {
                    init = function(self)
                        self.camera:zoomTo(2, .5)
                        self.peter:destroy()
                        self.timon:destroy()
                        self.timon = self:getLevel():add(PeterOnTimon(self.timon:centerX(), self.timon:centerY() - 20))
                        self.timon.inCutscene = true
                        self.peter = nil
                        self.camera:tweenToPoint(self.timon:centerX(), self.timon:centerY(), .5)
                    end
                },
                text = "RENNEN TIMON! SNEL![1.5][auto]",
            },
        },
    },
    functions = {
        prepare = function(self)
            -- TODO: Turn this back on
            self.camera:zoomTo(3)
            local level = self.map.currentLevel
        end,
        init = function(self)
            local room = self:findEntityWithTag("ExitRoom")
            self.cutsceneData = { room = room }
            self.camera:follow()
            self:startDialogue("part1")
            self.coil.wait(2)
            self.peter:cutsceneWalkTo(-130, true)
            self.coil.wait(.5)
            self:startDialogue("part2")
            self.camera:zoomTo(1, .5)
            self:onEndCutscene()
            self.noDoorAccess = true
            self.timon.inCutscene = false
            self.camera:follow(self.timon)
        end,
    },
    flag = Enums.Flag.cutsceneSelfDestruct,
}

return self_destruct
