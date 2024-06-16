local telegate3 = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "tired",
                text = "Sow, [.2]die vragen waren soms nog best pittig!",
            },
            {
                character = "peter",
                emotion = "happy_wink",
                text = "Ja, [.2]maar dat hebben we lekker gedaan Timpie!",
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Timpie? [.3]Ga je me nu een koosnaampje geven ook echt?",
            },
            {
                character = "timon",
                emotion = "confused_sarcastic",
                text = "Ga je straks over mijn wang aaien ook nog zeker?",
            },
            {
                character = "peter",
                text =
                "Als het mag. [.3]Zou wel gewoon even willen voelen.",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Nee afblijven, Peter. [.3]Ik weet ze zijn heel zacht, maar niet aanraken.",
            },
            {
                character = "peter",
                emotion = "eyes_closed",
                text = "Maar ga me dan ook niet teasen met hoe zacht ze zijn.",
            },
        },
    },
    functions = {
        prepare = function(self)
            self.camera:zoomTo(2)
        end,
        init = function(self)
            self:startDialogue("part1")
            self.camera:zoomTo(1, 1)
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneTelegate3
}

return telegate3
