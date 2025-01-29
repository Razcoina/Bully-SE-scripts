local peds = {}

function MissionSetup()
    SoundDisableSpeech_ActionTree()
    SoundStopAmbiences()
    SoundStopPA()
    PedClearPOIForAllPeds()
    AreaClearAllPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    MissionDontFadeIn()
    DATLoad("Chapt1Trans.DAT", 2)
    CameraSetWidescreen(true)
    if AreaGetVisible() == 0 then
        GeometryInstance("ScGate01Closed", true, 301.439, -72.5059, 8.04657, false)
        AreaSetPathableInRadius(303.1998, -72.23503, 5.583573, 0.5, 3, true)
        GeometryInstance("ScGate02Closed", true, 225.928, 5.79816, 8.39471, false)
        AreaSetPathableInRadius(226.3478, 5.853811, 5.758574, 0.5, 3, true)
    end
    LoadPedModels({
        69,
        145,
        3,
        70,
        73,
        30,
        35
    })
    ClockSet(8, 30)
    SoundStopCurrentSpeechEvent()
    SystemEnableFrontEndAndSelectScreens(false)
end

function main()
    local justRequested = 0
    local onceItsDone = 0
    F_MakePlayerSafeForNIS(true)
    PlayerSetHealth(200)
    PlayerSetPunishmentPoints(0)
    ChapterSet(1)
    PlayerSetControl(0)
    WeatherSet(4)
    if PAnimExists(TRIGGER._TSCHOOL_FRONTGATE) then
        PAnimDelete(TRIGGER._TSCHOOL_FRONTGATE)
    end
    PAnimCreate(TRIGGER._TSCHOOL_FRONTGATE)
    AreaTransitionPoint(0, POINTLIST._CHAPT1TRANSPLYR, 1, true)
    CameraSetWidescreen(true)
    CameraSetXYZ(215.46382, -73.07923, 9.913595, 216.46341, -73.08206, 9.886928)
    SoundPreloadSpeech(gPlayer, "NARRATION", 105, "supersize", true)
    justRequested = GetTimer()
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    onceItsDone = GetTimer()
    CameraSetPath(PATH._CHAPTTRANS_FOLLOW, true)
    CameraLookAtXYZ(289.518, -72.9983, 7.98641, true)
    CameraSetSpeed(2, 0, 0)
    MinigameSetChapterCompletion("Chapt1Message", "Chapt1Name", true, 0)
    MinigameHoldCompletion()
    local ped = PedCreatePoint(73, POINTLIST._CHAPTTRANSPLACEMENT, 1)
    PedFollowPath(ped, PATH._CHAPTTRANS_FOLLOW1B, 0, 0)
    table.insert(peds, ped)
    ped = PedCreatePoint(70, POINTLIST._CHAPTTRANSPLACEMENT, 2)
    PedFollowPath(ped, PATH._CHAPTTRANS_FOLLOW1A, 0, 0)
    table.insert(peds, ped)
    ped = PedCreatePoint(30, POINTLIST._CHAPTTRANSPLACEMENT, 3)
    PedFollowPath(ped, PATH._CHAPTTRANS_FOLLOW2A, 0, 0)
    table.insert(peds, ped)
    ped = PedCreatePoint(35, POINTLIST._CHAPTTRANSPLACEMENT, 4)
    PedFollowPath(ped, PATH._CHAPTTRANS_FOLLOW2B, 0, 0)
    table.insert(peds, ped)
    ped = PedCreatePoint(3, POINTLIST._CHAPTTRANSPLACEMENT, 5)
    PedFollowPath(ped, PATH._CHAPTTRANS_FOLLOW3A, 0, 0)
    table.insert(peds, ped)
    ped = PedCreatePoint(69, POINTLIST._CHAPT1CHASE, 1)
    PedSetInfiniteSprint(ped, true)
    PedMoveToPoint(ped, 3, POINTLIST._CHAPT1CHASE, 3)
    table.insert(peds, ped)
    local ped2 = PedCreatePoint(145, POINTLIST._CHAPT1CHASE, 2)
    PedAttack(ped2, ped, 3)
    table.insert(peds, ped2)
    CameraFade(500, 1)
    Wait(501)
    CameraSetSpeed(8, 8, 8)
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 106, "supersize", true)
    justRequested = GetTimer()
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    onceItsDone = GetTimer()
    while SoundSpeechPlaying(gPlayer, "NARRATION", 105) do
        Wait(0)
    end
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 107, "supersize", true)
    justRequested = GetTimer()
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    onceItsDone = GetTimer()
    while SoundSpeechPlaying(gPlayer, "NARRATION", 106) do
        Wait(0)
    end
    SoundPlayPreloadedSpeech()
    PAnimOpenDoor(TRIGGER._TSCHOOL_FRONTGATE)
    Wait(1000)
    Wait(50)
    while SoundSpeechPlaying(gPlayer, "NARRATION", 107) do
        Wait(0)
    end
    MinigameReleaseCompletion()
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(501)
    for i, ped in peds do
        if ped and PedIsValid(ped) then
            PedDelete(ped)
        end
    end
    UnloadModels({
        4,
        145,
        3,
        70,
        73,
        30,
        35
    })
    F_MakePlayerSafeForNIS(false)
    SoundContinue()
    CameraSetWidescreen(false)
    WeatherRelease()
    PlayCutsceneWithLoad("2-0", true, true)
    shared.g2_03_shirt = true
    AreaDisableCameraControlForTransition(true)
    AreaTransitionPoint(2, POINTLIST._CHAPT1TRANS, 1)
    Wait(10)
    PlayerFaceHeadingNow(90)
    Wait(10)
    PlayerSetControl(1)
    CameraReturnToPlayer()
    shared.updateDefaultKOPoint = true
    shared.addBusPoints = true
    MissionSucceed(true, false, false)
end

function MissionCleanup()
    if PAnimExists(TRIGGER._TSCHOOL_FRONTGATE) then
        PAnimDelete(TRIGGER._TSCHOOL_FRONTGATE)
    end
    AreaRevertToDefaultPopulation()
    SoundRemoveAllQueuedSpeech(gPlayer)
    AreaDisableCameraControlForTransition(false)
    DATUnload(2)
    SoundRestartPA()
    SoundRestartAmbiences()
    SoundEnableSpeech_ActionTree()
    CameraReturnToPlayer()
    PlayerSetScriptSavedData(3, PlayerGetNumTimesBusted())
    PlayerSetScriptSavedData(14, 0)
    SetFactionRespect(11, 100)
    SetFactionRespect(1, 75)
    SetFactionRespect(5, 50)
    SetFactionRespect(4, 50)
    SetFactionRespect(2, 45)
    SetFactionRespect(3, 0)
    SystemEnableFrontEndAndSelectScreens(true)
end
