local wrong5 = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                emotion = "furious",
                sound = "angry",
                text =
                "JA WHAT THE FUCK GAST?! [.3]HOE SLECHT ZIJN JULLIE WEL NIET?!",
            },
            {
                character = "peter",
                emotion = "scared_serious_sweat",
                text =
                "JA MAAR IK PRESTEER NIET GOED ONDER DRUK!",
            },
            {
                character = "panda",
                emotion = "angry",
                sound = "frustrated",
                text = "ALS JE GEEN FOUTEN MAAKT HOEF JE OOK GEEN DRUK TE VOELEN!",
            },
            {
                character = "panda",
                emotion = "angry",
                sound = "angry",
                text = "MAAR GOED IK ZAL EEN FOUTJE MAAR TOLEREREN, ANDERS STAAN WE HIER NOG UREN![.3] OPNIEUW!",
            },
        },
        part1_clefairy = {
            {
                character = "panda",
                emotion = "furious",
                sound = "angry",
                text =
                "JA WHAT THE FUCK GAST?! [.3]HOE SLECHT ZIJN JULLIE WEL NIET?!",
            },
            {
                character = "peter",
                emotion = "scared_serious_sweat",
                text =
                "JA MAAR IK PRESTEER NIET GOED ONDER DRUK!",
            },
            {
                character = "panda",
                emotion = "angry",
                sound = "frustrated",
                text = "ALS JE GEEN FOUTEN MAAKT HOEF JE OOK GEEN DRUK TE VOELEN!",
            },
            {
                character = "panda",
                emotion = "angry",
                sound = "angry",
                text = "MAAR GOED IK ZAL EEN FOUTJE MAAR TOLEREREN, ANDERS STAAN WE HIER NOG UREN!",
            },
            {
                character = "panda",
                emotion = "angry",
                sound = "frustrated",
                text =
                -- TODO: Test if this fits
                "JE HOEFT NIET EENS ALLE PIJLEN TE ONTHOUDEN! ALLEEN DE RICHTING EN OF HET MET DE KLOK MEE GAAT OF NIET!",
            },
            {
                character = "panda",
                emotion = "angry",
                sound = "angry",
                text = "OPNIEUW!",
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

            if pandaRoom.gameType == pandaRoom.GameType.Clefairy then
                self:startDialogue("part1_clefairy")
            else
                self:startDialogue("part1")
            end

            panda.anim:set("neutral")
            peter.anim:set("neutral" .. (peter.dance and "_dance" or ""))
            timon.anim:set("neutral" .. (timon.dance and "_dance" or ""))
            cat.anim:set("idle")

            self:onEndCutscene()
        end,
    },
}

return wrong5
