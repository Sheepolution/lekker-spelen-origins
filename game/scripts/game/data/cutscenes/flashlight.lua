local horror_intro = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "confused_concerned",
                text = "Wow! [.3]Hier is het pas donker! [.3]Ik zie amper wat!",
            },
            {
                character = "peter",
                emotion = "scared",
                text = "Ik vind dit helemaal niks... [.3]Is er nergens een lichtknopje?",
            },
            {
                character = "timon",
                functions = {
                    run = function(self)
                        self.peter:cutsceneWalkTo(550, true, function() self.peter.flip.x = true end, true)
                        self.coil.wait(.5)
                        self.timon:cutsceneWalkTo(300, true, nil, true)
                    end,
                },
                text =
                "[function=run]Geen idee, [.2]maar daar liggen wel weer apparaatjes!\n[.5]Misschien zijn het wel zaklampen!",
            },
            {
                character = "peter",
                emotion = "questioning",
                functions = {
                    init = function(self)
                        self:findEntityWithTag("DeviceContainer"):giveDevicesToPlayers()
                    end
                },
                text =
                "Dit is een laboratorium vol met hightech spul,\n[.2]en jij verwacht dat dit zaklampen gaan zijn puur omdat het hier donker is?",
            },
            {
                character = "peter",
                sound = "silence",
                functions = {
                    init = function(self)
                        self.coil.wait(.4)
                        self.timon:turnFlashlightOn()
                        self.coil.wait(.2)
                        self.peter:turnFlashlightOn()
                    end
                },
                text = "[1][sound=default]Oh.",
            },
        },
    },
    functions = {
        prepare = function(self)
            local device_container = self:findEntityWithTag("DeviceContainer")
            device_container:addDevices()
        end,
        init = function(self)
            self:startDialogue("part1")
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneGettingFlashlights
}

return horror_intro
