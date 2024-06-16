local done = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                sound = "cool",
                text =
                "Wauw! [.3]Jullie hebben jezelf bewezen als professionele dansers! [.3]Dat pasje is voor jullie!",
            },
            {
                character = "panda",
                emotion = "cool",
                text =
                "Maar eerst.[.1].[.1].[.1] FREESTYLE TIME![1.5][auto]",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self:onEndCutscene()
        end,
    },
}

return done
