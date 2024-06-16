local Flag = Enums.Flag

-- FINAL: All flags to false

local flags = {
    [Flag.cutsceneSecret] = false,
    [Flag.cutsceneIntro] = false,
    [Flag.cutsceneFirstLog] = false,
    [Flag.cutsceneVideogamesLog] = false,
    [Flag.cutsceneComputer1] = false,
    [Flag.cutsceneComputer2] = false,
    [Flag.cutsceneComputer3] = false,
    [Flag.cutsceneComputer4] = false,
    [Flag.cutsceneGettingTeleporters] = false,
    [Flag.cutsceneGettingCloners] = false,
    [Flag.cutsceneGettingSwimmers] = false,
    [Flag.cutsceneGettingFlashlights] = false,
    [Flag.cutsceneGettingShooters] = false,
    [Flag.cutsceneMeetingPier] = false,
    [Flag.cutsceneMeetingGier] = false,
    [Flag.cutsceneTelegate1] = false,
    [Flag.cutsceneTelegate2] = false,
    [Flag.cutsceneTelegate3] = false,
    [Flag.cutsceneTelegate4] = false,
    [Flag.cutsceneSniffReminder] = false,
    [Flag.cutsceneHorseyIntro] = false,
    [Flag.cutsceneTeleportersAgain] = false,
    [Flag.cutscenePandaIntro] = false,
    [Flag.cutsceneHellhoundIntro] = false,
    [Flag.cutsceneCentaurIntro] = false,
    [Flag.cutsceneKonkieIntro] = false,
    [Flag.cutsceneMainEvent2] = false,
    [Flag.cutscenePierBossIntro] = false,
    [Flag.cutsceneSickoIntro] = false,
    [Flag.cutsceneSelfDestruct] = false,
    [Flag.defeatedHorsey] = false,
    [Flag.defeatedPanda] = false,
    [Flag.defeatedHellhound] = false,
    [Flag.defeatedCentaur] = false,
    [Flag.defeatedKonkie] = false,
    [Flag.defeatedPier] = false,
    [Flag.hasAccessPass1] = false,
    [Flag.hasAccessPass2] = false,
    [Flag.hasAccessPass3] = false,
    [Flag.hasAccessPass4] = false,
    [Flag.hasAccessPass5] = false,
    [Flag.hasAccessPass6] = false,
    [Flag.activatedTeleportPlatforms] = false,
    [Flag.ateMiniPapflap] = false,
}

if not DEBUG then
    for k, v in pairs(flags) do
        flags[k] = false
    end
end

return flags
