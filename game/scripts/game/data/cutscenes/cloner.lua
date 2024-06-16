local cloner = {
    dialogues = {
        part1 = {
            {
                character = "peter",
                emotion = "questioning",
                text = "Wow, [.2]dat voelde raar. [.3]Ik ben helemaal duizelig.",
            },
            {
                character = "timon",
                emotion = "tired",
                text =
                "Peter[.1].[.1].[.1]. ik voel me misselijk[.1].[.1].[.1].\n[.3][emotion=nauseous]Ik ga misschien gewoon braken zelfs.",
            },
            {
                character = "peter",
                emotion = "scared_serious",
                functions = {
                    run = function(self)
                        self.peter:cutsceneWalkTo(270, true, function() self.peter.flip.x = true end, true)
                    end,
                },
                text = "Iel! [.3][function=run]In dat geval doe ik een paar stappen opzij. [.2]En ga me niet lokken!",
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "Wacht[.1].[.1].[.1]. [emotion=concerned]HUH?! [.3]Waar zijn onze teleporter machines?!",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text =
                "Hey inderdaad! [.3]Volgens mij zijn ze achtergebleven toen we door dat portaal-ding gingen.[.3]\nHelemaal balen dit...",
            },
            {
                character = "peter",
                emotion = "default",
                functions = {
                    run = function(self)
                        self.peter.flip.x = false
                        self.camera:tweenToRelativePoint(400, 0, 2)
                        self.coil.wait(1)
                        self.peter:cutsceneWalkTo(300, true, function() self.peter.flip.x = true end, true)
                        self.coil.wait(.2)
                        self.timon:cutsceneWalkTo(250, true, nil, true)
                    end,
                },
                text =
                "Ja, ze waren juist zo handig! [function=run][.5]\n[emotion=happy]Oh maar kijk Timon, daar liggen ze ook gewoon!",
            },
            {
                character = "timon",
                emotion = "happy_tongue",
                functions = {
                    init = function(self)
                        self:findEntityWithTag("DeviceContainer"):giveDevicesToPlayers()
                    end,
                },
                text =
                "Hoppaaa! [.5][emotion=confused]Of[.1].[.1].[.1]. toch niet? [.3][emotion=confused_mad]Nee Peter, deze zien er anders uit!",
            },
            {
                character = "peter",
                emotion = "thinking",
                text = "Je hebt gelijk! [.3]Maar wat zou dit knopje dan doen? [.3]Hou je vast Timon, [.2]ik ga drukken!",
            },
            {
                functions = {
                    init = function(self)
                        self.peter:createClone()
                    end,
                },
                character = "timon",
                emotion = "frustrated",
                sound = "silence",
                text = ".[.3].[.3].[.3][sound=default][emotion=wink_concerned]Heb je al gedrukt?",
            },
            {
                character = "peter",
                emotion = "mad",
                text =
                "Al meerdere keren, [.2]maar dit kutding doet helemaal niks.",
            },
            {
                character = "peter",
                emotion = "sarcastic",
                functions = {
                    init = function(self)
                        self.peter:cutsceneWalkTo(100, true)
                    end,
                },
                text =
                "Ach laat maar zitten ook.[.3]\nKom, Timon, dan gaan we verder!",
            },
            {
                character = "timon",
                emotion = "shocked_ep",
                text = "HUH?![.3]\nOf ik ben nog steeds duizelig,[.2] [emotion=tired_mad]of er zijn twee Peters!",
            },
            {
                character = "peter",
                emotion = "mad",
                functions = {
                    flip = function(self)
                        self.peter.flip.x = true
                    end,
                },
                text =
                "Timon, wat loop je nou allemaal te brabbelen?[function=flip]",
            },
            {
                character = "peter",
                functions = {
                    flip = function(self)
                        self.peter.flip.x = true
                    end,
                },
                text =
                "Hey, dat ben ik! [.3]Of nouja, [.2]het lijkt op mij!",
            },
            {
                character = "timon",
                emotion = "confused",
                text = "Klonen[.1].[.1].[.1].[.1]?\n[.3][emotion=happy_wink]Dit zou nog wel eens van pas kunnen komen!",
            },
        },
    },
    functions = {
        prepare = function(self)
            local device_container = self:findEntityWithTag("DeviceContainer")
            device_container:addDevices()

            self.camera:zoomTo(2)
            local level = self.map.currentLevel
            self.camera:moveToPoint(level.x, level.y + level.height - 200)
        end,
        init = function(self)
            self:startDialogue("part1")
            self.camera:zoomTo(1, 1)
            self.camera:follow(self.cameraFollow)
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneGettingCloners
}

return cloner
