local Canvas = require "base.canvas"

GLOBAL = {}

PI = math.pi
TAU = PI * 2

SCREEN_WIDTH = love.graphics.getWidth()
SCREEN_HEIGHT = love.graphics.getHeight()

WIDTH = CONFIG.gameWidth
HEIGHT = CONFIG.gameHeight

THRESHOLD = 0.0000000000000000000001

CANVAS = Canvas(1920, 1080)
