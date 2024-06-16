local sicko_boss_defeat = {
    dialogues = {
        part1 = {
            {
                character = "sicko",
                emotion = "dead",
                sound = "death",
                text = "Wha-Whatever...",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self:delay(1, function()
                local bp = self:findEntityWithTag("Blueprint")
                bp.pickupable = true
                self:delay(4, function()
                    if not bp.destroyed then
                        local player = self:findNearestPlayer(bp)
                        self.noDoorAccess = false
                        bp:teleport(player:center())
                    end
                end)
            end)
            self:onEndCutscene()
        end,
    },
}

return sicko_boss_defeat
