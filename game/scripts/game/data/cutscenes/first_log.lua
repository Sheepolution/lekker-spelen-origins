local document = require "documents.document"

local first_document = {
    dialogues = {
        see = {
            {
                character = "peter",
                text = "Kijk, Timon, [.2]daar ligt iets.",
            },
            {
                character = "timon",
                text = "Wat is het?",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(160, true)
                    end,
                },
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "Het lijkt op een afgescheurde bladzijde.[.3]\nEens lezen...",
                functions = {
                    init = function(self)
                        self.peter:lookAt(self.timon)
                    end,
                },
            },
        },
        dizzy = {
            {
                character = "timon",
                emotion = "confused",
                text = "Oei, [.2]gaat het wel, Peter?",
            },
            {
                character = "peter",
                emotion = "dizzy",
                text = "Zoveel tekst...\n[.3]Het doet pijn aan mijn breinstelsel..."
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Laat mij eens kijken...",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(50, true)
                    end,
                },
            },
            {
                character = "timon",
                emotion = "gross",
                text = "Oh gadverdamme! [.3]Dit is toch niet te doen joh!"
            },
            {
                character = "peter",
                text = "Wacht, [.2]op de achterkant staat een samenvatting.",
                functions = {
                    init = function(self)
                        self.peter:stopBeingConfused()
                    end,
                },
            },
        },
        ending = {
            {
                character = "peter",
                emotion = "thinking",
                text = "Deze tekst gaat over ons. [.3]Blijkbaar zijn we proefdieren."
            },
            {
                character = "timon",
                emotion = "confused_tongue",
                text = "Maar wat moeten we proeven dan?"
            },
            {
                character = "peter",
                emotion = "thinking",
                text =
                "Geen idee... [.3]Misschien liggen hier meer van dit soort papieren. [.3][emotion=default]Laten we zoeken!"
            },
            {
                character = "timon",
                emotion = "blush",
                text = "Hopelijk hebben die ook een samenvatting..."
            },
        }
    },
    functions = {
        init = function(self)
            self:startDialogue("see")
            self.coil.wait(.2)
            self:showDocument("running_long", document.DocumentType.Log)
            self.coil.wait(6)
            self:hideDocument(true)
            self.peter:becomeConfused()
            self.coil.wait(.5)
            self:startDialogue("dizzy")
            self:showDocument("running", document.DocumentType.Log, true)
            self.coil.wait(.5)
            self:startDialogue("ending")
            self:onEndCutscene()
            self.coil.wait(1)
            self:showNotification("Documenten unlocked!\n\nJe kan nu de logs teruglezen in het menu.")
        end,
    },
    flag = Enums.Flag.cutsceneFirstLog
}

return first_document
