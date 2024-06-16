local main_event2 = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "determined",
                text = "Hoppaaa! [.3]We hebben alle pasjes!",
            },
            {
                character = "peter",
                emotion = "determined",
                text =
                "En die Pier maar zeggen dat het gevaarlijk was. [.3][emotion=satisfied]Ik heb niet eens gezweet!",
            },
            {
                character = "peter",
                emotion = "arms_crossed_eyes_closed",
                thinking = true,
                sound = "think",
                text =
                "(Want als Main Event is er geen reden om te zweten...)",
            },
            {
                character = "timon",
                emotion = "laughing",
                text = "Zo easy was dat! [.3]Ik was zelfs een beetje aan het klieren ondertussen."
            },
            {
                character = "timon",
                thinking = true,
                sound = "think",
                emotion = "smug_eyes_closed",
                text = "(Want als Main Event moet je het toch een beetje leuk houden voor jezelf...)"
            },
            {
                character = "peter",
                emotion = "happy",
                text =
                "Tijd om eindelijk hier weg te gaan, Timon.\n[.3]En niks, [.2][emotion=determined]maar dan ook niks, [.2][emotion=arms_crossed_wink]dat ons nu nog in de weg kan staan!"
            },
            {
                character = "timon",
                emotion = "confused_mad_tongue",
                sound = "silence",
                text = ".[.3].[.3].[.3][.5][sound=default][emotion=smug_wink]Inderdaad!"
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
    flag = Enums.Flag.cutsceneMainEvent2
}

return main_event2
