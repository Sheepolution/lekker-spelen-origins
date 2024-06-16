local dance = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                emotion = "cool",
                text =
                "Heel goed! [.3]Dan is het nu tijd voor de ultieme test!",
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

            self:fadeOut(.5)
            self.coil.wait(.5)
            pandaRoom:toDanceMode()
            self:fadeIn(.5)

            self:onEndCutscene()
        end,
    },
}

return dance
