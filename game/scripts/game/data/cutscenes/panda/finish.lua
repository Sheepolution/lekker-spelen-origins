local done = {
    functions = {
        init = function(self)
            local pandaRoom = self:findEntityWithTag("PandaRoom")

            self:fadeOut(1)
            self.coil:wait(1.3)
            pandaRoom.dansCamera = false
            pandaRoom.peter.dance = false
            pandaRoom.dansPauze.visible = false
            self.camera:zoomTo(1)
            self.camera:moveToPoint(self:getLevel():center())
            self.camera.camera.angle = 0
            self.camera:follow(self.cameraFollow)

            self.peter.visible = true
            self.timon.visible = true
            self.peter.inControl = true
            self.timon.inControl = true

            pandaRoom.peter.visible = false
            pandaRoom.timon.visible = false

            pandaRoom:doRandomDanceMoves()
            local doors = self:findEntitiesWithTag("Door")
            doors:foreach(function(e) e.side.z = ZMAP.DoorSide end)

            self:fadeIn(1)
            self.coil:wait(1)
            self:onEndCutscene()
        end,
    },
}

return done
