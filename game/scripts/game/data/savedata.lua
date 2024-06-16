local Save = require "base.save"

local savedata = {
    game = {
        beatGame = false,
        euro = 0,
        health = {
            -- FINAL: 2, 2
            peter = {
                max = 2,
                current = 2,
            },
            timon = {
                max = 2,
                current = 2,
            }
        },
        deaths = {
            peter = 0,
            timon = 0,
        },
        spacer_racer = {
            deaths = {
                total = 0,
                level = 0
            },
            time = 0
        },
        waku = {
            questions = 0,
            peter = 0,
            timon = 0,
            lifelines = 0,
        },
        stats = {
            time = 0,
            euro = 0,
            main_event = "peter",
        }
    },
    beatGame = false,
    documents = {
        blueprints = {
        },
        logs = {
        }
    },
    minigames = {
        waku = false,
        spacer_racer = false,
        fighter = false,
        sr_times = {},
    },
    settings = {
        controls = {
            peter = {
                player1 = true,
                rumble = true
            },
            timon = {
                player1 = false,
                rumble = true
            }
        },
        screen = {
            fullscreen = true,
            pixelperfect = false,
            sharp = true,
            vsync = false,
        },
        audio = {
            master = 100,
            music = 100,
            sfx = 100,
        }
    }
}

Save:saveDefault(savedata)

return savedata
