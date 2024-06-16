local panda_intro = {
    dialogues = {
        part1 = {
            {
                character = "panda",
                emotion = "secret",
                text =
                "Links![.3] Rechts![.3] Links, links, rechts![.3] Boven, onder, rechts, links, boven!",
            },
            {
                character = "timon",
                emotion = "questioning",
                text = "Uhm... [.3]Hallo?",
            },
        },
        part2 = {
            {
                character = "panda",
                text =
                "Hallo daar! [.3]Wat leuk om nieuwe gezichten te zien in onze dansclub!",
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Dansclub...?",
            },
            {
                character = "panda",
                emotion = "cool",
                sound = "cool",
                text =
                "Zeker! [.3]De coolste plek van het laboratorium, [.2]waar we onze lichamen overgeven aan de beat van de muziek!",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                text =
                "Mooi man. [.5][emotion=default]Maar wij zijn eigenlijk op zoek naar een toegangspasje.",
            },
            {
                character = "panda",
                text =
                "Die ligt in de kamer hiernaast! [.3]Je mag 'm hebben, [.2]want wij doen er toch niks mee.",
            },
            {
                character = "timon",
                emotion = "happy",
                text =
                "Oh, [.2]nou dat was makkelijk.",
            },
            {
                character = "peter",
                emotion = "happy",
                text =
                "Inderdaad. [.2]Fijn dat we gewoon kunnen doorlopen voor de verandering.",
            },
            {
                character = "panda",
                emotion = "cool",
                sound = "cool",
                text =
                "Maar eerst zullen jullie moeten bewijzen dat jullie echte dansers zijn!",
            },
            {
                character = "peter",
                emotion = "arms_crossed_frustrated",
                text =
                "Verdomme...",
            },
            {
                character = "timon",
                emotion = "tired_mad",
                text =
                "Te vroeg gejuicht...",
            },
        },
        part3 = {
            {
                character = "panda",
                sound = "cool",
                functions = {
                    init = function(self)
                        self.cutsceneData.panda.anim:set("neutral")
                        self.cutsceneData.cat.anim:set("idle")
                    end
                },
                text =
                "Cool! [.3]Eens zien of jullie een beetje danspasjes kunnen onthouden. [.3]Herhaal de moves die op het scherm verschijnen. [.3]Duidelijk?",
            },
            {
                character = "panda",
                emotion = "cool",
                text =
                "DJ, [.2]start de muziek!",
            },
            {
                character = "cat",
                functions = {
                    init = function(self)
                        self.cutsceneData.cat.anim:set("cute")
                    end
                },
                text =
                "Miauw, [.2]ik bjen geen DJ. [.3]Ik bjen slechts een lieve pjoes!",
            },
            {
                character = "panda",
                sound = "frustrated",
                emotion = "mad",
                functions = {
                    init = function(self)
                        self.cutsceneData.cat.anim:set("look_right")
                        self.cutsceneData.panda.anim:set("frustrated_left")
                    end
                },
                text =
                "Doe nou niet zo vervelend DJ Vervelende Poes en start die klotemuziek!",
            },
            {
                character = "panda",
                emotion = "frustrated",
                sound = "sad",
                thinking = true,
                functions = {
                    init = function(self)
                        self.cutsceneData.panda.anim:set("sad")
                    end
                },
                text =
                "(Ik had DJ Kuthond nooit moeten ontslaan...)",
            },
            {
                character = "panda",
                functions = {
                    init = function(self)
                        self.cutsceneData.panda.anim:set("neutral")
                    end
                },
                text =
                "Oké daar gaan we! [.3]Kijk wat ik doe, [.2]en doe mij na. [.3]Gebruik je control stick, [.2]D-pad, [.2]of die knoppen rechts op je controller.",
            },
        }
    },
    functions = {
        prepare = function(self)
            self.camera:zoomTo(3)
            local level = self.map.currentLevel
            self.camera:moveToPoint(level.x, level.y + level.height)
        end,
        init = function(self)
            local panda_room = self:findEntityWithTag("PandaRoom")
            local panda = panda_room.panda
            local cat = panda_room.cat

            self.cutsceneData = {
                panda = panda,
                cat = cat
            }

            self:startDialogue("part1")
            self.camera:zoomTo(1, 3)

            self.coil:wait(6)

            panda_room.randomDanceMovesEvent:stop()
            panda_room.dancers:danceTo("neutral")

            self.cutsceneData.panda.anim:set("neutral_left")
            self.cutsceneData.cat.anim:set("look_left")

            self.music:stop(.3)

            self.coil:wait(1)

            self:startDialogue("part2")

            self:fadeOut(1)
            self.coil:wait(1.3)

            self.peter.visible = false
            self.timon.visible = false

            panda_room.peter.visible = true
            panda_room.timon.visible = true

            local doors = self:findEntitiesWithTag("Door")
            doors:foreach(function(e) e.side.z = 1 end)

            self.peter.x = panda_room.mapLevel.x + panda_room.mapLevel.width / 2
            self.timon.x = panda_room.mapLevel.x + panda_room.mapLevel.width / 2

            panda.anim:set("neutral")
            cat.anim:set("idle")

            self:fadeIn(1)
            self.coil:wait(1)
            self:startDialogue("part3")
            self.coil:wait(1)
            self.camera:zoomTo(1, 1)

            self:onEndCutscene(nil, true)
            panda_room:initializeGame()
        end,
    },
    flag = Enums.Flag.cutscenePandaIntro
}

return panda_intro
