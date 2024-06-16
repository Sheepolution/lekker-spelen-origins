local meeting_gier = {
    dialogues = {
        part1 = {
            {
                character = "gier",
                sound = "welkom",
                text = "Welkom bij de Skrale Skraper. [.3]Hebben jullie euro's?",
            },
            {
                character = "timon",
                text = "Euro's? [.3]Bedoel je deze ronde dingen?",
            },
            {
                character = "gier",
                sound = "euros",
                emotion = "crazy",
                text = "Ja! [.3]Geef mij je euro's! [.3]Ik wil je euro's!",
            },
            {
                character = "peter",
                text = "En wat krijgen wij ervoor terug?",
            },
            {
                character = "gier",
                sound = "oja",
                emotion = "nervous",
                text = "Oja. [.3]Ehm... [.2]Flappies. [.3]Papflappies. [.3]Mag ik nu je euro's?",
            },
            {
                character = "timon",
                text = "Wat zijn papflappies nou weer?",
            },
            {
                character = "gier",
                sound = "snackies",
                text = "Snackies. [.3]Heel lekker. [.3]Krijg je een extra leven van.",
            },
            {
                character = "gier",
                sound = "price",
                text = "10 euro's voor 1 flappie.",
            },
        },
    },
    functions = {
        init = function(self)
            self.cutsceneBlackBarTop.visible = false
            self.cutsceneBlackBarBottom.visible = false
            self:startDialogue("part1")
            local shop = self.overlay:find(function(o) return o.tag == "Shop" end)
            shop:moveUp()
            self:onEndCutscene(true)
            self:delay(1, function()
                self.cutsceneBlackBarTop.visible = true
                self.cutsceneBlackBarBottom.visible = true
            end)
        end,
    },
    flag = Enums.Flag.cutsceneMeetingGier
}

return meeting_gier
