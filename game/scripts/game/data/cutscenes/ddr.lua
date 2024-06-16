local ddr = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                text =
                "Goed bezig, jongens! [.3]Maar hoe zit het met jullie gevoel voor ritme?",
            },
            {
                character = "panda",
                emotion = "cool",
                sound = "cool",
                text = "Dans met ons mee, [.2]op de beat!",
            },
            {
                character = "peter",
                text = "Staat het geluid goed zo?",
            },
            {
                character = "panda",
                text = "Wat loop jij je nou druk te maken over het geluid? [.3]Focus nou maar op die danspasjes!",
            },
        },
    },
    functions = {
        init = function(self)
            local pandaRoom = self:findEntityWithTag("PandaRoom")
            local panda = pandaRoom.panda
            local peter = pandaRoom.peter
            local timon = pandaRoom.timon

            panda.anim:set("neutral")
            peter.anim:set("look")
            timon.anim:set("look")

            self:startDialogue("part1")

            peter.anim:set("neutral")
            timon.anim:set("neutral")

            self:onEndCutscene()
        end,
    },
}

return ddr
