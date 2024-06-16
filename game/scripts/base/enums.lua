local Enum = require "libs.enum"

local Enums = {}

Enums.Direction = Enum("Left", "Right", "Up", "Down", "LeftUp", "LeftDown", "RightUp", "RightDown", "Center")

return Enums
