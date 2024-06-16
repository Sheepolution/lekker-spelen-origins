local SFX = require "base.sfx"

local shooter = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "nauseous",
                text = "Ik zal nooit aan die portalen gewend raken.[.3]\nIk ben niet gemaakt om rondjes te draaien.",
            },
            {
                character = "peter",
                functions = {
                    run = function(self)
                        self.peter:cutsceneWalkTo(550, true, function() self.peter.flip.x = true end, true)
                        self.coil.wait(.5)
                        self.timon:cutsceneWalkTo(300, true, nil, true)
                    end,
                },
                text = "En uiteraard [function=run]liggen daar weer apparaatjes!\n[.5]Wat zou het deze keer zijn?",
            },
            {
                character = "peter",
                emotion = "thinking",
                functions = {
                    init = function(self)
                        self:findEntityWithTag("DeviceContainer"):giveDevicesToPlayers()
                    end
                },
                text = "Oppassen Timon, [.2]je weet het nooit met die technologie.",
            },
            {
                character = "timon",
                emotion = "eyes_closed",
                functions = {
                    init = function(self)
                        self.timon.inputHoldingDown = true
                    end,
                },
                text = "Ga ervoor, Peter!",
            },
        },
        part2 = {
            {
                character = "peter",
                emotion = "shocked_ep_surprised",
                text =
                "WOW! [.3]Dat ging nog maar net goed..."
            },
            {
                character = "timon",
                emotion = "shocked_ep",
                functions = {
                    init = function(self)
                        self.timon.inputHoldingDown = false
                    end
                },
                text =
                "Wat is er?! [.2]Wat gebeurde er?!",
            },
            {
                character = "peter",
                emotion = "arms_crossed",
                text =
                "Hmm, wat?",
            },
            {
                character = "timon",
                emotion = "scared_serious",
                functions = {
                    init = function(self)
                        self.timon.inputHoldingDown = false
                    end
                },
                text =
                "Je zei [.2]\"Dat ging nog maar net goed.\"[.3]\nWat gebeurde er dan?",
            },
            {
                character = "peter",
                emotion = "arms_crossed_eyes_closed",
                text =
                "Huh, nee? [.3]Dat zei ik niet hoor. [.3]Hoe dan ook, [.2]het zijn laserguns! [.3]Die zullen mooi van pas komen!",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                sound = "silence",
                text =
                ".[.1].[.1].[.7][sound=default]Waarom ruik ik verbrand haar?",
            },
        }
    },
    functions = {
        prepare = function(self)
            local device_container = self:findEntityWithTag("DeviceContainer")
            device_container:addDevices()
        end,
        init = function(self)
            local shoot = SFX("sfx/players/shoot_peter")
            self:startDialogue("part1")
            self.coil.wait(.2)
            self.camera:zoomTo(2, 1)
            self.coil.wait(1.4)
            local x, y = self.peter:getRelativePosition(0, -4)
            local Laser = require "projectiles.laser"
            local laser = self:add(Laser(x, y, Enums.Direction.Left, self.peter.tag))
            laser.velocity.x = -1000
            shoot:play()
            self.coil.wait(.15)
            self:addParticle("sickoSmoke", self.timon:centerX() + 24, self.timon.y + 45, false)
            self.coil.wait(.05)
            self:addParticle("sickoSmoke", self.timon:centerX() + 26, self.timon.y + 48, false)
            self.coil.wait(.7)
            self:startDialogue("part2")
            self.camera:zoomTo(1, 1)
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneGettingShooters
}

return shooter
