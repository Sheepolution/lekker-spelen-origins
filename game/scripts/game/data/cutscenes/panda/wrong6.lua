local wrong6 = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                emotion = "furious",
                sound = "angry",
                text =
                "OPNIEUW!",
            },
        },
    },
    functions = {
        init = function(self)
            local pandaRoom = self:findEntityWithTag("PandaRoom")
            local panda = pandaRoom.panda
            local peter = pandaRoom.peter
            local timon = pandaRoom.timon
            local cat = pandaRoom.cat

            panda.anim:set("angry")
            peter.anim:set("scared" .. (peter.dance and "_dance" or ""))
            timon.anim:set("scared" .. (timon.dance and "_dance" or ""))
            cat.anim:set("scared")

            self:startDialogue("part1")

            panda.anim:set("neutral")
            peter.anim:set("neutral" .. (peter.dance and "_dance" or ""))
            timon.anim:set("neutral" .. (timon.dance and "_dance" or ""))
            cat.anim:set("scared")

            self:onEndCutscene()
        end,
    },
}

return wrong6
