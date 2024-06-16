local FlagManager = require "flagmanager"
local Save = require "base.save"

local voice = function(self)
    self:findEntityWithTag("Computer").mode = "voice"
end

local eye = function(self)
    self:findEntityWithTag("Computer").mode = "eye"
end

local computer_functions = {
    init = voice,
    eye = eye
}

local computer3_post_waku = {
    dialogues = {
        part1 = {
            {
                character = "computer",
                sound = "3/waku_complete",
                settings = {
                    print_speed = .05
                },
                functions = computer_functions,
                text =
                "Jullie hebben de WAKU WAKU voltooid, en daarmee toegang tot de volgende ruimte.[emotion=eye][function=eye]",
            },
            {
                character = "peter",
                emotion = "default",
                text = "Eindelijk!"
            },
            {
                character = "computer",
                sound = "3/warned",
                settings = {
                    print_speed = .04
                },
                functions = computer_functions,
                text =
                "Maar wees gewaarschuwd. [.3]Er is een goede reden voor de beperkte toegang tot dit gedeelte van het laboratorium.[emotion=eye][function=eye]",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self:onEndCutscene()
            self.coil.wait(.5)

            FlagManager:set(Enums.Flag.cutsceneComputer3, true)

            local minigame = Save:get("minigames.waku")
            if not minigame then
                Save:save("minigames.waku", true)
                self:showNotification(
                    "Miniogames unlocked!\n\nJe kan vanuit het hoofdmenu nu WAKU WAKU opnieuw spelen als miniogame.")
            end

            self.noDoorAccess = false
        end
    },
}

return computer3_post_waku
