local horsey_defeat = {
    dialogues = {
        part1 = {
            {
                character = "horsey",
                emotion = "dead",
                sound = "short",
                text =
                "De stemmen... [.5]Ik hoor ze niet meer...\n[1][emotion=peace]Eindelijk... [.5]rust.",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self.noDoorAccess = false
            self:onEndCutscene()
        end,
    },
}

return horsey_defeat
