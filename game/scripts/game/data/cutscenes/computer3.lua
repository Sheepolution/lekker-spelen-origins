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
                text = "Uh-oh, daar heb je 'm weer."
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text = "Toch niet weer een test hè?"
            },
            {
                character = "computer",
                sound = "3/no_access",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Welkom, P3-TR en T1-MN. [.5] Ik kan jullie geen toegang verlenen tot de volgende ruimte.[function=eye][emotion=eye]",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                text = "Omdat we eerst een game moeten spelen.\n[.3]We snappen het al."
            },
            {
                character = "computer",
                sound = "3/scientists",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Incorrect. Toegang tot deze ruimte is enkel voor wetenschappers met een uitgebreide kennis van dieren.[function=eye][emotion=eye]"
            },
            {
                character = "peter",
                emotion = "happy",
                text = "Oh! [.3]Maar wij weten wel wat van dieren!"
            },
            {
                character = "timon",
                emotion = "happy_tongue",
                text = "Ja joh! [.3]Sterker nog, [.2]we zijn ervaringsdeskundigen!"
            },
            {
                character = "timon",
                emotion = "sarcastic_extreme",
                text = "Nog zo'n woord..."
            },
            {
                character = "computer",
                sound = "3/waku",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "In dat geval kunnen jullie deelnemen aan de Wetenschapper Authenticatie Keuring Uitvoering.[function=eye][emotion=eye]"
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "De Wetenschapper Authenticatie..."
            },
            {
                character = "timon",
                emotion = "confused",
                text =
                "Keuring Uitvoering...?"
            },
            {
                character = "computer",
                sound = "3/waku_waku",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Correct. Afgekort de WAKU. Maar jullie zijn met z'n tweeën, dus je zou het ook de WAKU WAKU kunnen noemen.[function=eye][emotion=eye]"
            },
            {
                character = "computer",
                sound = "3/coincidence",
                settings = {
                    print_speed = .06
                },
                functions = computer_functions,
                text =
                "Hey, dat is grappig. Zo heet ook die dierenquiz op tv. Maar dat is louter toeval.[function=eye][emotion=eye]"
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "En wat is dat dan precies?"
            },
            {
                character = "computer",
                sound = "3/multiple_choice",
                settings = {
                    print_speed = .06
                },
                functions = computer_functions,
                text =
                "De WAKU WAKU is simpel. Ik stel jullie meerkeuzevragen, en jullie moeten correct antwoorden.[.2] A,[.2] B,[.2] of C.[function=eye][emotion=eye]",
            },
            {
                character = "computer",
                sound = "3/points",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Beiden een goed antwoord is twee punten erbij. Beiden een fout antwoord is twee punten eraf. Geen antwoord kiezen is sowieso een punt eraf.[function=eye][emotion=eye]",
            },
            {
                character = "computer",
                sound = "3/spread",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Jullie zouden ook kunnen spreiden. In het geval van een gespreid goed en fout antwoord blijft de score gelijk.[function=eye][emotion=eye]",
            },
            {
                character = "computer",
                sound = "3/victory_condition",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Wanneer jullie de 20 punten behalen, hebben jullie de WAKU WAKU voltooid en krijgen jullie toegang tot de volgende ruimte.[function=eye][emotion=eye]",
            },
            {
                character = "timon",
                emotion = "determined",
                text = "Dit wordt een eitje joh! [.3]Kom maar op met die eerste vraag!"
            },
            {
                character = "computer",
                sound = "3/help_lines",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Nog één ding. Jullie kunnen hulplijnen inschakelen. Er zijn drie soorten hulplijnen.[function=eye][emotion=eye]",
            },
            {
                character = "computer",
                sound = "3/fifty_fifty",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Met de 50:50 kun je één fout antwoord wegstrepen,[.2] en blijf je dus met twee antwoorden over.[function=eye][emotion=eye]",
            },
            {
                character = "computer",
                sound = "3/chat",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Als tweede hulplijn kan ik data ophalen van het interchat om te zien wat het publiek denkt dat het juiste antwoord is.[function=eye][emotion=eye]",
            },
            {
                character = "peter",
                text =
                "Bedoel je niet 'internet'?",
            },
            {
                character = "computer",
                sound = "3/ask_me",
                settings = {
                    print_speed = .06
                },
                functions = computer_functions,
                text =
                "Nee, interchat. Als derde hulplijn kun je het aan mij vragen. Er is 50% kans dat ik het juiste antwoord zal geven.[function=eye][emotion=eye]",
            },
            {
                character = "computer",
                sound = "3/button",
                settings = {
                    print_speed = .04
                },
                functions = computer_functions,
                text =
                "Je kan een hulplijn inschakelen door links op de knop te drukken.[function=eye][emotion=eye]",
            },
            {
                character = "computer",
                sound = "3/cooldown",
                settings = {
                    print_speed = .04
                },
                functions = computer_functions,
                text =
                "Na het gebruiken van een specifieke hulplijn zal deze voor 10 rondes lang niet meer beschikbaar zijn.[function=eye][emotion=eye]"
            },
            {
                character = "computer",
                sound = "3/all_explained",
                settings = {
                    print_speed = .06
                },
                functions = computer_functions,
                text =
                "Zo, alles is uitgelegd. Dan kunnen we nu beginnen met de eerste vraag.[function=eye][emotion=eye]",
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Eindelijk! [.3]Verspilling van tijd ook, want die [emotion=laughing]hulplijnen hebben we toch niet nodig.",
            },
            {
                character = "peter",
                emotion = "determined",
                text =
                "Precies! [.3]Dit zal niet lang duren.",
            },
        },
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
            computer:startWaku()
            self.noDoorAccess = true
            self:onEndCutscene(nil, true)
        end
    },
    flag = Enums.Flag.cutsceneComputer3,
}

return computer
