local wrong1 = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                emotion = "sad",
                sound = "sad",
                text =
                "Oei, [.2]iemand maakte een fout...",
            },
            {
                character = "panda",
                text = "Nou goed, [.2]dat kan gebeuren. [.3]Opnieuw!",
            },
        },
    },
    functions = {
        init = function(self)
            local pandaRoom = self:findEntityWithTag("PandaRoom")
            local panda = pandaRoom.panda
            local peter = pandaRoom.peter
            local timon = pandaRoom.timon

            panda.anim:set("sad")
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

return wrong1
