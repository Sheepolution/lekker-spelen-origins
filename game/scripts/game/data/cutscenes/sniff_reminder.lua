local telegate1 = {
    dialogues = {
        part1 = {
            {
                character = "peter",
                emotion = "default",
                settings = {
                    print_speed = .05
                },
                text = "Hey, Timon, vergeet niet af en-[auto]",
            },
            {
                character = "timon",
                emotion = "angry",
                settings = {
                    print_speed = .015
                },
                text = "Ja maar Peter klaar nu hoor!",
            },
            {
                character = "peter",
                emotion = "concerned",
                text = "Pardon?",
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Elke keer dat we een nieuwe ruimte binnenlopen gaan we weer praten! [.3]Ik wil niet steeds stoppen, ik wil gaan!",
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Oh, sorry.",
            },
            {
                character = "timon",
                emotion = "frustrated",
                text = "Ja sorry, niks persoonlijks hoor, maar ik raak gewoon een beetje opgefokt ervan."
            },
            {
                character = "peter",
                emotion = "eyes_closed",
                text = "Nee is gewoon terecht hoor.",
            },
            {
                character = "timon",
                emotion = "frustrated",
                text = "Oké nou zeg nou maar wat je wilde zeggen.",
            },
            {
                character = "peter",
                emotion = "arms_crossed",
                text = "Ik wilde alleen zeggen dat je niet moet vergeten af en toe te ruiken, [.2]voor die geheimpies.",
            },
            {
                character = "timon",
                emotion = "eyes_closed",
                text = "Daar moet jij je helemaal niet druk over maken, Peter. [.3]Ik weet heus wel wat ik moet doen.",
            },
            {
                character = "timon",
                emotion = "sarcastic_mad",
                thinking = true,
                sound = "think",
                text =
                "(Oja shit, dat was ik inderdaad vergeten.)",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneSniffReminder
}

return telegate1
