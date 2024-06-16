local telegate2 = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "tired",
                text = "Dit gaat allemaal niet zo snel als ik had verwacht...",
            },
            {
                character = "peter",
                text = "Ja, [.2]er zijn hier een hoop geflipte [sound=squeak_pitched]b[shiver]ee[/shiver]sten.",
            },
            {
                character = "timon",
                emotion = "questioning",
                text = "Oei... [.3]Wat gebeurde daar nou met je stem?",
            },
            {
                character = "peter",
                emotion = "concerned",
                text = "Even geen nadruk.",
            },
            {
                character = "timon",
                emotion = "questioning",
                text =
                "Ik wist niet dat ze in dit laboratorium ook [emotion=smug_confident][b]kippen[/b] hadden!",
            },
            {
                character = "peter",
                emotion = "scared",
                text = "Ja maar dit vind ik dus niet leuk.",
            },
            {
                character = "timon",
                emotion = "smug_wink",
                text = "Ik maak toch ook maar een geintje, Peter![.3]\nDat je stem overslaat kan iedereen gebeuren.",
            },
            {
                character = "timon",
                thinking = true,
                emotion = "smug_eyes_closed",
                sound = "think",
                text = "(Maar niet bij een Main Event...)",
            },
            {
                character = "timon",
                emotion = "smug",
                text = "Nou kom, [.2]dan [sound=bark_pitched]g[shiver]aa[/shiver]n[emotion=scared_eyes]...",
            },
            {
                character = "peter",
                emotion = "arms_crossed_smug",
                text = "Hmmm?",
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text =
                "Ja dit voelt dus kut...",
            },
        },
    },
    functions = {
        prepare = function(self)
            self.camera:zoomTo(2)
            local level = self.map.currentLevel
            -- self.camera:follow(self.cameraFollow)
            -- self.camera:moveToPoint(level.x, level.y + level.height - 200)
        end,
        init = function(self)
            self:startDialogue("part1")
            self.camera:zoomTo(1, 1)
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneTelegate2
}

return telegate2
