local Sicko = require "characters.sicko"
local SickoBoss = require "bosses.sicko.sicko"
local Sprite = require "base.sprite"
local Rect = require "base.rect"
local Timon = require "characters.players.timon"
local Asset = require "base.asset"
local SFX = require "base.sfx"
local Peter = require "characters.players.peter"

local sfx = {
    door_open = SFX("sfx/interactables/door_open"),
    door_close = SFX("sfx/interactables/door_close"),
    grab = SFX("sfx/cutscenes/sicko/grab"),
    punch = SFX("sfx/cutscenes/sicko/punch"),
    ko = SFX("sfx/cutscenes/sicko/ko"),
}

local sicko_intro = {
    dialogues = {
        part1_peter = {
            {
                character = "peter",
                emotion = "sobbing",
                text = "Timon... *snik*",
            },
            {
                character = "peter",
                emotion = "sobbing_slightly",
                text = "Uhm... *snik* [.2]hallo? [.3]Is dit misschien de uitgang?",
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
                "Uitgang, [.2]ingang. [.3]Het is maar hoe je het bekijkt. [.8]Whatever.",
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
                character = "peter",
                emotion = "crying",
                text = "Wacht, [.3][emotion=thinking_concerned]weet jij toevallig meer over het ongeluk?",
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
                character = "peter",
                emotion = "scared_serious",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(40, true)
                        self.cutsceneData.sicko.anim:set("idle")
                        self.camera:moveToRelativePoint(-180, 0)
                        self.camera:zoomTo(2)
                    end
                },
                text =
                "Jij?! [.3]Heb jij al die wetenschappers vermoord?!\n[.3]Je bent helemaal geflipt gast!",
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
                character = "peter",
                emotion = "questioning",
                text =
                "Ah... [.2]juist ja. [.3]Nou goed, [.3]tijd voor mij om ook maar eens te vertrekken.",
            },
        },
        part2_peter = {
            {
                character = "sicko",
                emotion = "hold",
                text =
                "Jij gaat helemaal nergens heen, [.2]makker.",
            },
            {
                character = "peter",
                emotion = "sicko",
                text =
                "Laat... [.3]me... [.3]gaan...",
            },
        },
        part3_peter = {
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

                        self.cutsceneData.sicko.anim:set("hold_peter_look")
                    end
                },
                text =
                "Hmmm...?[2][auto]"
            },
        },
        part4_peter = {
            {
                character = "timon",
                emotion = "angry_teeth",
                text =
                "Blijf met je gore kippentengels van mijn vriend af!"
            },
            {
                character = "peter",
                emotion = "crying_happy",
                functions = {
                    init = function(self)
                        self.peter.looking = true
                    end
                },
                text =
                "Timon... [.2]je leeft nog...?!\n[.3]Ik dacht dat je neer was!"
            },
            {
                character = "timon",
                emotion = "eyes_closed",
                functions = {
                    init = function(self)
                        self.timon.flip.x = true
                        self.timon.looking = true
                    end
                },
                text =
                "Nee joh, [.2]ik deed maar alsof zodat jij je klote zou voelen.[emotion=happy_wink]"
            },
            {
                character = "peter",
                emotion = "sobbing_slightly",
                text =
                "Timon, het spijt me van eerder.\n[.3]Ik had die dingen niet moeten zeggen."
            },
            {
                character = "timon",
                emotion = "sobbing_slightly",
                text =
                "Nee het spijt [b]mij[/b], Peter. [.3][emotion=crying_happy]Zonder jou was ik nooit zo ver gekomen. [.3][emotion=determined]We zijn een [b]Dream Team Supreme![/b]"
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
                "Ja, wij... [.5][emotion=questioning]uhmm... [.2]Als wij samen zijn dan... [.2][emotion=thinking_concerned]Hmm... [.2]hoe kan ik dit het beste zeggen...[2][function=spangas][8][auto]"
            },
            {
                character = "peter",
                emotion = "satisfied",
                text =
                "Ja precies! [.3]Wat die tv zei."
            },
        },
        part5_peter = {
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

            door.anim:set("open_peter")
            sfx.door_open:play()

            self.coil.wait(1.5)

            self.camera:tweenToPoint(setup:centerX() - 1000, setup:centerY(), 1)
            local door_x, door_y = door:center()
            self.peter = self:add(Peter(door_x - 100, door_y + 20))
            self.peter.inCutscene = true
            self.peter:cutsceneWalkTo(135, true)

            local sicko_room = self:findEntityWithTag("SickoRoom")
            sicko_room.setup.anim:set("sicko")

            self.coil.wait(1)

            door.anim:set("close_peter")
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

            self:startDialogue("part1_peter")
            self.peter:cutsceneWalkTo(210, true)

            self.coil.wait(1.65)

            self.peter.visible = false
            sicko.anim:set("hold_peter")
            sfx.grab:play("reverb")
            self:rumble(self.peter.controllerId, .4, .3)

            self.coil.wait(.2)
            self.cutsceneData.sicko_room.video = nil

            self:startDialogue("part2_peter")

            self.camera:tweenToRelativePoint(130, 0, .3):ease("linear")
            self.camera:zoomTo(3, .5)

            self.coil.wait(.8)

            sicko.anim:set("punch_peter")

            self.coil.wait(1.4)
            self:rumble(self.peter.controllerId, .8, .3)
            sfx.punch:play("reverb")
            self.coil.wait(1.1)

            self:startDialogue("part3_peter")

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

            self.peter.visible = true
            self.timon = self:add(Timon(sicko:center()))
            self.timon.x = self.timon.x + 20
            self.timon.inCutscene = true
            self:rumble(self.peter.controllerId, .2, .3)
            self:rumble(self.timon.controllerId, .3, .3)
            self.coil.wait(.5)
            self:startDialogue("part4_peter")
            self.coil.wait(1)
            self.timon.looking = false
            self.peter.looking = false
            self.timon:cutsceneWalkTo(-33, true)
            self.peter:cutsceneWalkTo(33, true)
            self.coil.wait(.3)
            self.timon.hugging = true
            self.peter.hugging = true
            self.coil.wait(.5)
            self.camera:tweenToRelativePoint(0, 25, .5)
            self.camera:zoomTo(4, .5)
            self.coil.wait(5)
            self.timon.hugging = false
            self.peter.hugging = false
            self.timon.flip.x = false
            sicko.x = sicko.x - 100
            sicko.visible = true
            sicko.anim:set("idle_no_beer")
            self.cutsceneData.sickoDoneFlyingCallback = self.coil:callback()
            self:startDialogue("part5_peter")
            self.coil.wait(self.cutsceneData.sickoDoneFlyingCallback)
            self.players:destroy()
            self.players = list({ self.peter, self.timon })
            self:configurePlayerFollowing()
            self:onEndCutscene()
            local checkpoint = self:findEntityWithTag("Checkpoint")
            self:onReachingCheckpoint(checkpoint)
            sicko_room:initializeRestart(true)
            self:saveGame()
        end,
    },
    flag = Enums.Flag.cutsceneSickoIntro
}

return sicko_intro
