local intro = {
    dialogues = {
        intro = {
            {
                character = "timon",
                emotion = "confused",
                text = "Dit is puur een test?"
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Klop volgens mij ja..."
            },
        }
    },
    functions = {
        init = function(self)
            self:startDialogue("intro")
            self:onEndCutscene()
        end
    },
    flag = Enums.Flag.cutsceneIntro
}

return intro
