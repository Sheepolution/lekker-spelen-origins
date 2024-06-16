CONFIG = {}

-- Game
CONFIG.title = "Lekker Spelen: Origins"

-- Size
CONFIG.windowScale = 1
CONFIG.gameScale = 2
CONFIG.baseWidth = 1920
CONFIG.baseHeight = 1080

CONFIG.gameWidth = CONFIG.baseWidth / CONFIG.gameScale
CONFIG.gameHeight = CONFIG.baseHeight / CONFIG.gameScale

-- Window
CONFIG.window = {}
CONFIG.window.width = CONFIG.baseWidth * CONFIG.windowScale
CONFIG.window.height = CONFIG.baseHeight * CONFIG.windowScale
CONFIG.window.vsync = 1
CONFIG.window.resizable = true
CONFIG.window.minwidth = 960
CONFIG.window.minheight = 540
-- FINAL = true
CONFIG.window.fullscreen = true
-- CONFIG.window.fullscreentype =
CONFIG.window.icon = "icon.png"

-- Audio
CONFIG.defaultSFXMax = 1
CONFIG.defaultSFXVolume = 1
CONFIG.defaultMusicMax = .3
CONFIG.defaultMusicVolume = 1

-- Speed
CONFIG.minFPS = 1 / 60

-- Graphics
CONFIG.defaultGraphicsFilter = "nearest"
CONFIG.defaultAnimationSpeed = 12

-- Text
CONFIG.defaultFont = "m5x7_custom"
CONFIG.defaultFontSize = 16

-- Input
CONFIG.gamepadSupport = true

-- Scene
CONFIG.defaultSpatialHashSize = 128

-- Map
CONFIG.levelPreloadRange = 0
CONFIG.levelActivateRange = 0

-- Libs
CONFIG.useLurker = false

function love.conf(t)
	io.stdout:setvbuf("no")
	t.identity = CONFIG.title:lower():gsub(" ", "_"):gsub(":", "")
	t.version = "11.5"
	t.window = nil
	t.modules.physics = false
	t.modules.touch = false
	t.modules.video = true
end
