local Sicko = require "characters.sicko"
local SickoBoss = require "bosses.sicko.sicko"
local Sprite = require "base.sprite"
local Rect = require "base.rect"
local Peter = require "characters.players.peter"
local Asset = require "base.asset"
local SFX = require "base.sfx"

local Timon = require "characters.players.timon"

local sfx = {
    door_open = SFX("sfx/interactables/door_open"),
    door_close = SFX("sfx/interactables/door_close"),
    grab = SFX("sfx/cutscenes/sicko/grab"),
    punch = SFX("sfx/cutscenes/sicko/punch"),
    ko = SFX("sfx/cutscenes/sicko/ko"),
}

local sicko_intro = {
    dialogues = {
        part1_timon = {
            {
                character = "timon",
                emotion = "crying",
                text = "Peter... *snik*",
            },
            {
                character = "timon",
                emotion = "sad",
                text = "Uhm... *snik* [.2]hallo? [.3]Is dit toevallig de uitgang?",
            },

            {
                character = "sicko",
                emotion = "secret",
                functions = {
                    init = function(self)
                        self.camera:tweenToRelativePoint(300, 0, 6):ease("quadinout")
                    end
                },
                text =
                "Uitgang, [.2]ingang. [.3]Het is maar hoe je het ziet. [.8]Whatever.",
            },
            {
                character = "sicko",
                emotion = "secret",
                sound = "whatever",
                functions = {
                    zap = function(self)
                        self.cutsceneData.sicko_room.video = self.cutsceneData.sicko_room.videoZap
                        self.coil.wait(1)
                        self.cutsceneData.sicko_room.video = self.cutsceneData.sicko_room.videoFriends
                    end
                },
                text =
                "Momenteel is [function=zap]het vooral mijn chillplek.\n[.3]Doe hier gewoon mijn eigen ding weet je.\n[.3]Lekker rustig zonder die wetenschappers.",
            },
            {
                character = "timon",
                emotion = "confused_concerned",
                text = "Wacht, [.3]weet jij misschien meer over het ongeluk?",
            },
            {
                character = "sicko",
                emotion = "secret",
                functions = {
                    switch = function(self)
                        self.cutsceneData.sicko.visible = true
                        self.cutsceneData.setup.anim:set("no_sicko")
                    end,
                    sunglasses = function(self)
                        self.cutsceneData.sicko.anim:set("sunglasses")
                        self.cutsceneData.sicko_room.video = self.cutsceneData.sicko_room.videoRoss
                        local audio = Asset.audio("music/bosses/sicko/decoration/cheer")
                        audio:play()
                        self.coil.wait(4)
                        self.camera:zoomTo(8)
                        self.camera:moveToPoint(self.cutsceneData.setup:centerX() - 10,
                            self.cutsceneData.setup:centerY() - 10)
                    end
                },
                text =
                "Weten? [.8]Makker, [.3]ik[function=switch][emotion=default] [b]ben[/b] het ongeluk.[.8][function=sunglasses][emotion=look][7][auto]",
            },
            {
                character = "timon",
                emotion = "scared_serious",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(40, true)
                        self.cutsceneData.sicko.anim:set("idle")
                        self.camera:moveToRelativePoint(-180, 0)
                        self.camera:zoomTo(2)
                    end
                },
                text =
                "What the hell?![.3]\nJij hebt al die wetenschappers vermoord?!\n[.3]Je bent helemaal gestoord gast!",
            },
            {
                character = "sicko",
                text =
                "Vermoord? [.3]Wat lul je nou slap?",
            },
            {
                character = "sicko",
                functions = {
                    init = function(self)
                        self.cutsceneData.cutscene.visible = true
                        self.cutsceneData.cutscene.anim:set("sicko")
                    end
                },
                text =
                "Ze probeerden de meest chille kip te maken, [.2]en dat is ze gelukt.",
            },
            {
                character = "sicko",
                functions = {
                    init = function(self)
                        self.cutsceneData.cutscene.anim:set("scientists")
                    end
                },
                text =
                "Alleen was ik zó chill dat het onverwachts een effect op de wetenschappers had.",
            },
            {
                character = "sicko",
                functions = {
                    init = function(self)
                        self.cutsceneData.cutscene.anim:set("chill")
                        self.cutsceneData.sicko_room.video = self.cutsceneData.sicko_room.videoGTST
                    end
                },
                text =
                "Ze werden zelf ook chill, [.2]en hadden geen zin meer om te werken. [.3]Vrije geesten, [.2]je weet.",
            },
            {
                character = "sicko",
                sound = "whatever",
                functions = {
                    init = function(self)
                        self.cutsceneData.cutscene.visible = false
                    end
                },
                text =
                "Sindsdien zijn er geen wetenschappers meer in het laboratorium te bekennen. [.3]Whatever.",
            },
            {
                character = "timon",
                emotion = "questioning",
                text =
                "Oh... [.2]oké. [.3]Nou goed, [.3]ik ga er ook maar eens vandoor.",
            },
        },
        part2_timon = {
            {
                character = "sicko",
                emotion = "hold",
                text =
                "Jij gaat helemaal nergens heen, [.2]makker.",
            },
            {
                character = "timon",
                emotion = "sicko",
                text =
                "Laat... [.3]me... [.3]los...",
            },
        },
        part3_timon = {
            {
                character = "sicko",
                emotion = "hold",
                text =
                "Wij horen hier thuis. [.3]Dit is onze chillzone supreme. [.3]Wegrennen is absoluut niet chill."
            },
            {
                character = "sicko",
                emotion = "hold_look",
                functions = {
                    init = function(self)
                        local s = sfx.door_open:play()
                        s:setPosition(-.0005, 0, 0)
                        s:setVolume(.3)
                        self:delay(5, function()
                            s:setPosition(0, 0, 0)
                        end)

                        self.cutsceneData.sicko.anim:set("hold_timon_look")
                    end
                },
                text =
                "Hmmm...?[2][auto]"
            },
        },
        part4_timon = {
            {
                character = "peter",
                emotion = "mad",
                text =
                "Blijf met je ranzige kippentengels van mijn vriend af!"
            },
            {
                character = "timon",
                emotion = "crying_happy",
                functions = {
                    init = function(self)
                        self.timon.looking = true
                    end
                },
                text =
                "Peter... [.2]je leeft nog...?!\n[.3]Ik dacht dat je dood was!"
            },
            {
                character = "peter",
                emotion = "eyes_closed",
                functions = {
                    init = function(self)
                        self.peter.flip.x = true
                        self.peter.looking = true
                    end
                },
                text =
                "Nee joh, [.2]ik deed maar alsof om jou kut te laten voelen.[emotion=happy_wink]"
            },
            {
                character = "peter",
                emotion = "concerned",
                text =
                "Timon, het spijt me van eerder.\n[.3]Ik had die dingen niet moeten zeggen."
            },
            {
                character = "timon",
                emotion = "proud",
                text =
                "Nee het spijt [b]mij[/b], Peter. [.3]Zonder jou was ik nooit zo ver gekomen. [.3]We zijn een [b]Dream Team Supreme![/b]"
            },
            {
                character = "peter",
                emotion = "proud",
                functions = {
                    spangas = function(self)
                        local audio = Asset.audio("music/bosses/sicko/decoration/spangas")
                        audio:play()
                    end
                },
                text =
                "Ja wij... [.5][emotion=questioning]Uhmm... [.2]Als wij samen zijn dan... [.2][emotion=thinking_concerned]Hmm... [.2]hoe kan ik dit het beste zeggen...[2][function=spangas][8][auto]"
            },
            {
                character = "peter",
                emotion = "satisfied",
                text =
                "Ja precies! [.3]Wat die tv zei."
            },
        },
        part5_timon = {
            {
                character = "peter",
                emotion = "determined",
                text =
                "Kom, [.2]we zijn weg hier!"
            },
            {
                character = "sicko",
                sound = "whatever",
                functions = {
                    init = function(self)
                        self.camera:zoomTo(1, 4)
                        local x, y = self.map:getCurrentLevel():center()
                        self.camera:tweenToPoint(x, y, 4)
                    end
                },
                text =
                "Dacht het niet vriend. [.3]De enige weg die jullie zullen nemen is terug het laboratorium in. [.3]Whatever."
            },
            {
                character = "timon",
                emotion = "determined",
                text =
                "Niks ervan! [.3]Peter, we gaan die kip laten zien dat [b]Tiempie Games[/b] onverslaanbaar is!"
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "[b]Tiempie Games[/b]? [.3]Wat is dat nou weer?"
            },
            {
                character = "timon",
                emotion = "determined",
                text =
                "Onze naam als duo! [.3]Tiempie omdat we een team zijn, [.2][emotion=smug_eyes_closed]en omdat ik Timon heet! [.8]En games omdat we games spelen natuurlijk.[emotion=smug_wink]"
            },
            {
                character = "peter",
                emotion = "thinking_sarcastic",
                text =
                "Juist ja. [.3]Daar kunnen we nog aan werken."
            },
            {
                character = "sicko",
                sound = "whatever",
                functions = {
                    fly = function(self)
                        local x, y = self.cutsceneData.sicko:center()
                        self.cutsceneData.sicko:destroy()
                        local level = self.map:getCurrentLevel()
                        local sicko = level:add(SickoBoss(x + 20, y + 5, true))
                        sicko.room = self.cutsceneData.sicko_room
                        sicko.flip.x = true
                        sicko:tween(2.5, level:centerX() - sicko.width / 2, level:centerY() - 140 - sicko.height / 2)
                            :oncomplete(function()
                                sicko:setStart()
                                self.cutsceneData.sickoDoneFlyingCallback()
                            end)
                            :ease("quadin")
                        self.cutsceneData.sicko_room.sicko = sicko
                    end
                },
                text =
                "Inderdaad. [.3][function=fly]En dat doen jullie maar mooi in het laboratorium. [.3]Whatever."
            },
        },
    },
    functions = {
        init = function(self)
            self:fadeIn(1)
            local cutscene = self:addOverlay(Sprite(0, 0, "cutscenes/sicko/experiment", true))
            -- cutscene.scale:set(2)
            cutscene.origin:set(0, 0)
            cutscene.visible = false
            cutscene.removeOnLevelChange = true

            local setup = self:findEntityWithTag("Setup")
            local door = self:findEntityWithTag("Door", function(e) return e.single end)
            door.solid = 0

            local setup_x, setup_y = setup:center()
            local sicko = self:add(Sicko(setup_x - 150, setup_y))
            sicko.visible = false

            self.camera:zoomTo(8)
            self.camera:moveToPoint(setup:centerX() - 10, setup:centerY() - 10)

            self.coil.wait(12)

            self.camera:zoomTo(3)
            self.camera:moveToPoint(setup:centerX() - 1000, setup:centerY() - 100)

            self.coil.wait(1)

            door.anim:set("open_timon")
            sfx.door_open:play()

            self.coil.wait(1.5)

            self.camera:tweenToPoint(setup:centerX() - 1000, setup:centerY(), 1)
            local door_x, door_y = door:center()
            self.timon = self:add(Timon(door_x - 100, door_y + 20))
            self.timon.inCutscene = true
            self.timon:cutsceneWalkTo(135, true)

            local sicko_room = self:findEntityWithTag("SickoRoom")
            sicko_room.setup.anim:set("sicko")

            self.coil.wait(1)

            door.anim:set("close_timon")
            sfx.door_close:play()
            door.solid = 2

            self.coil.wait(1)

            self.cutsceneData = {
                sicko = sicko,
                setup = setup,
                door = door,
                sicko_room = sicko_room,
                cutscene = cutscene
            }

            self:startDialogue("part1_timon")
            self.timon:cutsceneWalkTo(220, true)

            self.coil.wait(1.45)

            self.timon.visible = false
            sicko.anim:set("hold_timon")
            sfx.grab:play("reverb")
            self.scene:rumble(self.timon.controllerId, .4, .3)

            self.coil.wait(.2)
            self.cutsceneData.sicko_room.video = nil

            self:startDialogue("part2_timon")

            self.camera:tweenToRelativePoint(130, 0, .3):ease("linear")
            self.camera:zoomTo(3, .5)

            self.coil.wait(.8)

            sicko.anim:set("punch_timon")

            self.coil.wait(1.4)
            self.scene:rumble(self.timon.controllerId, .8, .3)
            sfx.punch:play("reverb")
            self.coil.wait(1.1)

            self:startDialogue("part3_timon")

            self.coil.wait(.25)

            -- FLASH!
            self.flashOverlay = self:addOverlay(Rect(0, 0, WIDTH, HEIGHT))
            self.flashOverlay:setColor(0, 0, 0)
            self.coil.wait(.05)
            self.flashOverlay:setColor(255, 255, 255)
            self.coil.wait(.05)
            self.flashOverlay:destroy()

            sfx.ko:play("reverb")

            sicko_room.video = sicko_room.videoSpangas
            sicko.anim:set("punched")
            sicko.velocity:set(1300, 0)
            setup.anim:set("no_skateboard")

            self.timon.visible = true
            self.peter = self:add(Peter(sicko:center()))
            self.peter.inCutscene = true
            self.scene:rumble(self.timon.controllerId, .2, .3)
            self.scene:rumble(self.peter.controllerId, .3, .3)
            self.coil.wait(.5)
            self:startDialogue("part4_timon")
            self.coil.wait(1)
            self.peter.looking = false
            self.timon.looking = false
            self.peter:cutsceneWalkTo(-28, true)
            self.timon:cutsceneWalkTo(28, true)
            self.coil.wait(.3)
            self.peter.hugging = true
            self.timon.hugging = true
            self.coil.wait(.5)
            self.camera:tweenToRelativePoint(0, 25, .5)
            self.camera:zoomTo(4, .5)
            self.coil.wait(5)
            self.peter.hugging = false
            self.timon.hugging = false
            self.peter.flip.x = false
            sicko.x = sicko.x - 100
            sicko.anim:set("idle_no_beer")
            self.cutsceneData.sickoDoneFlyingCallback = self.coil:callback()
            self:startDialogue("part5_timon")
            self.coil.wait(self.cutsceneData.sickoDoneFlyingCallback)
            self.players:destroy()
            self.players = list({ self.peter, self.timon })
            self:configurePlayerFollowing()
            self:onEndCutscene()
            sicko_room:initializeRestart(true)
            self:saveGame()
        end,
    },
    flag = Enums.Flag.cutsceneSickoIntro
}

return sicko_intro
