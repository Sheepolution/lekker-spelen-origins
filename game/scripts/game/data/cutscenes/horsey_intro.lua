local function horsey_turn(self)
    local horsey = self:findEntityWithTag("Horsey")
    horsey.anim:set("turn")
end

local horsey_intro = {
    dialogues = {
        part1 = {
            {
                character = "horsey",
                emotion = "secret",
                functions = {
                    turn = horsey_turn
                },
                sound = "default",
                text =
                "Rechts... [.2]links... [.2]links... [.2]rechts..."
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Uhm... hallo?",
            },
            {
                character = "horsey",
                functions = {
                    init = function(self)
                        self.camera:zoomTo(1, 2)
                    end,
                    turn = horsey_turn
                },
                emotion = "secret",
                sound = "silence",
                text =
                "[1][sound=short][function=turn][emotion=default]Links... [.2]rechts... [.2]links... [.2]links... [.2]hahaha... [function=turn][.2]rechts... [.2]springen... [.2]rechts...",
            },
            {
                character = "timon",
                emotion = "questioning",
                text = "Wat loop je nou allemaal te brabbelen?",
            },
            {
                character = "horsey",
                functions = {
                    turn = horsey_turn
                },
                sound = "default",
                text =
                "[function=turn][shiver=2]Naar links... [.2]ik moet naar links! [.2]Of... [function=turn][.4]nee toch niet! [.2]Rechts! [.2]Ja ik moet naar rechts![/shiver]",
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "We zijn op zoek naar een toegangspasje. [.3]Weet jij misschien waar die ligt?",
            },
            {
                character = "horsey",
                functions = {
                    turn = horsey_turn
                },
                sound = "long",
                text =
                "[shiver=3]Links! [function=turn][.2]Links! [.2]Hahaha! [.2]Nee rechts! [function=turn][.2]Hahahaha! [.2][emotion=nervous]LIIIIINNKSS!! [function=turn][.2]HAHAHA LIIIINKS!!![/shiver]",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Ja ligt ie nou links of rechts?!",
            },
            {
                character = "peter",
                emotion = "concerned",
                text = "Gaat alles wel goed daar in dat bovenkamertje van je?",
            },
            {
                character = "horsey",
                functions = {
                    turn = horsey_turn
                },
                sound = "default",
                emotion = "nervous",
                text =
                "[shiver=3]DE STEMMEN! [.2]HAAL DE STEMMEN UIT MIJN HOOFD!\nZE... [.3]ZE ZIJN... [/shiver][shiver=5][.5][sound=long][emotion=crazy][function=turn]RECHTS! LINKS! SPRINGEN! LINKS! SPRINGEN! RECHTS! RECHTS LINKS! RECHTS LINKS![function=turn][/shiver]",
            },
            {
                character = "timon",
                emotion = "scared_eyes",
                text =
                "Kijk uit, Peter! [.3]Hij is wild!",
            },
        },
    },
    functions = {
        prepare = function(self)
            self.camera:zoomTo(3)
            local level = self.map.currentLevel
            self.camera:moveToPoint(level.x, level.y + level.height)
        end,
        init = function(self)
            local room = self:findEntityWithTag("HorseyRoom")
            self:startDialogue("part1")
            self:onEndCutscene()
            room:initializeRestart()
        end,
    },
    flag = Enums.Flag.cutsceneHorseyIntro
}

return horsey_intro
