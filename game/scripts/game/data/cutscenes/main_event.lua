local main_event = {
    dialogues = {
        init = {
            {
                character = "peter",
                emotion = "thinking",
                text = "Dus iemand van ons is de Main Event?",
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Maar wie zou het zijn denk je?",
            },
            {
                character = "peter",
                emotion = "eyes_closed",
                text = "Tja, [.2]misschien jij, [.2]misschien ik. [.3]Het is lastig te zeggen.",
            },
            {
                character = "peter",
                emotion = "relaxed",
                thinking = true,
                sound = "think",
                text = "(Maar uiteraard ben ik het...)",
            },
            {
                character = "timon",
                emotion = "eyes_closed",
                text = "Boeit eigenlijk ook helemaal niet wie het is.",
            },
            {
                character = "timon",
                thinking = true,
                sound = "think",
                emotion = "mad",
                text = "(Behalve dat het alles boeit, en sowieso dat ik het ben...)",
            },
            {
                character = "peter",
                text = "Inderdaad. [.3]Laten we ons daar niet druk over maken.",
            },
            {
                character = "peter",
                emotion = "determined",
                thinking = true,
                sound = "think",
                text = "(Want waarom zou je je druk maken over iets wat je al weet...)",
            },
            {
                character = "timon",
                text = "Precies. [.3]We moeten focussen op het vinden van die wetenschappers!",
            },
            {
                character = "timon",
                emotion = "wink",
                sound = "think",
                thinking = true,
                text = "(Die ons gaan vertellen dat ik de Main Event ben...)",
            },
        },
    },
    functions = {
        init = function(self)
            self.music:setVolume(.25, .5)
            self:startDialogue("init")
            self:onEndCutscene()
            self.cutscenePausesMusic = true
            self.music:setVolume(1, .5)
        end,
    },
}

return main_event
