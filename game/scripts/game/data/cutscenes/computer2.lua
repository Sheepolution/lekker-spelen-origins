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
                text = "Huh?! De supercomputer?"
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Zijn we nou een rondje gelopen?"
            },
            {
                character = "computer",
                sound = "2/welcome",
                settings = {
                    print_speed = .06
                },
                functions = computer_functions,
                text =
                "Welkom terug, P3-TR en T1-MN. [.2]Nee, jullie zijn geen rondje gelopen. Ik ben op meerdere plaatsen in dit laboratorium te vinden.[function=eye][emotion=eye]",
            },
            {
                character = "peter",
                functions = {
                    close = function(self)
                        self.noDoorAccess = true
                    end
                },
                emotion = "default",
                text = "Ah, dat verklaart.[.3] Nou goed, [.2]wij moeten weer verder.[function=close]"
            },
            {
                character = "computer",
                sound = "2/denied",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Toegang om te vertrekken geweigerd. Jullie zullen eerst de test moeten voltooien.[emotion=eye][function=eye]"
            },
            {
                character = "peter",
                emotion = "concerned",
                text = "Alweer?[.3] Maar we hebben die test al gedaan!"
            },
            {
                character = "timon",
                emotion = "mad",
                text = "Ja![.2] En de resultaten waren uitstekend, weet je nog?"
            },
            {
                character = "peter",
                emotion = "happy_questioning",
                text = "Misschien moet je wat ruimte vrijmaken op die harde schijf van je!"
            },
            {
                character = "timon",
                emotion = "wink",
                text = "Nice one, Peter."
            },
            {
                character = "computer",
                sound = "2/monthly",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Eerder hebben jullie de wekelijkse test voltooid. Nu is het tijd voor de maandelijkse test.[emotion=eye][function=eye]"
            },
            {
                character = "peter",
                emotion = "mad",
                text = "Serieus?![.3] Kan je die niet gewoon samenvoegen of zo?"
            },
            {
                character = "timon",
                emotion = "mad",
                text = "Verdomme man![.3] Nou kies maar een spel uit, dan cleanen we die test!"
            },
            {
                character = "computer",
                sound = "2/millions",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Ik ga nu een willekeurige videogame selecteren uit mijn database van miljoenen videogames.[emotion=eye][function=eye][2][auto]",
            },
        },
        part2 = {
            {
                character = "computer",
                sound = "2/spacer_racer",
                settings = {
                    print_speed = .05
                },
                emotion = "eye",
                text =
                "Mijn willekeurige selectie is uitgekomen op Spacer Racer.[.4] Wow, wat is de kans?!",
            },
            {
                character = "peter",
                emotion = "sarcastic_mild",
                text =
                "Hoe willekeurig is die selectie werkelijk?",
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text =
                "Ja, [.2]dit klinkt heel scripted!",
            },
            {
                character = "computer",
                sound = "2/scripts",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Als computer besta ik inderdaad uit scripts. Zo zal ik nu het aftelscript activeren voor de simulatie.[function=eye][.5][auto]"
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
                sound = "2/results",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Einde van de simulatie.\n[.2]Resultaten van de analyse berekenen.\n[.3]Even geduld alstublieft.[emotion=eye][function=eye][2][auto]",
            },
            {

                character = "peter",
                emotion = "disgusted",
                text =
                "Oh nee hè, dit gaat weer echt een uur duren zeker...[3.2][auto]",
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
                "[emotion=default][function=voice]De resultaten worden berekend.\n[.3]Nog even geduld alstublieft.[emotion=eye][function=eye][6][auto]",
            },
            {

                character = "timon",
                emotion = "mad",
                text =
                "Skiiiip![2][auto]",
            },
            {
                character = "computer",
                emotion = "eye",
                sound = "2/skipped",
                settings = {
                    print_speed = .05
                },
                functions = {
                    voice = voice,
                    eye = eye
                },
                text =
                "Berekenen van de resultaten overgeslagen. Jullie mogen gaan.",
            },
            {
                character = "timon",
                emotion = "questioning",
                text =
                "Oh... oké.",
            },
            {
                character = "peter",
                emotion = "mad",
                text =
                "Dat was gewoon een optie?[.3][emotion=frustrated] Weet je wat, het boeit me niet eens.[.2] Kom, Timon, wegwezen hier.",
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
            self:toUfoGame({ 3, 4, 5 }, cb)
            self.coil.wait(cb)
            self.coil.wait(2)
            self:startDialogue("part3")
            self:onEndCutscene()
            self.noDoorAccess = false
        end
    },
    flag = Enums.Flag.cutsceneComputer2
}

return computer
