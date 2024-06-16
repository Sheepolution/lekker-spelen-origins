local WaterBackground = require "decoration.water_background"
local Sprite = require "base.sprite"
local Scene = require "base.scene"

local HorrorLevel = Scene:extend("WaterLevel")

local Placement = require "base.components.placement"

function HorrorLevel:new(x, y, mapLevel)
    HorrorLevel.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function HorrorLevel:done()
    self.background:add("sets/animals_in_bottles", 1341, 318)
    self.background:add("sets/cages1", 323, 359)
    self.background:add("flora/set/3", 275, 445)
    self.background:add("bordje_alert", 642, 376)
    self.background:add("kooi_hangend", 850, 152)
    self.background:add("flora/set/4", 1687, 373)
    self.background:add("flora/set/5", 1808, 352)
    self.background:add("kooi_hangend", 2462, 56)
    self.background:add("kist", 2194, 416)
    self.background:add("flora/set/9", 2239, 434)
    self.background:add("flora/set/8", 2171, 447)
    self.background:add("bordje_giftig", 3022, 395)
    self.background:add("sets/doctor_chair", 2468, 338)
    self.background:add("sets/bureau2", 3144, 336)
    self.background:add("spinnenweb_links_m", 3776, 344)
    self.background:add("vat_radioactief", 3514, 397)
    self.background:add("kooi_hangend", 4404, 184)
    self.background:add("deur_verboden_toegang", 4493, 216)
    self.background:add("flora/set/7", 4922, 320)
    self.background:add("flora/set/1", 5903, 435)
    self.background:add("flora/set/2", 6089, 444)
    self.background:add("sets/cages2", 6677, 359)
    self.background:add("flora/set/9", 7003, 434)
    self.background:add("flora/set/8", 6936, 447)
    self.background:add("sets/bureau8", 7214, 383)
    self.background:add("kooi_hangend_medium", 7450, 184)
    self.background:add("kooi_hangend_lang", 8542, 184)
    self.background:add("kooi_hangend_medium", 8675, 184)
    self.background:add("flora/set/4", 8644, 437)
    self.background:add("flora/set/5", 8765, 416)
    self.background:add("flora/set/1", 9265, 435)
    self.background:add("flora/set/2", 8922, 444)
    --
    self.background:add("flora/set/14", 1093, 448)
    self.background:add("flora/set/14", 3733, 256)
    self.background:add("flora/set/14", 5120, 448)
    self.background:add("flora/set/14", 5706, 448)
    self.background:add("flora/set/14", 6135, 448)
    self.background:add("flora/set/14", 7782, 296)
    self.background:add("flora/set/14", 9364, 448, true)

    self.background:add("sets/animals_in_bottles", 8111, 158, true)
    self.background:add("hibernation_tube_bg_broken", 527, 285)
    self.background:add("hibernation_tube_bg_broken", 4241, 285)
    self.background:add("hibernation_tube_bg_broken", 8437, 285)

    self.background:add("spinnenweb_links_s", 1023, 344, true)
    self.background:add("spinnenweb_links_s", 3967, 344, true)
    self.background:add("spinnenweb_links_s", 5567, 280, true)
    self.background:add("spinnenweb_links_s", 8128, 376)

    self.background:add("spin_midden", 1016, 346)
    self.background:add("spin_midden", 5560, 281)
    self.background:add("spin_midden", 8153, 377)

    self.background:add("sets/chemistry6", 9920, 558)
    self.background:add("deur_planken", 2870, 304)

    self.background:add("flora/set/9", 805, 339)
    self.background:add("flora/set/9", 2423, 243)
    self.background:add("flora/set/9", 3945, 243)
    self.background:add("flora/set/9", 6022, 435)
    self.background:add("flora/set/9", 8028, 435)
    self.background:add("flora/set/9", 9020, 435)
    self.background:add("flora/set/9", 9700, 435)

    self.background:add("flora/set/12", 5830, 430)
    self.background:add("flora/set/13", 5967, 416)
    self.background:add("flora/set/7", 6233, 416)
    self.background:add("flora/set/3", 5797, 445, true)
    self.background:add("flora/set/10", 5876, 443)

    self.background:add("bord_halt", 9783, 371)


    --
    self.spider = self.mapLevel:add(Sprite(self.x + 11028, self.y, "decoration/horror/spider"))
    self.spider.z = ZMAP.TOP

    self.timer = 0
end

function HorrorLevel:update(dt)
    self.timer = self.timer + dt

    if not self.splitscreen then
        self.spider.offset.x = (self.spider.x - self.x) - (self.scene.camera.x - self.x) * 2.2 +
            math.cos(self.timer * PI * .25) * 15
    end

    -- Placement.update(self.spider, dt)
end

return HorrorLevel
