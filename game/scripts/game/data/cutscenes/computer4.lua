local Save = require "base.save"

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
                emotion = "sarcastic_extreme",
                text = "Het zal weer 's niet."
            },
            {
                character = "timon",
                emotion = "sarcastic_extreme",
                text = "Daar heb je 'm weer hoor."
            },
            {
                character = "computer",
                sound = "4/welcome",
                settings = {
                    print_speed = .088
                },
                functions = computer_functions,
                text =
                "Welkom, P3-TR en T1-MN.[emotion=eye][function=eye]",
            },
            {
                character = "timon",
                functions = {
                    close = function(self)
                        self.noDoorAccess = true
                    end
                },
                emotion = "mad",
                text = "Hey je zegt steeds onze oude namen, [.2]maar we noemen onszelf nu Peter en Timon ja!"
            },
            {
                character = "computer",
                sound = "4/names1",
                settings = {
                    print_speed = .053
                },
                functions = computer_functions,
                text =
                "Mijn excuses. [.3]Ik zal jullie namen aanpassen in mijn database.[emotion=eye][function=eye][1][auto]"
            },
            {
                character = "computer",
                sound = "4/names2",
                settings = {
                    print_speed = .03
                },
                functions = computer_functions,
                text =
                "[[]Namen gewijzigd]\n[.3][textspeed=.06]Welkom, Peter en Simon.[emotion=eye][function=eye]"
            },
            {
                character = "timon",
                emotion = "mad",
                text = "Nee niet Simon. [.3]TIMON!"
            },
            {
                character = "computer",
                sound = "4/names3",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text = "Mijn excuses. [.3]Ik zal de naam nogmaals aanpassen.[emotion=eye][function=eye][1][auto]"
            },
            {
                character = "computer",
                sound = "4/names4",
                settings = {
                    print_speed = .03
                },
                functions = computer_functions,
                text = "[[]Naam gewijzigd]\n[.3][textspeed=.06]Welkom, Peter en Tommy.[emotion=eye][function=eye]"
            },
            {
                character = "timon",
                emotion = "shocked_mad",
                text = "Tommy?! [.3]Nee niet Tommy! [.3]Timon! [.3]TI-[.1]MON!"
            },
            {
                character = "computer",
                sound = "4/names5",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "U herhaalt deze actie te vaak in korte tijd. [.3]Probeer het later nog eens.[emotion=eye][function=eye]"
            },
            {
                character = "timon",
                emotion = "sarcastic_extreme_mad",
                text = "Verdomme man!"
            },
            {
                character = "peter",
                emotion = "arms_crossed",
                text = "Maar hoe zit het? [.3]Moeten we nog een test doen of zo?"
            },
            {
                character = "computer",
                sound = "4/yearly",
                settings = {
                    print_speed = .04
                },
                functions = computer_functions,
                text =
                "Correct. [.3]De jaarlijkse test.[emotion=eye][function=eye]"
            },
            {
                character = "peter",
                text =
                "Ja ik dacht al zoiets. [.3]Nou start die Spacer Racer maar weer op.",
            },
            {
                character = "computer",
                sound = "4/millions",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Niet zo snel. [.3]Ik zal eerst een willekeurige videogame selecteren uit mijn database van miljoenen videogames.[emotion=eye][function=eye]"
            },
        },
        part2 = {
            {
                character = "computer",
                sound = "4/spacer_racer",
                settings = {
                    print_speed = .05
                },
                emotion = "eye",
                text =
                "Mijn willekeurige selectie is uitgekomen op Spacer Racer.[.4] Dit begint bijna eng te worden, zo toevallig.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Zitten er überhaupt nog meer games in je database?",
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text =
                "Ja noem eens wat games op!",
            },
            {
                character = "computer",
                sound = "4/of_course",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Uiteraard. [.3]Mijn database bestaat uit miljoenen videogames. [.3]Laat me de titels van enkele willekeurige games opnoemen.[emotion=eye][function=eye][.5][auto]"
            },
            {
                character = "computer",
                sound = "4/racers",
                settings = {
                    print_speed = .07
                },
                functions = computer_functions,
                text =
                "Spacer Racer 2. [.3]Spacer Racer 3. [.3]Spacer Racer 3: [.2]Part II: [.2]Return of the Racer. [.3]Spacer Racer 4: [.2]Racing from Memo[emotion=eye][function=eye][auto]",
            },
            {

                character = "peter",
                emotion = "shocked",
                text =
                "Ja oké duidelijk!",
            },
            {

                character = "timon",
                emotion = "mad",
                text =
                "Start die simulatie nou maar!",
            },
            {
                character = "computer",
                sound = "2/countdown",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Ik start de simulatie in\n[[]Snel-aftelmodule geactiveerd][.5]\n[speed=.0167]10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, go.[function=eye][auto]",
            },
        },
        part3 = {
            {
                character = "computer",
                sound = "4/admit",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Einde van de simulatie.\n[.2]Ik moet jullie iets bekennen.[emotion=eye][function=eye]",
            },
            {
                character = "computer",
                sound = "4/no_coincidence",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Het was geen toeval dat steeds Spacer Racer werd gekozen bij de willekeurige selectie.[emotion=eye][function=eye]",
            },
            {

                character = "peter",
                emotion = "sarcastic",
                text =
                "Je meent het.",
            },
            {

                character = "timon",
                emotion = "tired_mad",
                text =
                "Dat hadden we dus zeg maar wel al door.",
            },
            {
                character = "computer",
                sound = "4/my_videogame",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Ah, is dat zo? [.3]Hoe dan ook, ik hoop dat jullie hebben genoten van mijn videogame.[emotion=eye][function=eye]",
            },
            {

                character = "peter",
                emotion = "thinking",
                text =
                "Wacht, [.5][emotion=questioning][b]jouw[/b] videogame?",
            },
            {

                character = "timon",
                emotion = "happy_tongue",
                text =
                "Dus daarom was jij de eindbaas!",
            },
            {
                character = "computer",
                sound = "4/for_you",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Correct. [.3]Deze videogame heb ik speciaal voor jullie ontworpen. [.3]Ik hoop dat jullie het leuk vonden.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "happy",
                text =
                "Wow! [.3]Je hebt een hele videogame in elkaar gezet, [.2][emotion=proud]speciaal voor ons?",
            },
            {
                character = "timon",
                emotion = "happy",
                text =
                "Dat is heel cute! [.3]Zoveel moeite, [.2]en dat voor twee simpele gozers.",
            },
            {
                character = "computer",
                sound = "4/free_time",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Graag gedaan.[.3]\nIk had wat vrije tijd sinds [.3]het ongeluk.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Het ongeluk? [.3][emotion=thinking_concerned]Wat is het ongeluk?",
            },
            {
                character = "computer",
                sound = "4/denied",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "[[]Toegang geweigerd]\n[.3]Informatie over het ongeluk is geclassificeerd, en vereist een wachtwoord.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "thinking_sarcastic",
                text =
                "Verdomme...",
            },
            {
                character = "timon",
                emotion = "default",
                text =
                "Wat is het wachtwoord?",
            },
            {
                character = "peter",
                emotion = "frustrated",
                settings = {
                    print_speed = .05
                },
                text =
                "Timon, [.2]hij gaat ons toch niet vertellen wat het wachtwo-[.3][auto]",
            },
            {
                character = "computer",
                sound = "4/password",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Het wachtwoord is [.35]'1[.35]9[.35]8[.35]3'.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Oh[.1].[.1].[.1]. [.3]oké. [.3]Vertel ons over het ongeluk. [.3]1[.1]9[.1]8[.1]3.",
            },
            {
                character = "computer",
                sound = "4/accepted",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "[[]Toegang geaccepteerd]\nHet ongeluk gebeurde [textspeed=.06]3942 dagen geleden.[/textspeed][emotion=eye][function=eye]",
            },
            {
                character = "computer",
                sound = "4/experiment",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Wetenschapper waren zoals gebruikelijk aan het experimenteren met een dier.[emotion=eye][function=eye]",
            },
            {
                character = "computer",
                sound = "4/no_scientists",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Maar deze keer liep het experiment flink uit de hand, met als gevolg [textspeed=.04]dat er geen wetenschappers meer in dit laboratorium te vinden zijn.[/textspeed][emotion=eye][function=eye]",
            },
            {
                character = "timon",
                emotion = "confused",
                text =
                "Een experiment met een dier...?",
            },
            {
                character = "peter",
                emotion = "thinking_serious",
                text =
                "Wat voor geflipt beest zou dat kunnen zijn geweest...?",
            },
            {
                character = "computer",
                sound = "4/no_more_information",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Helaas heb ik niet meer informatie over het ongeluk. Ik heb inmiddels wel de resultaten van de test berekend.[emotion=eye][function=eye]",
            },
            {
                character = "computer",
                sound = "4/results",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "De resultaten zijn [.5]fantastisch.[emotion=eye][function=eye]",
            },
            {
                character = "timon",
                emotion = "laughing_lines",
                text =
                "Nee [b]jij[/b] bent fantastisch!",
            },
            {
                character = "peter",
                emotion = "happy_wink",
                text =
                "Je bent een droomgozer, supercomputer.[.3][emotion=determined]\nKom Timon, [.2]nog maar één zo'n pasje en dan zijn we weg hier!",
            },
            {
                character = "computer",
                sound = "4/good_luck",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Succes, [.2]Peter en Tommy.[emotion=eye][function=eye]",
            },
            {
                character = "timon",
                emotion = "angry",
                text =
                "TIMON!",
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
            local computer = self:findEntityWithTag("Computer")
            computer:turnOn()
            self.music:play("computer/neutral", 3.5)
            self.coil.wait(3.5)
            self:startDialogue("part1")
            computer:pickRandomVideogame()
            self.coil.wait(6.2)
            self:startDialogue("part2")
            self:startSucking()
            self.coil.wait(3)
            local cb = self.coil.callback()
            self:toUfoGame({ 6, 7, 8 }, cb)
            self.coil.wait(cb)
            self.coil.wait(2)
            self:startDialogue("part3")
            self:onEndCutscene()

            local minigame = Save:get("minigames.spacer_racer")
            if not minigame then
                Save:save("minigames.spacer_racer", true)
                self:showNotification(
                    "Spacer Racer unlocked!\n\nJe kan vanuit het hoofdmenu nu\nalle Spacer Racer levels opnieuw spelen.")
            end

            self.noDoorAccess = false
        end
    },
    flag = Enums.Flag.cutsceneComputer4
}

return computer
