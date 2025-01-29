local bPathAtEnd = false
local gPeds = {}
local gVehicle

function MissionSetup()
    DATLoad("3_07.DAT", 2)
    DATLoad("Chapt2Trans.DAT", 2)
    DATInit()
    PedClearPOIForAllPeds()
    AreaClearAllPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    ChapterSet(2)
    LoadPedModels({
        131,
        97,
        236,
        237,
        195,
        123
    })
    LoadVehicleModels({ 288 })
    MissionDontFadeIn()
    AreaLoadSpecialEntities("Christmas", true)
    LoadAnimationGroup("Hang_Talking")
    ClockSet(8, 30)
    SoundStopCurrentSpeechEvent()
    SystemEnableFrontEndAndSelectScreens(false)
end

function main()
    PlayerSetHealth(200)
    PlayerSetPunishmentPoints(0)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaClearAllVehicles()
    AreaTransitionPoint(0, POINTLIST._3_07_PLAYERPOOR, 1, true)
    CameraSetXYZ(514.2725, -190.18013, 7.101344, 513.6727, -190.94771, 6.876837)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    Wait(1000)
    CameraSetPath(PATH._C3T_TOWN, true)
    CameraSetSpeed(13, 13, 13)
    CameraLookAtPath(PATH._C3T_LOOKAT, true)
    CameraLookAtPathSetSpeed(13, 13, 13)
    gPeds[1] = PedCreatePoint(236, POINTLIST._C3T_CONSTRUCTION, 1)
    gPeds[2] = PedCreatePoint(237, POINTLIST._C3T_CONSTRUCTION, 2)
    gPeds[3] = PedCreatePoint(195, POINTLIST._C3T_CONSTRUCTION, 3)
    gPeds[4] = PedCreatePoint(123, POINTLIST._C3T_CONSTRUCTION, 5)
    gVehicle = VehicleCreatePoint(288, POINTLIST._C3T_CONSTRUCTION, 4)
    gPeds[5] = PedCreatePoint(131, POINTLIST._C3T_PEDESTRIANS, 1)
    PedFollowPath(gPeds[5], PATH._C3T_PEDESTRIAN2, 0, 0)
    gPeds[6] = PedCreatePoint(97, POINTLIST._C3T_PEDESTRIANS, 2)
    PedFollowPath(gPeds[6], PATH._C3T_PEDESTRIAN1, 0, 0)
    PedFollowPath(gPeds[1], PATH._C3T_FARLEFT, 0, 0)
    PedFollowPath(gPeds[2], PATH._C3T_CENTER, 0, 0)
    PedFollowPath(gPeds[3], PATH._C3T_FARRIGHT, 0, 0)
    VehicleFollowPath(gVehicle, PATH._C3T_TRACTOR)
    PedClearAllWeapons(gPeds[4])
    VehicleEnableEngine(gVehicle, true)
    PedWarpIntoCar(gPeds[4], gVehicle)
    VehicleSetCruiseSpeed(gVehicle, 2)
    SoundPreloadSpeech(gPlayer, "NARRATION", 108, "supersize", true)
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    MinigameSetChapterCompletion("Chapt2Trans_Title", "Chapt2Trans_Name", true, 0)
    MinigameHoldCompletion()
    CameraFade(500, 1)
    Wait(501)
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 109, "supersize", true)
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    while SoundSpeechPlaying(gPlayer, "NARRATION", 108) do
        Wait(0)
    end
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 110, "supersize", true)
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    while SoundSpeechPlaying(gPlayer, "NARRATION", 109) do
        Wait(0)
    end
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 111, "supersize", true)
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    while SoundSpeechPlaying(gPlayer, "NARRATION", 110) do
        Wait(0)
    end
    SoundPlayPreloadedSpeech()
    Wait(50)
    while SoundSpeechPlaying(gPlayer, "NARRATION", 111) do
        Wait(0)
    end
    MinigameReleaseCompletion()
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(501)
    PedDelete(gPeds[1])
    PedDelete(gPeds[2])
    PedDelete(gPeds[3])
    PedDelete(gPeds[4])
    PedDelete(gPeds[5])
    PedDelete(gPeds[6])
    VehicleDelete(gVehicle)
    UnloadModels({
        131,
        97,
        236,
        237,
        195,
        123,
        288
    })
    UnloadModels({ 288 })
    PlayCutsceneWithLoad("3-0", true, true)
    SetFactionRespect(1, 85)
    SetFactionRespect(5, 100)
    AreaForceLoadAreaByAreaTransition(true)
    AreaTransitionPoint(14, POINTLIST._CHAPT2TRANS, 1)
    AreaForceLoadAreaByAreaTransition(false)
    LoadPedModels({ 134 })
    local pete = PedCreatePoint(134, POINTLIST._CHAPT2TRANS, 2)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    PedWander(pete, 0)
    PedMakeAmbient(pete)
    VehicleRevertToDefaultAmbient()
    CameraFade(500, 1)
    Wait(500)
    ClearTextQueue()
    MissionSucceed(false, false, false)
end

function MissionCleanup()
    WeatherForceSnow(false)
    WeatherRelease()
    AreaRevertToDefaultPopulation()
    CameraReturnToPlayer()
    PlayerSetScriptSavedData(3, PlayerGetNumTimesBusted())
    PlayerSetScriptSavedData(14, 0)
    SystemEnableFrontEndAndSelectScreens(true)
    SoundRemoveAllQueuedSpeech(gPlayer)
    SetFactionRespect(11, 100)
    SetFactionRespect(1, 85)
    SetFactionRespect(5, 100)
    SetFactionRespect(4, 50)
    SetFactionRespect(2, 45)
    SetFactionRespect(3, 0)
end
