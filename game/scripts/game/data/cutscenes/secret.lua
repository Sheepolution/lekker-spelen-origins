local secret = {
    dialogues = {
        part1 = {
            {
                character = "peter",
                emotion = "happy",
                text = "Zie je nou wel! [.3]Ik zei toch dat hier iets was!",
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text = "Ik ben gewoon geen terugloop-man...",
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Maar wat is dit voor kamer?",
            },
            {
                character = "timon",
                emotion = "confused",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(-20, true)
                    end,
                },
                text = "En wat zijn deze dingen in de kast?\n[.5][emotion=confused]The Lion King...?",
            },
            {
                character = "peter",
                emotion = "thinking",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(-100, true)
                    end,
                },
                text = "Volgens mij zijn dit... [.3]videogames.",
            },
            {
                character = "timon",
                emotion = "default",
                text = "Hier staat [.2]'Donkey Kong'. [.3][emotion=questioning]Heb jij wel eens Donkey Kong gespeeld?",
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "Niet dat ik me kan herinneren...",
            },
            {
                character = "timon",
                emotion = "confused",
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(-40, true)
                    end,
                },
                text = "Maar als dit videogames zijn, [.2]en wij zijn gemaakt om videogames te spelen...",
            },
            {
                character = "peter",
                text =
                "Dan is dit dus de ruimte waar ze proeven op ons hebben gedaan.",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self.camera:zoomTo(1, 1)
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneSecret
}

return secret
