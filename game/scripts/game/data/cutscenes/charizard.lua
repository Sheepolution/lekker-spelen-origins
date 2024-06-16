local charizard = {
    dialogues = {
        init = {
            {
                character = "timon",
                emotion = "confused",
                text = "Wat is dit nou weer voor ding?",
            },
            {
                character = "peter",
                emotion = "thinking",
                text =
                "Het lijkt op een kaartje. [.3][emotion=questioning]Zou het iets waard zijn?",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Het is puur karton. [.3]Hoeveel kan dat nou opleveren?",
            },
            {
                character = "peter",
                emotion = "default",
                text = "We kunnen het meenemen, [.2]toch?\n[.3]Je weet maar nooit.",
            },
            {
                character = "timon",
                emotion = "mad",
                text =
                "Ja hallo, Peter! [.3]En dan? [.3]Ga je alle troep die hier ligt meenemen soms?",
            },
            {
                character = "timon",
                emotion = "suspicious",
                text =
                "Dan zijn we heel de dag bezig! [.3]Ik wil zo snel mogelijk weg hier!",
            },
            {
                character = "peter",
                emotion = "arms_crossed_confident",
                text =
                "Gelijk heb je, Timon. [.3][emotion=laughing]Alsof iemand dit spul wil hebben ook.",
            },
        },
    },
    functions = {
        init = function(self)
            self.music:setVolume(.25, .5)
            local charizard = self:findEntityWithTag("Charizard")
            local distance_peter = self.peter:getDistance(charizard)
            local distance_timon = self.timon:getDistance(charizard)

            if distance_peter > 100 then
                self.timon:teleportOther()
                self.coil.wait(.5)
            elseif distance_timon > 100 then
                self.peter:teleportOther()
                self.coil.wait(.5)
            end

            self:startDialogue("init")
            self:onEndCutscene()
            self.cutscenePausesMusic = true
            self.music:setVolume(1, .5)
        end,
    },
}

return charizard
