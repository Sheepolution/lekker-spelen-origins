local SFX = require "base.sfx"

local konkie_intro = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "sick",
                text =
                "Die cart was dus echt het kutste in mijn leven ooit...",
            },
            {
                character = "peter",
                emotion = "determined",
                text = "We hebben bijna dat laatste pasje Timon! [.3]We zijn zo dichtbij voor mijn gevoel.",
            },
            {
                character = "timon",
                emotion = "confused",
                text =
                "Ik voel het ook, [.2]maar het zou me niet verbazen als we eerst nog een opperbeast moeten verslaan.",
            },
            {
                character = "peter",
                emotion = "thinking_sarcastic",
                text = "Ja inderdaad. [.3]Wat voor een geflipte gaan we deze keer tegenkomen?",
            },
            {
                character = "timon",
                emotion = "determined",
                text = "Misschien wel een full-grown T-Rex die vuur spuwt!",
            },
            {
                character = "peter",
                emotion = "laughing_mad",
                text = "Of wat dacht je van zo'n megalodon met laser-ogen!",
            },
            {
                character = "timon",
                emotion = "laughing",
                text = "Noooouuuu!! [.3]Of een big suchu- [.5][emotion=confused]Wacht. [.3]Wat is dat?",
            },
        },
        part2 = {
            {
                character = "timon",
                emotion = "happy_blush",
                text = "Kiekiekiek! [.3]Wat een leukie!",
            },
            {
                character = "peter",
                emotion = "happy_blush",
                text = "Ja die is heel lief! [.3]Nou goed, ik denk dat we die wel kunnen negeren.",
            },
            {
                character = "timon",
                emotion = "happy",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(550, true, function() self.peter.flip.x = true end)
                        self.timon:cutsceneWalkTo(280, true)
                        self.camera:tweenToRelativePoint(240, 0, 3)
                    end
                },
                text = "Ja, [.2]hij zit achter glas ook. [.3]Wat wil ie doen?",
            },
            {
                character = "timon",
                emotion = "questioning",
                text = "Hey Peter, wacht. [.3]Wat zou deze knop doen denk je?",
            },
            {
                character = "peter",
                emotion = "concerned",
                text = "Niet drukken. [.3]Dat kan echt van alles zijn.",
            },
            {
                character = "timon",
                emotion = "happy_tongue",
                text = "Maar misschien bevrijden we dan wel die cutie!",
            },
            {
                character = "peter",
                emotion = "angry",
                functions = {
                    zoom = function(self)
                        self.camera:zoomTo(1, 1)
                        local level = self.map.currentLevel
                        self.camera:tweenToPoint(level.x + level.width / 2, level.y + level.height / 2, 1)
                    end
                },
                text =
                "Ja of misschien activeert het dat[function=zoom] gigantische apparaat boven zijn hoofd. [.3][emotion=frustrated]Niet drukken, Timon.",
            },
            {
                character = "timon",
                emotion = "eyes_closed",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(150, true)
                        self.coil.wait(.5)
                        self.peter.flip.x = false
                    end
                },
                text = "Oké oké, [.5]rustig maar.",
            },
            {
                character = "timon",
                emotion = "default",
                functions = {
                    init = function(self)
                        self.timon.flip.x = true
                    end,
                    button = function(self)
                        self.cutsceneData.room.button.anim:set("on")
                        self.cutsceneData.room.laser.anim:set("turn_on")
                        SFX("sfx/bosses/konkie/laser_charge"):play()
                    end
                },
                text = "Toch even kijken...[function=button][2][auto]",
            },
            {
                character = "peter",
                emotion = "shocked_ep_hands",
                functions = {
                    init = function(self)
                        self.peter.flip.x = true
                    end
                },
                text = "TIMON JIJ HOND![2][auto]",
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
            local room = self:findEntityWithTag("KonkieRoom")
            self.cutsceneData = { room = room }

            self:startDialogue("part1")

            self.camera:tweenToRelativePoint(160, 0, 1)
            self.camera:zoomTo(2, 1)

            self.coil.wait(5)

            self:startDialogue("part2")
            room.glass.anim:set("explosion")

            self.coil.wait(10)

            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneKonkieIntro
}

return konkie_intro
