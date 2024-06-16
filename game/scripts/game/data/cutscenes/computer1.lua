local voice = function(self)
    self:findEntityWithTag("Computer").mode = "voice"
end

local eye = function(self)
    self:findEntityWithTag("Computer").mode = "eye"
end

local computer_functions = {
    init = voice,
    eye = eye
}

local computer = {
    dialogues = {
        part1 = {
            {
                character = "peter",
                emotion = "questioning",
                text = "Wow, [.2]het is hier zo donker."
            },
            {
                character = "timon",
                emotion = "scared",
                text = "Wel een beetje eng..."
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Vind je?\n[.5][emotion=arms_crossed_eyes_closed]Nou goed, [.2]ik ben dan ook niet zo snel bang."
            },
            {
                character = "computer",
                sound = "detected",
                emotion = "secret",
                text = "Stemmen gedetecteerd.[.2][auto]"
            },
            {
                character = "peter",
                emotion = "scared_serious_sweat",
                text = "Wat was dat?!"
            },
        },
        part2 = {
            {
                functions = computer_functions,
                character = "computer",
                sound = "welcome",
                settings = {
                    print_speed = .07
                },
                text =
                "Welkom terug, P3-TR en T1-MN. [.3]Het is vandaag 6 oktober 2013. [.3]Zijn jullie klaar voor jullie test?[function=eye][emotion=eye]",
            },
            {
                character = "timon",
                emotion = "scared_serious",
                text = "Wow, [.2]wat is dat voor een ding?!\n[.3]Het kent onze namen, Peter!"
            },
            {
                character = "peter",
                emotion = "scared",
                text = "Test? [.3]W-Welke test?"
            },
            {
                functions = {
                    init = function(self)
                        local peter = self:findEntityWithTag("Peter")
                        peter:cutsceneWalkTo(300, true)
                        local timon = self:findEntityWithTag("Timon")
                        timon:cutsceneWalkTo(200, true)
                        self:findEntityWithTag("Computer").mode = "voice"
                    end,
                    eye = eye
                },
                character = "computer",
                sound = "last_test",
                settings = {
                    print_speed = .05
                },
                text =
                "De wekelijkse test om jullie vaardigheden in videogames te berekenen. [.5]Het is [.3]3946 dagen geleden [.7]sinds de laatste test.[function=eye][emotion=eye]"
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "3946 dagen? [.3][emotion=thinking]Maar dat is... [.3]dat is[.2].[.2].[.2].\n[.4][emotion=thinking_serious]Wacht, laat me rekenen..."
            },
            {
                functions = {
                    init = function(self)
                        self.noDoorAccess = true
                    end
                },
                character = "peter",
                text = "Dat is echt heel veel jaar!"
            },
            {
                character = "timon",
                text = "Beste wensen nog..."
            },
            {
                character = "timon",
                emotion = "mad",
                text = "Maar hoelang kunnen ze wel niet over die pauze doen joh?!"
            },
            {
                functions = {
                    init = function(self)
                        local peter = self:findEntityWithTag("Peter")
                        local timon = self:findEntityWithTag("Timon")
                        peter:lookAt(timon)
                    end
                },
                character = "peter",
                emotion = "thinking_concerned",
                text =
                "Nee Timon, [.2]ik denk dat er geen pauze is. [.3]We zaten drieduizend[.2].[.2].[.2].[.2][emotion=thinking_sarcastic]weet ik veel hoeveel dagen, [.2]vast in die buizen!"
            },
            {
                character = "peter",
                emotion = "concerned",
                text =
                "We zijn hier [b]alleen[/b], [.2]in een [b]verlaten[/b] laboratorium!"
            },
            {
                character = "timon",
                emotion = "shocked",
                text = "[b]JEUTJE![/b]"
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Maar wat doen wij hier dan nog?!"
            },
            {
                character = "peter",
                text = "Ik weet wat we gaan doen. [.2]We piepen 'm!"
            },
            {
                character = "timon",
                emotion = "questioning",
                text = "Is dat zo'n rattengeintje of...?"
            },
        },
        part3 = {
            {
                character = "peter",
                emotion = "questioning",
                text =
                "De deuren zijn dicht, Timon. [.3]Hoe kan dit nou?",
            },
            {
                character = "timon",
                functions = {
                    init = function(self)
                        local level = self.map:getCurrentLevel()
                        self.peter.flip.x = self.peter:centerX() > level.x + level.width / 2
                        self.timon.flip.x = self.timon:centerX() > level.x + level.width / 2
                    end
                },
                text =
                "Hey computer, [.2]doe die deuren open! [.3]We willen hier weg!",
            },
            {
                character = "computer",
                sound = "denied",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Toegang om te vertrekken geweigerd. Jullie zullen eerst de test moeten voltooien.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "mad",
                text =
                "Maar wij hebben helemaal geen zin in die test! [.3]Laat ons nou maar gaan!",
            },
            {
                character = "computer",
                sound = "rules",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Zolang de test niet is voltooid, kan ik jullie geen toegang verlenen om deze kamer te verlaten. Dat zijn de regels.[emotion=eye][function=eye]",
            },
            {
                character = "timon",
                emotion = "sarcastic_mad",
                text =
                "Heel vervelend dit. [.5][emotion=default]Laten we die test nou maar gewoon doen, Peter, [.2]dan kunnen we daarna weg hier.",
            },
            {
                character = "peter",
                text =
                "Ja, lijkt erop dat we geen keus hebben. [.3]Wat houdt die test precies in?",
            },
            {
                character = "computer",
                sound = "explanation1",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "De test is simpel. [.3]Jullie spelen een videogame, waarbij ik jullie vaardigheden analyseer.[emotion=eye][function=eye]",
            },
            {
                character = "computer",
                sound = "explanation2",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Na de test vertel ik de resultaten van mijn analyse, en of jullie zijn geslaagd.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                text =
                "Helder.",
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Start die klotetest nou maar!",
            },
            {
                character = "computer",
                sound = "millions",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Ik ga nu een willekeurige videogame selecteren uit mijn database van miljoenen videogames.[emotion=eye][function=eye][2][auto]",
            },
        },
        part4 = {
            {
                character = "computer",
                sound = "spacer_racer",
                settings = {
                    print_speed = .05
                },
                emotion = "eye",
                text =
                "Mijn willekeurige selectie is uitgekomen op Spacer Racer. Toevallig een van mijn favoriete videogames.",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                text =
                "Heel toevallig ja...",
            },
            {
                character = "computer",
                sound = "first_three_levels",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "In Spacer Racer bestuur je samen een UFO om naar de finish te racen. Voor deze test moeten jullie de eerste drie levels halen.[emotion=eye][function=eye]",
            },
            {
                character = "timon",
                emotion = "questioning",
                text = "Hoe gaan we het spelen? [.3]Heb je controllers voor ons?"
            },
            {
                character = "computer",
                sound = "countdown1",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Er is geen controller nodig. Er zal gebruik worden gemaakt van een simulatie. Ik start de simulatie in 10[1], 9[1], 8[1], 7[1], 6[.3][function=eye][auto]",
            },
            {
                character = "peter",
                emotion = "shocked_hands",
                text =
                "Wacht wacht wacht![.4] Beginnen we bij de 0 of bij de go?",
            },
            {
                character = "computer",
                sound = "countdown2",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "[[]Aftelling onderbroken][.5]\nDe simulatie zal starten bij de go.\n10[1], 9[1], 8[1], 7[1], 6[1], 5[.3][function=eye][auto]",
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Halt![.5] [emotion=confused]Is het zeg maar '3 2 1 go' of '3 2 1 0' en dan go?",
            },
            {
                character = "computer",
                sound = "countdown3",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "[[]Aftelling onderbroken][.5]\nHet is 3 2 1 0 en dan go.[function=eye]",
            },
            {
                character = "computer",
                sound = "countdown4",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "[[]Snel-aftelmodule geactiveerd][.5]\n[speed=.0167]10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, go.[function=eye][auto]",
            },
        },
        part5 = {
            {
                character = "computer",
                sound = "results",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Einde van de simulatie.\n[.2]Resultaten van de analyse berekenen.\n[.3]Even geduld alstublieft.[emotion=eye][function=eye][2][auto]",
            },
            {
                character = "computer",
                sound = "silence",
                emotion = "eye",
                settings = {
                    print_speed = .05
                },
                functions = {
                    voice = voice,
                    eye = eye
                },
                text =
                "[6.4][emotion=default][function=voice]De resultaten worden berekend.\n[.3]Nog even geduld alstublieft.[emotion=eye][function=eye][2][auto]",
            },
            {
                character = "computer",
                emotion = "eye",
                sound = "silence",
                settings = {
                    print_speed = .05
                },
                functions = {
                    voice = voice,
                    eye = eye
                },
                text =
                "[4.8][emotion=default][function=voice]De resultaten worden berekend.\n[.3]Nog even geduld alstublieft.[emotion=eye][function=eye][2][auto]",
            },
            {
                character = "computer",
                emotion = "eye",
                sound = "silence",
                settings = {
                    print_speed = .05
                },
                functions = {
                    voice = voice,
                    eye = eye
                },
                text =
                "[6.3][emotion=default][function=voice]Bekijk ook onze aanbiedingen op w[.1]w[.1]w[.1].supercomputer[auto]",
            },
            {
                character = "computer",
                sound = "results",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Bedankt voor het wachten. Klaar met het berekenen van de resultaten.[.4]\nDe resultaten zijn[.5] uitstekend.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "mad",
                functions = {
                    init = function(self)
                        self.music:play("computer/neutral", 1)
                    end
                },
                text =
                "Uitstekend? [.3]Dat is alles? [.3]Daar moest je 10 minuten over doen?!",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text =
                "Ja ik verwachtte eigenlijk iets heel uitgebreids. [.3]Over onze snelheid en zo.",
            },
            {
                character = "computer",
                sound = "waittime",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Willen jullie een uitgebreide analyse van de resultaten? De geschatte wachttijd is 3 uur en [.5]42 minuten.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "shocked_hands",
                text =
                "NEE!",
            },
            {
                character = "timon",
                emotion = "shocked_ep",
                text =
                "HALT! [.3]Nee alsjeblieft niet."
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Mogen we nu gaan?"
            },
            {
                character = "computer",
                sound = "completed_weekly",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Jullie zijn geslaagd. [.3]De wekelijkse test is voltooid. [.2]Jullie mogen gaan.[emotion=eye][function=eye]",
            },
        }
    },
    functions = {
        prepare = function(self)
            local computer = self:findEntityWithTag("Computer")
            self.darkness.alpha = .9
            computer.mode = "off"
        end,
        init = function(self)
            self:startDialogue("part1")
            local computer = self:findEntityWithTag("Computer")
            computer:turnOn()
            self.music:play("computer/scary", 1)
            self.coil.wait(6)
            self:startDialogue("part2")
            local cutscene = self.cutscene
            self.musicCallbackAfterCutscene = nil
            self:onEndCutscene(true, true)
            self.music:pause(2)
            self.coil.wait(8)
            self.players:goIntoCutscene()
            self.inCutscene = true
            self.cutscene = cutscene
            self:showCutsceneBars()
            self.ui:hide()
            self.music:resume(2)
            self:startDialogue("part3")
            computer:pickRandomVideogame()
            self.coil.wait(6.2)
            self:startDialogue("part4")
            self.coil.wait(.5)
            self:startSucking()
            self.coil.wait(3)
            local cb = self.coil.callback()
            self:toUfoGame({ 0, 1, 2 }, cb)
            self.coil.wait(cb)
            self.coil.wait(2)
            self:startDialogue("part5")
            self.noDoorAccess = false
            self:onEndCutscene()
        end
    },
    flag = Enums.Flag.cutsceneComputer1
}

return computer
