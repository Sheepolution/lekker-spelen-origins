local Document = require "documents.document"

local videogames = {
    dialogues = {
        see = {
            {
                character = "timon",
                text = "Kijk, Peter! [.3]Daar ligt nog zo'n papiertje.",
            },
            {
                character = "peter",
                text = "Wat staat erop? [.3][emotion=questioning]Op de achterkant dan...",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(160, true)
                    end,
                },
            },
        },
        talk = {
            {
                character = "timon",
                text = "Videogames, Peter. [.3]We zijn goed in... [.2][emotion=questioning]videogames.",
                functions = {
                    init = function(self)
                        self.timon:lookAt(self.peter)
                    end,
                },
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Videogames? [.6]Weet je zeker dat er niks staat over hyperintelligentie of kungfu of zo?",
            },
            {
                character = "timon",
                text =
                "Je mag van mij kijken of het op de voorkant staat, [.2]maar daar ben ik niet hyperintelligent genoeg voor.",
            },
            {
                character = "timon",
                emotion = "sarcastic_extreme",
                text = "Ik kan dat woord amper uitspreken..."
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Maar ik kan me niet herinneren ooit een videoga- [.3]Oja. [.2]Juist.[emotion=sarcastic_mild_unamused] [.2]Verdomme.",
            },
            {
                character = "timon",
                text = "Ik besef 'm ineens. [.2][emotion=questioning]Waar zijn die wetenschappers dan eigenlijk?",
            },
            {
                character = "peter",
                emotion = "questioning",
                text =
                "Daar vraag je me wat. [.2]Misschien hebben ze pauze?[.2][emotion=default] Laten we ze zoeken!",
            },
            {
                character = "timon",
                emotion = "wink",
                text =
                "Dan kunnen we ze vragen om nog wat hyperinte- [.2][emotion=sarcastic_extreme]slimheid te injecteren.",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("see")
            self.coil.wait(.2)
            self:showDocument("videogames", Document.DocumentType.Log, true)
            self:startDialogue("talk")
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneVideogamesLog
}

return videogames
