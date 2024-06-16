local memory = {
    dialogues = {
        init = {
            {
                character = "timon",
                emotion = "shocked",
                text = "Ze hebben ons geheugen gewist? [.3]Meerdere keren?!",
            },
            {
                character = "peter",
                emotion = "thinking_concerned",
                text =
                "Geheugen wissen?\n[.3]Waarom kan ik me daar niks van her- [.3][emotion=thinking_sarcastic]Oh. [.5]Juist.",
            },
            {
                character = "timon",
                emotion = "wink",
                text = "Niet te veel over nadenken, Peter.\n[.3]Straks word je weer duizelig.",
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Maar welke vaardigheden hebben ze het over?",
            },
            {
                character = "timon",
                emotion = "satisfied",
                text = "Ik kan op zich best mooi blaffen.",
            },
            {
                character = "peter",
                emotion = "questioning",
                text = "Laat dat nou net mijn zwakke punt zijn. \n[.3][emotion=default]Kom, [.2]dan zoeken we verder.",
            },
        },
    },
    functions = {
        init = function(self)
            self.music:setVolume(.25, .5)
            self:startDialogue("init")
            self:onEndCutscene()
            self.cutscenePausesMusic = true
            self.music:setVolume(1, .5)
        end,
    },
}

return memory
