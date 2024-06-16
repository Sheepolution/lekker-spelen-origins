local Save = require "base.save"
local document = require "documents.document"

local teleporter = {
    dialogues = {
        part1 = {
            {
                character = "timon",
                emotion = "confused",
                text = "Kijk, Peter, [.2]wat zijn dat?",
            },
            {
                functions = {
                    init = function(self)
                        self.timon:cutsceneWalkTo(100, true)
                        self.peter:cutsceneWalkTo(270, true, function() self.peter:lookAt(self.timon) end)
                    end
                },
                character = "peter",
                emotion = "thinking",
                text = "Geen idee. [.3]Het lijken een soort van apparaten te zijn.",
            },
            {
                character = "timon",
                functions = {
                    init = function(self)
                        self.coil:wait(1)
                        self:findEntityWithTag("DeviceContainer"):giveDevicesToPlayers()
                    end,
                },
                text = "Inderdaad. [.3]Laten we het gewoon meenemen. [.3]Misschien komt het wel van pas.",
            },
            {
                functions = {
                    turnAround = function(self)
                        self.peter:lookAway(self.timon)
                    end,
                    walk = function(self)
                        self.peter:cutsceneWalkTo(100, true)
                    end
                },
                character = "peter",
                text =
                "Dat kan geen kwaad. [.3][function=turnAround][.3]Oh, en daar ligt nog zo'n papiertje.[function=walk][.8]\nEens lezen...",
            },
            {
                character = "peter",
                emotion = "thinking",
                text =
                "Druk op B om te lokken[.1].[.1].[.1].[.1] [.2]Wat zouden ze daarmee bedoelen?",
            },
            {
                functions = {
                    init = function(self)
                        self.timon:teleportOther()
                    end
                },
                character = "peter",
                sound = "silence",
                emotion = "thinking",
                text =
                "[.5].[.3].[.3].[.3][emotion=scared][sound=default]Huh? [.3]Ik stond net daar! [.2]Waarom sta ik nu hier?",
            },
            {
                character = "timon",
                text = "Het zijn die apparaatjes, Peter. [.2]Ik drukte op het knopje zoals het papiertje zei.",
            },
            {
                character = "peter",
                emotion = "thinking",
                text =
                "Teleporteren[.1].[.1].[.1].[.1]?\n[.3][emotion=determined]Dit zou nog wel eens van pas kunnen komen.",
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
            self.peter.ability = self.peter.Ability.Teleport
            self.timon.ability = self.timon.Ability.Teleport
            Save:save("game.ability", self.timon.Ability.Teleport)
            self:showDocument("teleporter", document.DocumentType.Log)
            local owned_logs = list(Save:get("documents.logs"))
            if not owned_logs:contains("teleporter") then
                owned_logs:add("teleporter")
                Save:save("documents.logs", owned_logs:table())
            end
            self:onEndCutscene()
        end,
    },
    flag = Enums.Flag.cutsceneGettingTeleporters
}

return teleporter
