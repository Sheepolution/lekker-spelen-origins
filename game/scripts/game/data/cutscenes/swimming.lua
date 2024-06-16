local swimming = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "nauseous",
                text = "Oh man... [.3]Ik snap niet dat die wetenschappers zichzelf dit aandoen...",
            },
            {
                character = "peter",
                emotion = "frustrated",
                text = "Zo onnodig futuristisch ook. [.3]Bouw gewoon een lift.",
            },
            {
                character = "timon",
                emotion = "mad",
                text = "Maar echt! [.3]En we zijn onze [emotion=sarcastic_extreme]teleporters weer kwijt ook.",
            },
            {
                character = "peter",
                emotion = "happy",
                functions = {
                    run = function(self)
                        self.peter:cutsceneWalkTo(660, true, function() self.peter.flip.x = true end, true)
                        self.coil.wait(.5)
                        self.timon:cutsceneWalkTo(440, true, nil, true)
                    end,
                },
                text = "Ja maar kijk! [.3][function=run]Daar liggen weer nieuwe apparaatjes.",
            },
            {
                character = "timon",
                emotion = "happy_tongue",
                functions = {
                    give = function(self)
                        self:findEntityWithTag("DeviceContainer"):giveDevicesToPlayers()
                    end
                },
                text =
                "Oja! [function=give][.3]Is het weer dat klonen?"
            },
            {
                character = "peter",
                emotion = "thinking",
                text =
                "Nee, het lijkt weer iets anders te zijn. [.3]Je moet het om je mond doen zo te zien. [.3]Een soort masker om door te ademen?",
            },
            {
                character = "timon",
                emotion = "confused_mad",
                text =
                "Eerst die portalen en nu gaan ze zelfs ademen voor je regelen. [.3]Die science guys weten echt niet wanneer ze moeten stoppen.",
            },
            {
                character = "peter",
                emotion = "thinking",
                functions = {
                    pan = function(self)
                        self.coil.wait(2.5)
                        self.peter.flip.x = false
                        self.coil.wait(.5)
                        self.camera:tweenToRelativePoint(300, 100, 2)
                    end
                },
                text =
                "Nee maar dit moet toch ergens voor zijn? [.3][emotion=thinking_sarcastic]\nMaar wat...?[function=pan][4][auto]",
            },
        }
    },
    functions = {
        prepare = function(self)
            local device_container = self:findEntityWithTag("DeviceContainer")
            device_container:addDevices()

            self.camera:follow()
        end,
        init = function(self)
            self:startDialogue("part1")
            self.coil.wait(2)
            self.camera:tweenToObject(self.cameraFollow, .5)
            self.coil.wait(.5)
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneGettingSwimmers
}

return swimming
