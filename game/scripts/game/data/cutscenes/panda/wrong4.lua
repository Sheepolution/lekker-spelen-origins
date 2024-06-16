local wrong4 = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                emotion = "mad",
                sound = "frustrated",
                text =
                "Doen jullie wel je best?!",
            },
            {
                character = "panda",
                emotion = "mad",
                sound = "frustrated",
                text = "Verdomme zeg! [.3]Opnieuw!",
            },
        },
    },
    functions = {
        init = function(self)
            local pandaRoom = self:findEntityWithTag("PandaRoom")
            local panda = pandaRoom.panda
            local peter = pandaRoom.peter
            local timon = pandaRoom.timon

            panda.anim:set("frustrated")
            peter.anim:set("look" .. (peter.dance and "_dance" or ""))
            timon.anim:set("look" .. (timon.dance and "_dance" or ""))

            self:startDialogue("part1")

            panda.anim:set("neutral")
            peter.anim:set("neutral" .. (peter.dance and "_dance" or ""))
            timon.anim:set("neutral" .. (timon.dance and "_dance" or ""))

            self:onEndCutscene()
        end,
    },
}

return wrong4
