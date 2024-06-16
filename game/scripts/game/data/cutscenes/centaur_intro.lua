local PeterOnTimon = require "characters.players.peter_on_timon"
local SFX = require "base.sfx"
local Rect = require "base.rect"

local breathing = SFX("sfx/cutscenes/centaur/breathing", 1)
local reveal = SFX("sfx/cutscenes/centaur/intro_mixed", 1)

local centaur_intro = {
    dialogues = {
        part1 = {
            {
                character = "peter",
                emotion = "frightened",
                text = "Wat was dat voor beest?!",
            },
            {
                character = "timon",
                emotion = "frightened_moving",
                text = "DAT WAS FUCKED UP! [.3]Gewoon niet te doen zelfs!",
            },
            {
                character = "peter",
                emotion = "scared_sweat",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(500, true)
                        self.coil.wait(.4)
                        self.timon:cutsceneWalkTo(500, true)
                        self.coil.wait(.4)
                        self.camera:tweenToRelativePoint(500, 0, 3):ease("linear")
                    end
                },
                text = "Oké nou dat...[.2] dat pasje kan niet heel ver weg meer zijn... [.2]toch?",
            },
            {
                character = "timon",
                emotion = "frightened_mad_right",
                text =
                "FUCK DAT PASJE PETER! [.2]Ik wil weg hier!",
            },
            {
                character = "timon",
                emotion = "frightened_right",
                functions = {
                    init = function()
                        breathing:play()
                    end
                },
                text =
                "Ik ga het toegeven ook gewoon. [.2]Ik kan dit oprecht nie-[auto]"
            },
            {
                character = "peter",
                emotion = "scared_serious_sweat",
                text = "WACHT STIL! [.5]Hoorde jij ook iets?",
            },
            {
                character = "timon",
                emotion = "frightened_mad_left",
                text = "Peter, ga me nou niet nog meer opfokken!",
            },
            {
                character = "peter",
                emotion = "scared_serious",
                text = "[textspeed=.015]Hou je kutbek?[textspeed=.02] [.5]Luister...",
            },
        },
        part2 = {
            {
                character = "timon",
                emotion = "shocked_vines",
                text = "WHAT THE FUUUUCK?!",
            },
            {
                character = "peter",
                emotion = "frightened_mad",
                text = "RENNEN TIMON! GAAN!",
            },
        }
    },
    functions = {
        prepare = function(self)
            self.camera:zoomTo(3)
            local level = self.map.currentLevel
            self.camera:moveToPoint(level.x, level.y + level.height - 160)
        end,
        init = function(self)
            local peter_on_timon = PeterOnTimon()
            local room = self:findEntityWithTag("CentaurRoom")
            self:startDialogue("part1")

            reveal:play()

            self.coil.wait(.5)

            room.centaur.anim:set("idle")
            local level = self:getLevel()
            local light = level:add(Rect(self.peter:center()))
            light.lightSource = self:addLightSource(light, 100, 100)
            light.lightSource.alpha = 0
            local tween_a = self.camera:tweenToRelativePoint(0, -250, 4):ease("quadin")
            local tween_b = self.camera:zoomTo(2, 4):ease("quadin")
            local tween_c = self:tween(light.lightSource.offset, 4, { x = -100, y = -300 }):ease("quadin")
            self:tween(light.lightSource, 2, { alpha = 1 })

            self.coil.wait(4.3)

            tween_a:stop()
            tween_b:stop()
            tween_c:stop()

            self.peter:destroy()
            self.timon:destroy()
            peter_on_timon:set(self.peter:centerX(), self.timon:centerY() - 5)
            self.timon = level:add(peter_on_timon)
            self.timon.inCutscene = true
            self.peter = nil
            self.players:clear()
            self.players:add(self.timon)

            self.camera:tweenToPoint(self.timon:centerX(), self.timon:centerY(), .5)
            self.camera:zoomTo(3, .5)
            self:startDialogue("part2")
            light:destroy()
            self.camera:zoomTo(1, 1)
            self:onEndCutscene()
            self.camera:follow(self.timon)
            self.music:play("bosses/centaur/theme"):setLooping(false)
            self.timon.inCutscene = false
            self.coil.wait(1)
            room:initializeRestart(true)
        end,
    },
    flag = Enums.Flag.cutsceneCentaurIntro
}

return centaur_intro
