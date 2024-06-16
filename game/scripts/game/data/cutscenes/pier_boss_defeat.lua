local pier_boss_defeat = {
    dialogues = {
        part1 = {
            {
                character = "pier",
                emotion = "dead",
                sound = "death",
                text = "Dat was... [.5]leuk...\n[1]Bedankt... [.5][emotion=dead_smile]voor de dolle pret.",
            },
        },
    },
    functions = {
        init = function(self)
            self:startDialogue("part1")
            self:delay(1, function()
                local ap = self:findEntityWithTag("AccessPass")
                ap.pickupable = true
                self:delay(4, function()
                    if not ap.destroyed then
                        local player = self:findNearestPlayer(ap)
                        ap:teleport(player:center())
                    end
                end)
            end)
            self:onEndCutscene()
        end,
    },
}

return pier_boss_defeat
