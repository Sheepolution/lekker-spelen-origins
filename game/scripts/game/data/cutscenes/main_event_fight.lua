local SFX = require "base.sfx"
local lightning_sfx = SFX("sfx/cutscenes/main_event_fight/lightning")


local main_event_fight = {
    dialogues = {
        part1 = {
            {
                character = "peter",
                emotion = "frustrated",
                text = "Oh man! [.2]Het is hier zo licht!",
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text = "Inderdaad! [.2]Die zon doet pijn aan mijn ogen...",
            },
            {
                character = "peter",
                emotion = "frustrated",
                text = "Wacht... [.2][emotion=default]Zon? [.5][emotion=thinking]En wolken[.1].[.1].[.1].",
            },
            {
                character = "timon",
                emotion = "happy_tongue",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(500, true)
                        self.peter:cutsceneWalkTo(150, true)
                    end,
                },
                text = "We zijn buiten! [.3]Het is ons gelukt!",
            },
            {
                character = "peter",
                emotion = "happy",
                text = "De zoete geur van vrijheid! [.3]En allemaal omdat jij zo lekker bezig was, Timon!",
            },
            {
                character = "timon",
                emotion = "happy_wink",
                text = "Zonder jou was het niet gelukt, Peter!",
                functions = {
                    init = function(self)
                        self.timon:lookAt(self.peter)
                    end,
                },
            },
            {
                character = "peter",
                emotion = "happy_wink",
                text = "Ja maar jij wist echt precies wat we moesten doen steeds!",
            },
            {
                character = "timon",
                emotion = "satisfied",
                text = "Ja maar jij was heel goed met dat klonen!",
            },
            {
                character = "peter",
                emotion = "laughing_no_hand",
                text = "Maar dat dansen ging jou heel goed af!",
            },
            {
                character = "timon",
                emotion = "laughing",
                text = "En jij was echt heel slim bij die dierenvragen!",
            },
            {
                character = "peter",
                emotion = "laughing",
                text = "Vergeet dat geflipte paard niet![.3]\nDat deed jij heel goed!",
            },
            {
                character = "timon",
                emotion = "laughing_lines",
                text = "Haha ja! [.3]En hoe jij die cart bestuurde was echt professioneel gewoon!",
            },
            {
                character = "peter",
                emotion = "laughing",
                text =
                "Haha, [.3]nou goed, [.3][emotion=arms_crossed_eyes_closed]daarom ben ik natuurlijk ook\n[b]Main Event[/b]!",
            },
            {
                character = "timon",
                emotion = "laughing_tears",
                functions = {
                    darker = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:darker(0.85)
                    end
                },
                text =
                "Inderda- [1][function=darker][emotion=confused_mad]Wacht.[.3] [b]Jij[/b] Main Event?[.3] Dat meen je niet serieus, [.2]toch?",
            },
            {
                character = "peter",
                emotion = "arms_crossed_tired",
                functions = {
                    init = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:darker(0.71)
                    end
                },
                text = "Wat? [.3]Je denkt toch niet dat [b]jij[/b] de Main Event bent?",
            },
            {
                character = "timon",
                emotion = "smug_eyes_closed",
                functions = {
                    init = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:darker(0.57)
                    end
                },
                text =
                "Oh zeker weten wel! [.3]Heb je gezien hoe ik met gemak die gorilla neerhaalde, [.2]terwijl jij amper kon mikken?",
            },
            {
                character = "peter",
                emotion = "arms_crossed_frustrated",
                functions = {
                    init = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:darker(0.42)
                    end
                },
                text =
                "Oh, [.2]bedoel je die gorilla die zo gigantisch werd, omdat jij zo dom was om op die knop te drukken?",
            },
            {
                character = "timon",
                emotion = "angry",
                functions = {
                    init = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:darker(0.28)
                    end
                },
                text =
                "Nou ik [b]druk[/b] tenminste op knoppen! [.3]Jij loopt een beetje voor je uit te staren terwijl ik alles doe hier.",
            },
            {
                character = "peter",
                emotion = "angry",
                functions = {
                    init = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:darker(0.14)
                    end
                },
                text =
                "Zonder mij zou je amper weten wat je moet doen! [.3]Ik ben het meesterbrein dat al die puzzels oplost!"
            },
            {
                character = "peter",
                emotion = "angry_fist",
                functions = {
                    init = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:darker(0)
                    end
                },
                text =
                "Jij voert simpelweg uit wat ik zeg![.3]\nAls een, [.5][emotion=thinking_serious]als een[.1].[.1].[.1]."
            },
            {
                character = "peter",
                emotion = "arms_crossed_evil",
                functions = {
                    lightning = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:lightning()
                        lightning_sfx:play()
                        self.music:play("cutscenes/main_event_fight/ambience", nil, true, 11.32)
                    end
                },
                text =
                "Als een [b]sidekick![/b][function=lightning]"
            },
            {
                character = "timon",
                emotion = "angry_teeth",
                text =
                "Jij denkt echt dat je het mannetje bent, of niet soms?"
            },
            {
                character = "peter",
                emotion = "arms_crossed_eyes_closed",
                text =
                "Nee niet het mannetje, Timon. [.3]Main Event.[.3]\nIets wat jij nooit zal zijn, jij domme hond!"
            },
            {
                character = "timon",
                emotion = "furious",
                text =
                "Jij bent echt zo'n vuile rat, Peter![.3]\nIk zou je zo graag een keer in je maag willen stompen, serieus!"
            },
            {
                character = "peter",
                emotion = "furious_fist",
                text =
                "Denk je echt dat je mij aankan? [.3]Ik breek met gemak dat zielige hondennekkie van je!"
            },
            {
                character = "timon",
                emotion = "furious",
                text =
                "Laten we het uitvechten dan!\n[.5]1 tegen 1. [.5]Hier. [.5]Nu."
            },
            {
                character = "peter",
                emotion = "furious",
                text =
                "En de winnaar is officieel Main Event!"
            },
        },
        part2 = {
            {
                character = "peter",
                emotion = "arms_crossed_evil",
                functions = {
                    lightning = function(self)
                        local room = self:findEntityWithTag("OutsideScene")
                        room:lightning()
                    end
                },
                text =
                "Als een [b]sidekick![/b][2][function=lightning]"
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Laten we het uitvechten dan!\n[.5]1 tegen 1. [.5]Hier. [.5]Nu."
            },
            {
                character = "peter",
                emotion = "mad",
                text =
                "En de winnaar is officieel Main Event!"
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self.music:stop(2, true)
            self:delay(2, function()
                self.ambience:stop(4)
                self:toFightingGame(false, true)
            end)
            self.coil.wait(5)
            self:onEndCutscene()
            self.peter.inControl = false
            self.timon.inControl = false
            self.coil.wait(2)
            self.ui:hide()
        end,
    },
}

return main_event_fight
