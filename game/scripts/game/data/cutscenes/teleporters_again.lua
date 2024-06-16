local teleporters_again = {
    dialogues = {
        part1 = {
            {
                character = "peter",
                emotion = "scared",
                text = "Jemig, wat voor een geflipt beest was dat joh?!",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text =
                "Vertel mij wat! [.3]Probeerde hij ons nou dood te stampen, [.2]of was hij gewoon willekeurig aan het rondspringen?",
            },
            {
                character = "peter",
                emotion = "thinking_concerned",
                text = "Geen idee, [.2]maar hij had duidelijk geen controle over zijn lichaam."
            },
            {
                character = "timon",
                emotion = "happy_tongue",
                text = "Oh maar kijk, [.2]we hebben onze teleporters weer!\n[.3]Zo nice zijn die!",
            },
            {
                character = "peter",
                emotion = "arms_crossed_wink",
                text = "Ze zijn essentieel zelfs!",
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Essentieel? [.3]Wat zeg jij nou weer?",
            },
            {
                character = "peter",
                emotion = "arms_crossed_confident",
                text = "Nou gewoon. [.3]We kunnen niet zonder. [.3]Essentieel. [.3]Toch?",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text = "Wat probeer je nou allemaal cool te klinken? [.3]Probeer het anders over 10 jaar nog eens.",
            },
            {
                character = "peter",
                text = "Staat genoteerd.",
            },
        },
    },
    functions = {
        prepare = function(self)
            self.camera:zoomTo(2)
            -- local level = self.map.currentLevel
            -- self.camera:follow(self.cameraFollow)
            -- self.camera:moveToPoint(level.x, level.y + level.height - 200)
        end,
        init = function(self)
            self:startDialogue("part1")
            self.camera:zoomTo(1, 1)
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneTeleportersAgain
}

return teleporters_again
