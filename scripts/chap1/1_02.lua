local gGary
local gObjectives = {}
local gMissionState = "main"
local gMissionUpdateFunction
local gClothingTutorial = false
local gChangedProperly = false
local gDeleteGary = false
local gSecretary
local gBlockersT = {}
local gPrefect, gRussell
local bCanPush = false
local bMonitorRussellEncounter = true
local bFightingRussell = false
local bFoughtRussell = false
local bRussellHumiliatedPlayer = false
local bTimedOut = false
local gPreviousPlayerHealth = 0
local gPreviousRussellHealth = 0
local gTimeRussellStartedHarassing = 0
local gOriginalBullyHealth = 0
local gPlayerHealth = 0
local gTargetNumber
local gCurrentCombo = 1
local gCurrentPlayerMove = 1
local gMoveLanded = false
local gOriginalHealth = 0
local gLastTimeCheckedHit = 0
local bCanBullyLaunchAttacks = false
local bInTraining = false
local gBully01, gBully02, gBully03
local gPushers = {}
local gSequencePassed = false
local gSequenceFailed = false
local L36_1 = false
local bLightAttacks = false
local bHeavyAttacks = false
local bGrappleAttacks = false
local bGroundKicks = false
local bGrapplePunches = false
local bFinalStage = false
local bPushPlayer = true
local bIgnoreR1 = false
local Gate102Pos = {
    271.099,
    -102.023,
    8.49927,
    0
}
local Gate102PoolIndex, Gate102Entity
local numBully01 = 0
local numBully02 = 0
local numBully03 = 0
local numBully04 = 0
local numBully05 = 0
local numBoy02 = 0
local numWhiteBoy = 0
local numHispanicBoy = 0
local numRussell = 0
local pLastPed
local gComboTable = {
    {
        1,
        "/Global/TrainingPlayer/Attacks/Strikes/SloppyAttacks",
        { 7 },
        false
    },
    {
        1,
        "/Global/TrainingPlayer/Attacks/Strikes/HeavyAttacks",
        { 6 },
        false
    }
}

function MissionSetup()
    MissionDontFadeIn()
    SoundEnableInteractiveMusic(false)
    if GetMissionAttemptCount("1_02") == 1 then
        PlayCutsceneWithLoad("1-1-2", true, true)
    end
    DATLoad("1_02.DAT", 2)
    DATInit()
end

function F_MissionSetup()
    SoundEnableInteractiveMusic(true)
    ButtonHistoryEnableActionTreeInput(true)
    ClockSet(8, 30)
    PlayerSetControl(0)
    gModelList = {
        102,
        99,
        85,
        145,
        146,
        73,
        139,
        69,
        75,
        74
    }
    LoadPedModels(gModelList)
    LoadAnimationGroup("1_02_MeetWithGary")
    LoadAnimationGroup("TE_FEMALE")
    LoadAnimationGroup("Russell")
    LoadAnimationGroup("F_Girls")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadAnimationGroup("F_Douts")
    LoadAnimationGroup("Hang_Talking")
    LoadAnimationGroup("Area_School")
    LoadAnimationGroup("SBULL_A")
    LoadAnimationGroup("NPC_Adult")
    LoadAnimationGroup("HUMIL_6-5VPLY")
    LoadAnimationGroup("NIS_1_02")
    LoadAnimationGroup("NIS_1_02B")
    LoadActionTree("Act/Conv/1_02.act")
    LoadActionTree("Act/Conv/1_01.act")
    LoadActionTree("Act/TrainingPlayer.act")
    LoadActionTree("Act/Anim/Fight_Tutorial.act")
    LoadActionTree("Act/AI/AI_FightTutorial.act")
    WeatherSet(0)
    PedClearHasAggressed(gPlayer)
    PedSocialOverrideLoad(6, "Mission/1_02Aggro.act")
    PedSocialOverrideLoad(0, "Mission/1_02Aggro.act")
    PedSocialOverrideLoad(1, "Mission/1_02Aggro.act")
    numBully01 = PedGetUniqueModelStatus(102)
    PedSetUniqueModelStatus(102, -1)
    numBully02 = PedGetUniqueModelStatus(99)
    PedSetUniqueModelStatus(99, -1)
    numBully03 = PedGetUniqueModelStatus(85)
    PedSetUniqueModelStatus(85, -1)
    numBully04 = PedGetUniqueModelStatus(145)
    PedSetUniqueModelStatus(145, -1)
    numBully05 = PedGetUniqueModelStatus(146)
    PedSetUniqueModelStatus(146, -1)
    numBoy02 = PedGetUniqueModelStatus(73)
    PedSetUniqueModelStatus(73, -1)
    numWhiteBoy = PedGetUniqueModelStatus(139)
    PedSetUniqueModelStatus(139, -1)
    numHispanicBoy = PedGetUniqueModelStatus(69)
    PedSetUniqueModelStatus(69, -1)
    numRussell = PedGetUniqueModelStatus(75)
    PedSetUniqueModelStatus(75, -1)
end

function MissionCleanup()
    AreaSetDoorLocked("DT_TSCHOOL_BOYSDORML", false)
    --print("CLEANING!!!")
    ButtonHistoryEnableActionTreeInput(false)
    ButtonHistoryIgnoreController(false)
    ToggleHUDComponentVisibility(21, false)
    ToggleHUDComponentVisibility(4, true)
    ToggleHUDComponentVisibility(11, true)
    ToggleHUDComponentVisibility(0, true)
    ClearTextQueue()
    DATUnload(2)
    PlayerWeaponHudLock(false)
    PlayerSetInvulnerable(false)
    if Gate102PoolIndex ~= nil then
        GeometryInstance("1_02Gate", true, Gate102Pos[1], Gate102Pos[2], Gate102Pos[3], false)
        DeletePersistentEntity(Gate102PoolIndex, Gate102Entity)
    end
    if shared.gSecretaryID and PedIsValid(shared.gSecretaryID) then
        PedSetMissionCritical(shared.gSecretaryID, false)
    end
    UnLoadAnimationGroup("1_02_MeetWithGary")
    UnLoadAnimationGroup("TE_FEMALE")
    UnLoadAnimationGroup("Russell")
    UnLoadAnimationGroup("F_Girls")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("F_Douts")
    UnLoadAnimationGroup("Hang_Talking")
    UnLoadAnimationGroup("Area_School")
    UnLoadAnimationGroup("SBULL_A")
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("HUMIL_6-5VPLY")
    UnLoadAnimationGroup("NIS_1_02")
    UnLoadAnimationGroup("NIS_1_02B")
    PedResetTypeAttitudesToDefault()
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    --print("CRASHING HERE???")
    PlayerSetControl(1)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    CameraReset()
    PedHideHealthBar()
    PlayerIgnoreTargeting(false)
    PedLockTarget(gPlayer, -1)
    PedSetAIButes("Default")
    if gBully01 then
        PedDelete(gBully01)
        gBully01 = 1
    end
    if gRussell then
        PedDelete(gRussell)
        gRussell = nil
    end
    if gPrefect then
        PedDelete(gPrefect)
        gPrefect = nil
    end
    if numBully01 then
        PedSetUniqueModelStatus(102, numBully01)
    end
    if numBully02 then
        PedSetUniqueModelStatus(99, numBully02)
    end
    if numBully03 then
        PedSetUniqueModelStatus(85, numBully03)
    end
    if numBully04 then
        PedSetUniqueModelStatus(145, numBully04)
    end
    if numBully05 then
        PedSetUniqueModelStatus(146, numBully05)
    end
    if numBoy02 then
        PedSetUniqueModelStatus(73, numBoy02)
    end
    if numWhiteBoy then
        PedSetUniqueModelStatus(139, numWhiteBoy)
    end
    if numHispanicBoy then
        PedSetUniqueModelStatus(69, numHispanicBoy)
    end
    if numRussell then
        PedSetUniqueModelStatus(75, numRussell)
    end
    EnablePOI(true, true)
    AreaEnableAllPatrolPaths()
    DisablePunishmentSystem(false)
    PedSetActionNode(gPlayer, "/Global/1_02/IdleFight/SimpleIdle", "Act/Conv/1_02.act")
    if gRussell ~= nil and PedIsValid(gRussell) then
        PedDelete(gRussell)
        gRussell = nil
    end
    --print("CLEANED!!!")
end

local gRussNode = 0

function CB_RussPath(pedId, pathId, nodeId)
    gRussNode = nodeId
end

function F_DoCutscene()
    local bSkip = false
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    CameraFade(500, 0)
    Wait(500)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaDisableAllPatrolPaths()
    AreaClearAllPeds()
    if gBully02 and PedIsValid(gBully02) then
        PedDelete(gBully02)
    end
    if gBully03 and PedIsValid(gBully03) then
        PedDelete(gBully03)
    end
    if gPushers[2] and PedIsValid(gPushers[2]) then
        PedDelete(gPushers[2])
    end
    if gPushers[1] and PedIsValid(gPushers[1]) then
        PedDelete(gPushers[1])
    end
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    bMonitorRussellEncounter = false
    if gBully01 and not PedIsDead(gBully01) and PedIsValid(gBully01) then
        PedDelete(gBully01)
    end
    PlayerSetPosPoint(POINTLIST._1_02_NISLOCATIONS, 1)
    gPrefect = PedCreatePoint(61, POINTLIST._1_02_NISLOCATIONS, 2)
    gRussell = PedCreatePoint(75, POINTLIST._1_02_NISLOCATIONS, 3)
    gPushers[1] = PedCreatePoint(99, POINTLIST._1_02_NIS_BULLIES, 1)
    gPushers[2] = PedCreatePoint(145, POINTLIST._1_02_NIS_BULLIES, 2)
    gBully02 = PedCreatePoint(102, POINTLIST._1_02_NIS_BULLIES, 3)
    gBully03 = PedCreatePoint(85, POINTLIST._1_02_NIS_BULLIES, 4)
    PedSetInfiniteSprint(gPushers[1], true)
    PedSetInfiniteSprint(gPushers[2], true)
    PedSetInfiniteSprint(gBully03, true)
    PedSetInfiniteSprint(gBully02, true)
    PlayerSetInvulnerable(true)
    PedIgnoreStimuli(gPrefect, true)
    F_RestorePeds(gBlockersT, true)
    if gBully01 and PedIsValid(gBully01) then
        PedDelete(gBully01)
    end
    Wait(100)
    SoundSetAudioFocusCamera()
    CameraSetWidescreen(true)
    DoublePedShadowDistance(true)
    SoundDisableSpeech_ActionTree()
    gBully01 = PedCreatePoint(146, POINTLIST._1_02_NISLOCATIONS, 4)
    CameraSetFOV(20)
    CameraSetXYZ(262.03876, -107.05659, 7.649979, 262.90775, -107.54619, 7.580511)
    CameraFade(500, 1)
    SoundPlayScriptedSpeechEvent(gPlayer, "M_1_02", 90, "large", true)
    PedSetActionNode(gPlayer, "/Global/1_02/NIS/MeetRussell/Jimmy/Jimmy01", "Act/Conv/1_02.act")
    PedSetActionNode(gRussell, "/Global/1_02/NIS/MeetRussell/Russell/Russell01", "Act/Conv/1_02.act")
    PedSetActionNode(gBully01, "/Global/1_02/NIS/MeetRussell/Bullies/Bullies", "Act/Conv/1_02.act")
    Wait(6500)
    SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 9, "large", true)
    Wait(1500)
    SoundPlayScriptedSpeechEvent(gPrefect, "M_1_02", 131, "large", true)
    Wait(500)
    PedIgnoreStimuli(gPrefect, true)
    PedMoveToPoint(gPrefect, 2, POINTLIST._1_02_NISLOCATIONS, 5)
    Wait(500)
    PedMoveToPoint(gPushers[1], 1, POINTLIST._1_02_NIS_BULLIESFLEE, 1)
    Wait(200)
    PedMoveToPoint(gPushers[2], 2, POINTLIST._1_02_NIS_BULLIESFLEE, 2)
    PedMoveToPoint(gBully02, 1, POINTLIST._1_02_NIS_BULLIESFLEE, 3)
    PedMoveToPoint(gBully03, 0, POINTLIST._1_02_NIS_BULLIESFLEE, 4)
    CameraSetXYZ(269.75888, -114.511444, 7.713468, 269.93295, -113.52723, 7.682266)
    Wait(1500)
    PedSetAsleep(gPrefect, true)
    DisablePunishmentSystem(true)
    PedStop(gPrefect)
    PedClearObjectives(gPrefect)
    PedMakeTargetable(gBully01, false)
    PedMakeTargetable(gRussell, false)
    PedIgnoreStimuli(gPrefect, true)
    PedAddPedToIgnoreList(gPrefect, gBully01)
    PedAddPedToIgnoreList(gPrefect, gRussell)
    Wait(100)
    PedLockTarget(gPrefect, gPlayer, 3)
    PedSetActionNode(gPlayer, "/Global/1_02/NIS/MeetRussell/Jimmy/Jimmy02", "Act/Conv/1_02.act")
    PedSetActionNode(gRussell, "/Global/1_02/NIS/MeetRussell/Russell/Russell02", "Act/Conv/1_02.act")
    PedSetActionNode(gPrefect, "/Global/1_02/NIS/MeetRussell/Hattrick/Hattrick01", "Act/Conv/1_02.act")
    SoundPlayScriptedSpeechEvent(gPrefect, "M_1_02", 132, "jumbo", true)
    Wait(200)
    PedLockTarget(gPrefect, gPlayer, 3)
    CameraSetXYZ(268.70038, -117.49149, 8.010346, 269.24255, -116.65308, 7.955737)
    while SoundSpeechPlaying(gPrefect) do
        Wait(1)
    end
    SoundPlayScriptedSpeechEvent(gPrefect, "M_1_02", 134, "jumbo", true)
    Wait(7000)
    SoundPlayScriptedSpeechEvent(gPlayer, "M_1_02", 85, "jumbo", true)
    PedFlee(gRussell, gPlayer)
    PedSetActionNode(gPrefect, "/Global/1_02/NIS/MeetRussell/Hattrick/BLANK", "Act/Conv/1_02.act")
    Wait(1500)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(500, 0)
    Wait(500)
    DoublePedShadowDistance(false)
    CameraSetWidescreen(false)
    CameraDefaultFOV()
    Wait(500)
    PedSetActionNode(gPlayer, "/Global/1_02/ShortIdle", "Act/Conv/1_02.act")
    PedSetActionNode(gRussell, "/Global/1_02/ShortIdle", "Act/Conv/1_02.act")
    PedSetActionNode(gPrefect, "/Global/1_02/ShortIdle", "Act/Conv/1_02.act")
    F_MakePlayerSafeForNIS(false)
    DisablePunishmentSystem(false)
    --print("BLAH")
    F_MakePlayerSafeForNIS(false)
    AreaRevertToDefaultPopulation()
    AreaEnableAllPatrolPaths()
    --print("BLOOO")
    SoundSetAudioFocusPlayer()
    PedLockTarget(gPlayer, -1)
    --print("BLOOO!!!!!!")
    PedClearObjectives(gPlayer)
    SoundEnableSpeech_ActionTree()
    --print("POOOOO!!!")
end

function CB_GoToBoysDorm(pedId, pathId, nodeId)
end

function CB_GaryToDorm(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) then
        PedMakeAmbient(gGary)
        gDeleteGary = true
    end
end

function F_SetupRussellFight()
    F_DoCutscene()
    bInTraining = false
    bFoughtRussell = true
    bMonitorRussellEncounter = true
    gMissionState = "passed"
end

function F_WaitForPlayerSoRussellStartsFighting()
    if PlayerIsInTrigger(TRIGGER._1_02_RUSSELTEASE) or bBullyNISLaunched then
        if PedGetHealth(gPlayer) < 150 then
            PedSetHealth(gPlayer, 150)
        end
        bBullyNISLaunched = true
        bCanPush = false
        gTimeRussellStartedHarassing = GetTimer()
        F_CompleteMissionObjective("1_02B_LOGOBJ04")
        F_DoBullyNIS()
        F_TriggerFight()
    end
end

function CB_RussellToWait(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) then
        PedFaceObjectNow(gRussell, gPlayer, 3)
    end
end

function F_StageOne()
    if not bFightingRussell and (PlayerIsInTrigger(TRIGGER._GARYTRIGGER) or bBullyNISLaunched) then
        gMissionUpdateFunction = F_WaitForPlayerSoRussellStartsFighting
    end
end

function F_SetupTowardsDorm()
    if AreaGetVisible() == 0 then
        DisablePOI(true, true)
        bCanPush = false
        bFightingRussell = true
        F_SetupFight()
        gMissionUpdateFunction = F_StageOne
    end
end

function CB_DoneSecretaryDialogue()
    SoundEnableSpeech_ActionTree()
    if shared.gSecretaryID and PedIsValid(shared.gSecretaryID) then
        PedMakeAmbient(shared.gSecretaryID)
    end
    Wait(2000)
    MinigameReleaseCompletion()
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraReturnToPlayer(false)
    CameraReset()
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    F_AddObjectiveBlip("POINT", POINTLIST._INBEDROOM, 2, 1)
    F_AddMissionObjective("1_02B_LOGOBJ04", true)
    BitchModelLoad = false
    PedFollowPath(shared.gSecretaryID, PATH._SECRETARYOFFICEPATH, 2, 0)
    Wait(1500)
    TutorialShowMessage("TUT_RMGL1", 5000, false)
end

function CB_SecKilled()
    if shared.gSecretaryID ~= nil and PedIsValid(shared.gSecretaryID) and PedGetHealth(shared.gSecretaryID) < 0 then
        gMissionState = "fail"
    end
end

function main()
    F_MissionSetup()
    CreateThread("F_MonitorFirstBully")
    CreateThread("F_SetupBoysDormBullies")
    gMissionUpdateFunction = F_SetupTowardsDorm
    F_MakePlayerSafeForNIS(true, false, false, true)
    SoundDisableSpeech_ActionTree()
    shared.gSecretaryID = PedCreatePoint(59, POINTLIST._PRINCIPALROOM, 2)
    gEunice = PedCreatePoint(74, POINTLIST._PRINCIPALROOM, 2)
    PedSetPosPoint(shared.gSecretaryID, POINTLIST._PRINCIPALROOM, 2)
    PedSetPosPoint(gEunice, POINTLIST._1_02_EUNICE, 1)
    PedSetMissionCritical(shared.gSecretaryID, true, CB_SecKilled, true)
    AreaTransitionPoint(2, POINTLIST._PRINCIPALROOM, 1)
    while not shared.gAreaDATFileLoaded[2] do
        Wait(0)
    end
    CameraReturnToPlayer()
    CameraReset()
    while shared.gSecretaryID == nil do
        Wait(0)
    end
    F_DoIntroNIS()
    while gMissionState == "main" do
        Wait(0)
        gMissionUpdateFunction()
        UpdateTextQueue()
    end
    if gMissionState == "passed" then
        MissionSucceed(false, false, false)
    else
        SoundPlayMissionEndMusic(false, 10)
        MissionFail()
    end
end

function F_DoIntroNIS()
    DoublePedShadowDistance(true)
    PedSetFlag(gPlayer, 114, true)
    SoundPreloadSpeech(gPlayer, "NARRATION", 101, "supersize", true)
    CameraSetWidescreen(true)
    CameraReset()
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    PedFollowPath(gEunice, PATH._1_02_EUNICE_WALK, 0, 0)
    CameraSetFOV(70)
    CameraSetPath(PATH._1_02_1CAM_LOGO, true)
    CameraSetSpeed(0.2, 0.2, 0.2)
    CameraLookAtPath(PATH._1_02_1CAM_LOOKAT, true)
    Wait(10)
    CameraFade(500, 1)
    Wait(501)
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 102, "supersize", true)
    Wait(50)
    while SoundSpeechPlaying(gPlayer, "NARRATION", 101) do
        Wait(0)
    end
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    CameraSetPath(PATH._1_02_2CAM_CAF, true)
    CameraSetSpeed(0.3, 0.3, 0.3)
    CameraLookAtPath(PATH._1_02_2CAM_LOOKAT, true)
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 103, "supersize", true)
    Wait(50)
    while SoundSpeechPlaying(gPlayer, "NARRATION", 102) do
        Wait(0)
    end
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    CameraSetPath(PATH._1_02_3CAM_HALL, true)
    CameraSetSpeed(0.3, 0.4, 0.3)
    CameraLookAtPath(PATH._1_02_3CAM_LOOKAT, true)
    SoundPlayPreloadedSpeech()
    Wait(50)
    SoundPreloadSpeech(gPlayer, "NARRATION", 104, "supersize", true)
    Wait(50)
    while SoundSpeechPlaying(gPlayer, "NARRATION", 103) do
        Wait(0)
    end
    Wait(50)
    while not SoundIsSpeechPreloaded() do
        Wait(0)
    end
    PedSetActionNode(shared.gSecretaryID, "/Global/1_02/SecIdle", "Act/Conv/1_02.act")
    CameraSetXYZ(-629.55334, -285.77777, 6.459279, -629.8084, -284.84933, 6.728446)
    SoundPlayPreloadedSpeech()
    Wait(50)
    while SoundSpeechPlaying(gPlayer, "NARRATION", 104) do
        Wait(0)
    end
    Wait(50)
    CameraFade(500, 0)
    Wait(501)
    Wait(50)
    DoublePedShadowDistance(false)
    CameraSetXYZ(-630.0023, -283.6264, 6.978099, -630.286, -284.57684, 6.852377)
    MinigameSetChapterCompletion("Chapt0Message", "Chapt0Reward", true, 0)
    MinigameHoldCompletion()
    Wait(50)
    CameraFade(500, 1)
    Wait(501)
    QueueSoundSpeech(shared.gSecretaryID, "M_1_02", 101, nil, "large")
    QueueSoundSpeech(shared.gSecretaryID, "M_1_02", 123, CB_DoneSecretaryDialogue, "large")
    PedLockTarget(shared.gSecretaryID, gPlayer, 3)
    PedSetActionNode(shared.gSecretaryID, "/Global/1_02/SecStart", "Act/Conv/1_02.act")
    while MinigameIsShowingCompletion() do
        UpdateTextQueue()
        Wait(0)
    end
    F_MakePlayerSafeForNIS(false)
    PedDelete(gEunice)
    DisablePunishmentSystem(false)
    PedSetFlag(gPlayer, 114, false)
end

local gObjectiveBlip

function F_RemoveObjectiveBlip()
    if gObjectiveBlip ~= nil then
        BlipRemove(gObjectiveBlip)
        Wait(100)
        gObjectiveBlip = nil
    end
end

function F_AddObjectiveBlip(blipType, point, index, blipEnum)
    F_RemoveObjectiveBlip()
    if gObjectiveBlip == nil then
        if blipType == "POINT" then
            Wait(100)
            local x, y, z = GetPointFromPointList(point, index)
            gObjectiveBlip = BlipAddXYZ(x, y, z + 0.1, 0, blipEnum)
        elseif blipType == "CHAR" and not PedIsDead(point) then
            Wait(100)
            gObjectiveBlip = AddBlipForChar(point, index, 0, blipEnum)
        end
    end
end

function F_SetupFinalFightPed(ped)
    PedSetAsleep(ped, true)
    PedSetStationary(ped, true)
    PedLockTarget(ped, gPlayer, 3)
    PedSetInvulnerable(ped, true)
    PedMakeTargetable(ped, false)
    PedIgnoreStimuli(ped, true)
    PedSetEffectedByGravity(ped, true)
    PedSetPedToTypeAttitude(ped, 11, 2)
    PedSetActionNode(ped, "/Global/1_02/Talking/Talk", "Act/Conv/1_02.act")
end

function F_SetupFinalFightTable(table)
    for i, ped in table do
        F_SetupFinalFightPed(ped)
    end
end

function F_StartCheeringPed(ped)
    PedSetActionNode(ped, "/Global/1_02/ShortIdle", "Act/Conv/1_02.act")
    PedSetCheering(ped, true)
    PedSetTaskNode(ped, "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
end

function F_StartCheeringTable(table)
    for i, ped in table do
        F_StartCheeringPed(ped)
    end
end

function F_RestorePed(ped, flee)
    if PedIsValid(ped) then
        PedSetEffectedByGravity(ped, true)
        PedSetCheering(ped, false)
        PedSetActionNode(ped, "/Global/1_02/ShortIdle", "Act/Conv/1_02.act")
        PedSetTaskNode(ped, "/Global/AI", "Act/AI/AI.act")
        PedSetCheap(ped, false)
        PedMakeTargetable(ped, true)
        PedSetStationary(ped, false)
        PedSetAsleep(ped, false)
        PedRemoveStimulus(ped, 5)
        PedClearObjectives(ped)
        PedMakeAmbient(ped)
        PedSetInvulnerable(ped, false)
        PedClearHasAggressed(ped)
        PedIgnoreStimuli(ped, false)
        if bFlee then
            PedWander(ped, 0)
        end
    end
end

function F_RestorePeds(table, bFlee)
    for i, ped in table do
        if PedIsValid(ped) then
            F_RestorePed(ped, flee)
        end
    end
end

function F_SetupTrainingFightPed(ped)
    PedSetAsleep(ped, true)
    PedSetStationary(ped, true)
    PedLockTarget(ped, gPlayer, 3)
    PedSetInvulnerable(ped, true)
    PedMakeTargetable(ped, false)
    PedIgnoreStimuli(ped, true)
    PedSetEffectedByGravity(ped, true)
    PedSetPedToTypeAttitude(ped, 11, 2)
    PedSetActionNode(ped, "/Global/1_02/Talking/Talk", "Act/Conv/1_02.act")
end

function F_SetupFight()
    bFightingRussell = false
    gPreviousPlayerHealth = PedGetHealth(gPlayer)
    gPreviousRussellHealth = 200
end

function F_RussellStop()
    if gRussell and PedIsValid(gRussell) then
        PedIgnoreStimuli(gPrefect, false)
        PedMakeAmbient(gRussell)
        PedStop(gRussell)
        PedClearObjectives(gRussell)
        PedSetAsleep(gRussell, false)
        PedSetStationary(gRussell, false)
        PedSetTaskNode(gRussell, "/Global/AI", "Act/AI/AI.act")
        PedRemoveStimulus(gRussell, 5)
        PedWander(gRussell, 0)
    end
end

function CB_Point(text)
    if text == "Hey you two, break it up!" then
        AreaDeactivatePopulationTrigger(TRIGGER._1_02_POPULATIONTRIG)
        if gRussell and PedIsValid(gRussell) then
            PedFaceObject(gPrefect, gRussell, 2, 0)
            Wait(10)
        end
        PedSetActionNode(gPrefect, "/Global/1_02/PointAtRussel", "Act/Conv/1_02.act")
    elseif text == "And you, go into the dorm and change into your uniform!" then
        F_RussellStop()
        PedFaceObject(gPrefect, gPlayer, 2, 0)
        Wait(10)
        PedSetActionNode(gPrefect, "/Global/1_02/PointAtPlayer", "Act/Conv/1_02.act")
        if gRussell and PedIsValid(gRussell) then
            PedLockTarget(gPrefect, gRussell, 3)
        end
    else
        F_AddObjectiveBlip("POINT", POINTLIST._INBEDROOM, 2, 1)
        TextPrint("1_02B_LOGOBJ04", 4, 1)
    end
end

function CB_PrefPathFollow(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) then
        QueueTextString("Hey you two, break it up!", 4, 2, false, CB_Point)
        QueueTextString("And you, go into the dorm and change into your uniform!", 3, 2, false, CB_Point)
        QueueTextString("", 0.1, 2, false, CB_Point)
        PedMakeAmbient(gPrefect)
    end
end

function F_SendInThePrefects()
    bMonitorRussellEncounter = false
    gPrefect = PedCreatePoint(51, POINTLIST._1_02_NISLOCATIONS, 3)
    PedIgnoreStimuli(gPrefect, true)
    F_RestorePeds(gBlockersT, true)
end

function F_UpdatePopulation()
    local visibleArea = AreaGetVisible()
    if gVisibleArea ~= 0 and visibleArea == 0 then
        AreaActivatePopulationTrigger(TRIGGER._1_02_SCHOOLTRIG)
        gVisibleArea = visibleArea
    elseif gVisibleArea ~= 2 and visibleArea == 2 then
        AreaRevertToDefaultPopulation()
        gVisibleArea = visibleArea
    end
end

function F_RussellGrappledPlayer()
    bRussellHumiliatedPlayer = true
end

local gBlockers1 = {}
local gBlockers2 = {}
local gBlockers3 = {}
local gBlockers4 = {}
local gPrefect, gRussell
local bCanPush = false
local bMonitorRussellEncounter = true
local bFightingRussell = false
local gPreviousPlayerHealth = 0
local gPreviousRussellHealth = 0

function F_MonitorFirstBully()
    local x, y, z = GetPointFromPointList(POINTLIST._1_02_FIRSTSET, 1)
    while not PlayerIsInAreaXYZ(x, y, z, 40, 0) do
        Wait(0)
    end
    table.insert(gBlockers1, PedCreatePoint(99, POINTLIST._1_02_FIRSTSET, 1))
    table.insert(gBlockers1, PedCreatePoint(145, POINTLIST._1_02_FIRSTSET, 3))
    PedSetPedToTypeAttitude(gBlockers1[1], 6, 1)
    PedSetPedToTypeAttitude(gBlockers1[2], 6, 1)
    while true do
        Wait(0)
        if PlayerIsInAreaObject(gBlockers1[2], 2, 6, 0) then
            Wait(150)
            PedFaceObject(gBlockers1[1], gPlayer, 3, 1)
            PedSetPedToTypeAttitude(gBlockers1[1], 13, 2)
            PedSetEmotionTowardsPed(gBlockers1[1], gPlayer, 3, true)
            PedSetWantsToSocializeWithPed(gBlockers1[1], gPlayer)
            PedFaceObject(gBlockers1[2], gPlayer, 3, 1)
            PedSetPedToTypeAttitude(gBlockers1[2], 13, 2)
            PedSetEmotionTowardsPed(gBlockers1[2], gPlayer, 2, true)
            PedSetWantsToSocializeWithPed(gBlockers1[2], gPlayer)
            PedMakeAmbient(gBlockers1[1])
            PedMakeAmbient(gBlockers1[2])
            PedLockTarget(gBlockers1[2], -1)
            PedLockTarget(gBlockers1[2], -1)
            break
        else
            PedLockTarget(gBlockers1[1], gPlayer, 3)
            PedLockTarget(gBlockers1[2], gPlayer, 3)
        end
        if gMissionUpdateFunction == F_SetupRussellFight then
            PedMakeAmbient(gBlockers1[1])
            PedMakeAmbient(gBlockers1[2])
        end
    end
end

function F_SetupBoysDormBullies()
    local x, y, z = GetPointFromPointList(POINTLIST._1_02_BDORMBULLIES, 1)
    while not PlayerIsInAreaXYZ(x, y, z, 40, 0) do
        Wait(0)
    end
    gBully01 = PedCreatePoint(85, POINTLIST._1_02_BDORMBULLIES, 1)
    gBully02 = PedCreatePoint(102, POINTLIST._1_02_BDORMBULLIES, 2)
    gBully03 = PedCreatePoint(146, POINTLIST._1_02_BDORMBULLIES, 3)
    local x, y, z = GetPointFromPointList(POINTLIST._1_02_RUSSELLNIS, 2)
    PedFaceXYZ(gBully01, x, y, z, 0)
    PedFaceXYZ(gBully02, x, y, z, 0)
    PedFaceXYZ(gBully03, x, y, z, 0)
    PedSetActionNode(gBully01, "/Global/1_01/Talking", "Act/Conv/1_01.act")
    PedSetActionNode(gBully02, "/Global/1_01/Talking", "Act/Conv/1_01.act")
    PedSetActionNode(gBully03, "/Global/1_01/Talking", "Act/Conv/1_01.act")
    CreateThread("T_MonitorBullies")
    PedSetAsleep(gBully01, true)
    PedSetAsleep(gBully02, true)
    PedSetAsleep(gBully03, true)
end

function F_FireBullyNIS()
    --print("BEING CALLED!!")
    if not bBullyNISLaunched then
        bBullyNISLaunched = true
    end
end

function F_DoBullyNIS()
    PlayerSetControl(0)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    AreaSetDoorLocked("DT_TSCHOOL_BOYSDORML", true)
    CameraFade(500, 0)
    Wait(500)
    if shared.gSecretaryID and PedIsValid(shared.gSecretaryID) then
        PedSetMissionCritical(shared.gSecretaryID, false)
        PedDelete(shared.gSecretaryID)
        shared.gSecretaryID = nil
    end
    bBullyNISLaunched = true
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    if PedIsOnVehicle(gPlayer) then
        PlayerDetachFromVehicle()
    end
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaDisableAllPatrolPaths()
    AreaClearAllPeds()
    AreaClearAllVehicles()
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerWeaponHudLock(true)
    ObjectRemovePickupsInTrigger(TRIGGER._1_02_POPULATIONTRIG)
    PlayerSetPosPoint(POINTLIST._1_02_PLAYERNISLOCS, 1)
    table.insert(gPushers, PedCreatePoint(99, POINTLIST._1_02_BULLIESMID, 2))
    table.insert(gPushers, PedCreatePoint(145, POINTLIST._1_02_BULLIESMID, 3))
    PedIgnoreStimuli(gPushers[1], true)
    PedIgnoreStimuli(gPushers[2], true)
    PedFaceObject(gPlayer, gPushers[1], 2, 0)
    PedDelete(gBully01)
    PedDelete(gBully02)
    PedDelete(gBully03)
    gBully01 = PedCreatePoint(85, POINTLIST._1_02_BDORMBULLIES, 1)
    gBully02 = PedCreatePoint(102, POINTLIST._1_02_BDORMBULLIES, 2)
    gBully03 = PedCreatePoint(146, POINTLIST._1_02_BDORMBULLIES, 3)
    PedIgnoreStimuli(gBully01, true)
    PedIgnoreStimuli(gBully02, true)
    PedIgnoreStimuli(gBully03, true)
    CameraSetWidescreen(true)
    CameraSetXYZ(272.01678, -103.932014, 7.784328, 271.86807, -104.918785, 7.722927)
    Wait(1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(500, 1)
    CameraSetFOV(30)
    Wait(200)
    F_NISBullyCore()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    CameraFade(500, 0)
    Wait(500)
    if SoundSpeechPlaying(gBully01) then
        SoundStopCurrentSpeechEvent(gBully01)
    end
    if SoundSpeechPlaying(gBully02) then
        SoundStopCurrentSpeechEvent(gBully02)
    end
    if SoundSpeechPlaying(gBully03) then
        SoundStopCurrentSpeechEvent(gBully03)
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PedDelete(gBully01)
    PedDelete(gBully02)
    PedDelete(gBully03)
    for i, ped in gPushers do
        PedDelete(ped)
    end
    gPushers = {}
    gBully01 = PedCreatePoint(146, POINTLIST._1_02_PLAYERNISLOCS, 2)
    gBully02 = PedCreatePoint(102, POINTLIST._1_02_BULLIESMID, 1)
    gBully03 = PedCreatePoint(85, POINTLIST._1_02_BULLIESMID, 2)
    table.insert(gPushers, PedCreatePoint(99, POINTLIST._1_02_BULLIESMID, 3))
    table.insert(gPushers, PedCreatePoint(145, POINTLIST._1_02_BULLIESMID, 4))
    PlayerSetPosPoint(POINTLIST._1_02_PLAYERNISLOCS, 1)
    PedFaceObject(gPlayer, gBully01, 2, 0)
    F_SetupTrainingFightPed(gBully02)
    F_SetupTrainingFightPed(gBully03)
    F_StartCheeringPed(gBully02)
    F_StartCheeringPed(gBully03)
    F_SetupTrainingFightPed(gPushers[1])
    F_SetupTrainingFightPed(gPushers[2])
    F_StartCheeringPed(gPushers[1])
    F_StartCheeringPed(gPushers[2])
    CameraSetWidescreen(false)
    CameraReset()
    CameraSetXYZ(269.5932, -102.982864, 7.619021, 270.05994, -103.86416, 7.545108)
    Wait(1)
    CameraReturnToPlayer(false)
    Wait(50)
    F_MakePlayerSafeForNIS(false)
    PedSetActionTree(gPlayer, "/Global/TrainingPlayer", "Act/TrainingPlayer.act")
    Gate102PoolIndex, Gate102Entity = CreatePersistentEntity("1_02Gate", Gate102Pos[1], Gate102Pos[2], Gate102Pos[3], Gate102Pos[4], 0)
    GeometryInstance("1_02Gate", true, Gate102Pos[1], Gate102Pos[2], Gate102Pos[3], true)
    bPushPlayer = false
end

function F_NISBullyCore()
    PedSetActionNode(gPlayer, "/Global/1_02/NIS/PLAYER_BULLIES/PLAYER01", "Act/Conv/1_02.act")
    PedSetActionNode(gBully01, "/Global/1_02/TauntPlayer/Taunt01", "Act/Conv/1_02.act")
    PedSetActionNode(gBully02, "/Global/1_02/TauntPlayer/Taunt03", "Act/Conv/1_02.act")
    PedSetActionNode(gBully03, "/Global/1_02/TauntOnce", "Act/Conv/1_02.act")
    SoundPlayScriptedSpeechEvent(gBully03, "M_1_02", 34, "large")
    Wait(1500)
    local bSkip = false
    while not (not SoundSpeechPlaying() or bSkip) do
        bSkip = WaitSkippable(1)
    end
    if bSkip then
        return
    end
    CameraSetFOV(30)
    CameraSetXYZ(271.4686, -107.84492, 7.986414, 271.4614, -106.85376, 7.856282)
    PedSetActionNode(gPushers[2], "/Global/1_02/TauntPlayer/Taunt04", "Act/Conv/1_02.act")
    PedSetActionNode(gPushers[1], "/Global/1_02/TauntPlayer/Taunt03", "Act/Conv/1_02.act")
    if F_PlaySpeechWait(gPushers[1], "M_1_02", 33, "large") then
        return
    end
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    local skip = false
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while not (not SoundSpeechPlaying() or skip) do
            skip = WaitSkippable(1)
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while not (not SoundSpeechPlaying() or skip) do
            skip = WaitSkippable(1)
        end
    end
    return skip
end

function F_HealthTutorial()
    if bBullyNISLaunched then
        return 0
    end
    return 1
end

local bShowHumiliationTutorial = false

function F_MonitorTraining2()
    F_CheeringSpeech()
    if PedGetHealth(gBully01) == 5 then
        if not bShowHumiliationTutorial then
            bCanBullyLaunchAttacks = false
            F_CompleteMissionObjective("1_02_FightMsg")
            F_AddMissionObjective("1_02_HumiliateHim", true)
            Wait(1000)
            TutorialStart("HUMILIATEX")
            bInTraining = false
            bShowHumiliationTutorial = true
            CameraAllowChange(true)
        end
        if PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/Humiliate_Me/5-8_IndianBurn", true) or PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/Humiliate_Me/5-8_HitSelf", true) or PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/Humiliate_Me/5-8_NoogieSpit", true) or PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/WaitForVictim/EmergencyAnim", true) then
            PedClearTether(gBully01)
            TutorialRemoveMessage()
            PlayerSetControl(0)
            PedSetMinHealth(gBully01, -1)
            while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/Humiliate_Me/5-8_IndianBurn", true) or PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/Humiliate_Me/5-8_HitSelf", true) or PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/Humiliate_Me/5-8_NoogieSpit", true) or PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations/Humiliate_Init/WaitForVictim/EmergencyAnim", true) do
                Wait(0)
            end
            while PedGetHealth(gBully01) > 0 do
                Wait(0)
            end
            while not PedIsPlaying(gBully01, "/Global/HitTree/KnockOuts", true) do
                Wait(0)
            end
            DisablePunishmentSystem(false)
            Wait(1500)
            SoundFadeWithCamera(false)
            MusicFadeWithCamera(false)
            CameraFade(500, 0)
            Wait(501)
            bPushPlayer = false
            PedLockTarget(gPlayer, -1)
            ToggleHUDComponentVisibility(21, false)
            F_SetupRussellFight()
        end
    end
end

function T_MonitorBullyHealth()
    while gMissionUpdateFunction ~= F_MonitorTraining1 do
        Wait(0)
    end
    while gMissionUpdateFunction == F_MonitorTraining1 do
        if PedGetHealth(gBully01) < gOriginalBullyHealth / 2 then
            PedSetHealth(gBully01, gOriginalBullyHealth / 2)
        end
        Wait(0)
    end
end

local bIsBlocking = false
local bStayInPosition = false

function F_MonitorTraining1()
    local L0 = false
    F_CheeringSpeech()
    if gCurrentPlayerMove == 1 then
        if PedIsPlaying(gPlayer, "/Global/HitTree/Standing/BlockHits", true) then
            gCurrentCombo = gCurrentCombo + 1
            gSequencePassed = false
            L36_1 = false
            if 2 <= gCurrentCombo then
                gCurrentCombo = 1
                L0 = true
                Wait(500)
                ToggleHUDComponentVisibility(21, false)
                while PedIsPlaying(gPlayer, "/Global/HitTree/Standing/BlockHits", true) do
                    Wait(0)
                end
                Wait(500)
            else
                Wait(500)
                ToggleHUDComponentVisibility(21, false)
                while PedIsPlaying(gPlayer, "/Global/HitTree/Standing/BlockHits", true) do
                    Wait(0)
                end
                Wait(500)
                F_SetSequence({ 10, true }, "1_02_R1but")
            end
        else
            if not bIsBlocking and PedMePlaying(gPlayer, "0_BLOCK_0", true) then
                bIsBlocking = true
            else
                if bIsBlocking then
                    if not PedMePlaying(gPlayer, "0_BLOCK_0", true) then
                        bIsBlocking = false
                        F_SetSequence({ 10, true }, "1_02_R1but")
                    end
                end
            end
        end
    elseif gCurrentPlayerMove == 2 then
        if gSequencePassed then
            gCurrentCombo = gCurrentCombo + 1
            gSequencePassed = false
            L36_1 = false
            if 3 <= gCurrentCombo then
                gCurrentCombo = 1
                L0 = true
                Wait(500)
                ToggleHUDComponentVisibility(21, false)
                Wait(500)
            else
                Wait(500)
                ToggleHUDComponentVisibility(21, false)
                Wait(500)
                F_SetSequence({ 6, false, 6, false, 6, false }, "1_02_Xbut", false)
            end
        end
    elseif gCurrentPlayerMove == 3 then
        if PedIsPlaying(gPlayer, "/Global/TrainingPlayer/Default", true) then
            if gSequencePassed then
                F_SetSequence({ 9, false }, "1_02_TBut1", true)
            end
        elseif PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/GrappleAttempt/GrappleSuccess/GIVE", false) and gSequencePassed then
            gCurrentCombo = gCurrentCombo + 1
            gSequencePassed = false
            L36_1 = false
            gCurrentCombo = 1
            gCurrentPlayerMove = 4
            bGrapplePunches = true
            F_SetSequence({ 6, false, 6, false, 6, false }, "1_02_GrapplePunch", true)
        end
        Wait(0)
    elseif gCurrentPlayerMove == 4 then
        if gSequencePassed or PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/GrappleMoves/GrappleStrikes/HitC/Charge", true) then
            gCurrentCombo = gCurrentCombo + 1
            gSequencePassed = false
            L36_1 = false
            if 1 <= gCurrentCombo then
                gCurrentCombo = 1
                gCurrentPlayerMove = 4
                L0 = true
                bGrapplePunches = false
            end
        elseif not PedIsPlaying(gBully01, "/Global/Actions/Grapples/Front/Grapples", true) then
            gCurrentPlayerMove = 3
            gCurrentCombo = 1
            bGrapplePunches = false
            F_SetSequence({ 9, false }, "1_02_TBut1", true)
        end
    elseif gCurrentPlayerMove == 5 then
        if PedIsPlaying(gPlayer, "/Global/TrainingPlayer/Default", true) then
            if gSequencePassed then
                F_SetSequence({ 9, false }, "1_02_TBut1", true)
            end
        else
            if (PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/GrappleAttempt/GrappleSuccess/GIVE", false) or PedIsPlaying(gPlayer, "/Global/Actions/Grapples/Front/Grapples/GrappleMoves/GrappleStrikes/Punch_Hold_Idle", true)) and gSequencePassed then
                gCurrentCombo = gCurrentCombo + 1
                gSequencePassed = false
                L36_1 = false
                gCurrentCombo = 1
                gCurrentPlayerMove = 6
                F_SetSequence({ 9, false }, "1_02_TBut2", true)
            end
        end
    elseif gCurrentPlayerMove == 6 then
        if PedIsPlaying(gBully01, "/Global/Actions/Grapples/Front/Grapples/GrappleMoves/DirectionalPush/PushFwd/RCV", false) then
            Wait(1000)
            gCurrentCombo = gCurrentCombo + 1
            gSequencePassed = false
            L36_1 = false
            bGroundKicks = true
            gCurrentCombo = 1
            gCurrentPlayerMove = 7
            bStayInPosition = false
            F_SetSequence({ 6, false }, "1_02_GroundKicks", true)
        elseif not PedIsPlaying(gBully01, "/Global/Actions/Grapples/Front/Grapples", true) then
            gCurrentPlayerMove = 5
            gCurrentCombo = 1
            bGrappleAttacks = true
            bGroundKicks = false
            F_SetSequence({ 9, false }, "1_02_TBut1", true)
        end
    elseif gCurrentPlayerMove == 7 then
        if not bStayInPosition then
            if PedIsPlaying(gBully01, "/Global/HitTree/Standing/PostHit/SitOnWall/DownOnGround/Sit", false) then
                PedSetActionNode(gBully01, "/Global/1_02/SitOnWall", "Act/Conv/1_02.act")
                bGroundKicks = true
                bStayInPosition = true
            elseif PedIsPlaying(gBully01, "/Global/HitTree/Standing/PostHit/BellyUp/On_Ground", true) then
                PedSetActionNode(gBully01, "/Global/1_02/On_Ground", "Act/Conv/1_02.act")
                bStayInPosition = true
            end
        end
        if gSequencePassed then
            Wait(100)
            if PedIsPlaying(gPlayer, "/Global/TrainingPlayer/Attacks/GroundAttacks/GroundAttacks/Strikes/HeavyAttacks", true) then
                while PedIsPlaying(gPlayer, "/Global/TrainingPlayer/Attacks/GroundAttacks/GroundAttacks/Strikes/HeavyAttacks", true) do
                    Wait(0)
                    if PedIsPlaying(gBully01, "/Global/HitTree/GroundAndWallHits/On_Ground/BellyUp/GroundHitHeavy/GroundHitHeavy", true) or PedIsPlaying(gBully01, "/Global/HitTree/GroundAndWallHits/On_Ground/BellyUp/RollAway", false) or PedIsPlaying(gBully01, "/Global/HitTree/GroundAndWallHits", true) then
                        gSequencePassed = false
                        L36_1 = false
                        gCurrentCombo = 1
                        gCurrentPlayerMove = 7
                        L0 = true
                        break
                    end
                end
                if not L0 then
                    gCurrentCombo = 1
                    gSequencePassed = false
                    L36_1 = false
                    bGroundKicks = true
                    gCurrentCombo = 1
                    gCurrentPlayerMove = 7
                    bStayInPosition = false
                    F_SetSequence({ 6, false }, "1_02_GroundKicks", true)
                end
            end
        elseif not PedIsPlaying(gBully01, "/Global/HitTree/GroundAndWallHits/On_Ground", true) and not PedIsPlaying(gBully01, "/Global/Actions/Grapples/Front/Grapples/", true) and not PedIsPlaying(gBully01, "/Global/HitTree/Standing/WallHits", true) and not PedIsPlaying(gBully01, "/Global/HitTree/Standing/PostHit/BellyUp", true) and not PedIsPlaying(gBully01, "/Global/1_02", true) and not PedIsPlaying(gBully01, "/Global/HitTree/GroundAndWallHits", true) then
            gCurrentPlayerMove = 5
            gCurrentCombo = 1
            bGrappleAttacks = true
            bGroundKicks = false
            F_SetSequence({ 9, false }, "1_02_TBut1", true)
        end
    end
    if L0 then
        if gCurrentPlayerMove == 1 then
            bIgnoreR1 = true
            bLightAttacks = true
            GameSetPedStat(gBully01, 12, 50)
            F_SetSequence({ 6, false, 6, false, 6, false }, "1_02_Xbut", false)
            bCanBullyLaunchAttacks = false
        elseif gCurrentPlayerMove == 2 then
            bGrappleAttacks = true
            F_SetSequence({ 9, false }, "1_02_TBut1", false)
        elseif gCurrentPlayerMove == 4 then
            gSequencePassed = false
            L36_1 = false
            gCurrentCombo = 1
            gCurrentPlayerMove = 5
            bGrappleAttacks = true
            F_SetSequence({ 9, false }, "1_02_TBut2", true)
        elseif gCurrentPlayerMove == 7 then
            ToggleHUDComponentVisibility(21, false)
            ButtonHistoryClearSequence()
            F_AddMissionObjective("1_02_FightMsg", true)
            MissionObjectiveReminderTime(1000000000)
            PedSetMinHealth(gBully01, 5)
            GameSetPedStat(gBully01, 8, 100)
            bCreateCrowd = true
            bFinalStage = true
            gMissionUpdateFunction = F_MonitorTraining2
        end
        gCurrentPlayerMove = gCurrentPlayerMove + 1
    end
    if not PlayerIsInTrigger(TRIGGER._1_02_FightArea) then
        gMissionState = "fail"
    end
end


function F_TriggerFight()
    if table.getn(gObjectives) > 0 then
        MissionObjectiveComplete(gObjectives[table.getn(gObjectives)])
    end
    bCanPush = false
    bPushPlayer = true
    DisablePunishmentSystem(true)
    ToggleHUDComponentVisibility(4, false)
    ToggleHUDComponentVisibility(11, false)
    ToggleHUDComponentVisibility(0, false)
    PedDelete(gBully01)
    gBully01 = PedCreatePoint(146, POINTLIST._1_02_PLAYERNISLOCS, 2)
    PedSetActionNode(gBully01, "/Global/1_02/ShortIdle", "Act/Conv/1_02.act")
    PedSetPedToTypeAttitude(gBully01, 13, 0)
    PedSetTetherToXYZ(gBully01, 271.3, -108.2, 6.2, 5)
    PedSetTetherMoveToCenter(gBully01, true)
    PedSetActionTree(gBully01, "/Global/Fight_Tutorial", "Act/Anim/Fight_Tutorial.act")
    PedSetAITree(gBully01, "/Global/AI_FightTutorial", "Act/AI/AI_FightTutorial.act")
    PedLockTarget(gPlayer, gBully01, 3)
    PedLockTarget(gBully01, gPlayer, 3)
    PedFaceObject(gPlayer, gBully01, 2, 1)
    PedFaceObject(gBully01, gPlayer, 2, 1)
    PedSetCombatZoneMask(gBully01, true, true, false)
    PlayerSocialDisableActionAgainstPed(gBully01, 28, true)
    GameSetPedStat(gBully01, 12, 40)
    GameSetPedStat(gBully01, 8, 100)
    GameSetPedStat(gBully01, 38, 0)
    GameSetPedStat(gBully01, 39, 0)
    PedSetInvulnerableToPlayer(gBully01, false)
    PlayerSetInvulnerable(true)
    SoundEnableSpeech_ActionTree()
    CameraFade(500, 1)
    Wait(500)
    PlayerSetControl(1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    PedClearObjectives(gBully01)
    PedAttack(gBully01, gPlayer, 3)
    if PedGetHealth(gPlayer) < 150 then
        PedSetHealth(gPlayer, 150)
    end
    bInTraining = true
    gOriginalBullyHealth = PedGetHealth(gBully01)
    gPlayerHealth = PedGetHealth(gPlayer)
    gTimeRussellStartedHarassing = GetTimer()
    ButtonHistoryIgnoreController(false)
    ToggleHUDComponentVisibility(21, true)
    PedSetMinHealth(gBully01, 75)
    F_SetSequence({ 10, true }, "1_02_R1but")
    ButtonHistorySetSequenceTime(10)
    Wait(1000)
    CreateThread("T_StartFightTut")
    bCanBullyLaunchAttacks = true
    gMissionUpdateFunction = F_MonitorTraining1
end

function T_StartFightTut()
    TutorialShowMessage("1_02_FightTut", 3500, false)
    Wait(4000)
    TutorialShowMessage("TUT_TARGET01", 4000, false)
    collectgarbage()
end

function F_SetSequence(buttonTbl, captioning, bGrapple)
    if not bGrapple or bGrapple == nil then
        while not PedIsPlaying(gPlayer, "/Global/TrainingPlayer/Default", true) do
            Wait(0)
            --print("F_SetSequence false")
        end
    end
    ButtonHistoryClearSequence()
    ButtonHistoryIgnoreController(true)
    ToggleHUDComponentVisibility(21, true)
    if bIgnoreR1 then
        ButtonHistoryIgnoreSequence(16, 17, 20, 21, 10, 11, 12, 13, 8, 7, 14)
    else
        ButtonHistoryIgnoreSequence(16, 17, 20, 21, 11, 12, 13, 8, 7, 14)
    end
    ButtonHistorySetCallbackPassed(F_PassedCallback)
    ButtonHistorySetCallbackFailed(F_FailedCallback)
    ButtonHistorySetCallbackCorrectButton(F_CorrectButtonPressed)
    if table.getn(buttonTbl) == 6 then
        --print("Setting 3 buttons!")
        --DebugPrint("************WMW - timeOutDelay is: " .. timeOutDelay) --Now it's always 30
        ButtonHistoryAddSequenceTimeInterval(buttonTbl[1], buttonTbl[2], 30, buttonTbl[3], buttonTbl[4], 30, buttonTbl[5], buttonTbl[6], 30)
    elseif table.getn(buttonTbl) == 4 then
        --print("Setting 2 buttons!")
        --DebugPrint("************WMW - timeOutDelay is: " .. timeOutDelay)
        ButtonHistoryAddSequence(buttonTbl[1], buttonTbl[2], buttonTbl[3], buttonTbl[4])
    elseif table.getn(buttonTbl) == 2 then
        --print("Setting 1 button!")
        --DebugPrint("************WMW - timeOutDelay is: " .. timeOutDelay) --Now it's always 1000000
        if gCurrentPlayerMove == 1 then
            ButtonHistoryAddSequenceTimeInterval(buttonTbl[1], buttonTbl[2], 1000000)
        else
            ButtonHistoryAddSequenceTimeInterval(buttonTbl[1], buttonTbl[2], 1000000)
        end
    end
    ButtonHistoryIgnoreController(false)
    ButtonHistorySetSequenceTime(5000)
    ButtonHistoryAddSequenceLocalText(captioning)
end

function F_CanBlock()
    if math.random(1, 100) > 80 then
        return 1
    end
    return 0
end

function F_CanBullyAttack()
    if bCanBullyLaunchAttacks then
        return 1
    end
    return 0
end

function T_PushPlayer()
    collectgarbage()
end

function F_PushPlayerAway(table)
end

function F_PlayerGrapple()
    if bGrappleAttacks or bFinalStage then
        return 1
    end
    return 0
end

function F_PlayerSloppyAttacks()
    if bLightAttacks or bFinalStage then
        return 1
    end
    return 0
end

function F_PlayerHeavyAttacks()
    if bHeavyAttacks or bFinalStage then
        return 1
    end
    return 0
end

function F_PlayerGroundKicks()
    --print("WTF????")
    if bGroundKicks or bFinalStage then
        --print("YEAAAAHH!!!!")
        return 1
    end
    --print("WJNKDFDSJFNSDKJFNSDFJNKJN!!!")
    return 0
end

function F_BulliesCanPush()
    if bPushPlayer then
        --print("bullies can push!")
        return 1
    end
    return 0
end

function F_GrapplePunches()
    if bGrapplePunches or bFinalStage then
        return 1
    end
    return 0
end

function F_FinalAttacks()
    if bFinalStage then
        return 1
    end
    return 0
end

function F_FailedCallback(button)
    SoundPlay2D("WrongBtn")
end

function F_PassedCallback(button)
    gSequencePassed = true
    SoundPlay2D("RightBtn")
    --print("SDIFMSDKFS!")
end

function F_PlayerIsTraining()
    if bInTraining then
        return 1
    end
    return 0
end

local tObjectiveTable = {}

function F_ObjectiveAlreadyGiven(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            return true
        end
    end
    return false
end

function F_ObjectiveAlreadyComplete(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            return objective.bComplete
        end
    end
    return false
end

function F_RemoveMissionObjective(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            MissionObjectiveRemove(objective.id)
            table.remove(tObjectiveTable, i)
        end
    end
end

function F_CompleteMissionObjective(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            MissionObjectiveComplete(objective.id)
            objective.bComplete = true
        end
    end
end

function F_AddMissionObjective(reference, bPrint)
    if F_ObjectiveAlreadyGiven(reference) then
        for i, objective in tObjectiveTable do
            if objective.ref == reference then
                return objective.id
            end
        end
    end
    if bPrint then
        TextPrint(reference, 3, 1)
    end
    local objId = MissionObjectiveAdd(reference)
    table.insert(tObjectiveTable, {
        id = objId,
        ref = reference,
        bComplete = false
    })
    return objId
end

function T_MonitorBullies()
    while not bBullyNISLaunched do
        if gBully01 and PedIsValid(gBully01) and PedGetWhoHitMeLast(gBully01) == gPlayer or gBully02 and PedIsValid(gBully02) and PedGetWhoHitMeLast(gBully02) == gPlayer or gBully03 and PedIsValid(gBully03) and PedGetWhoHitMeLast(gBully03) == gPlayer then
            --print("GET THE NEW KID!!")
            F_FireBullyNIS()
            break
        end
        Wait(100)
    end
    collectgarbage()
end

function F_WaitForSpeech()
    while SoundSpeechPlaying() do
        Wait(0)
    end
end

function F_CheeringSpeech()
    local ped = 0
    if pLastPed == nil or not SoundSpeechPlaying(pLastPed) then
        ped = math.random(1, 4)
        if ped == 1 then
            SoundPlayScriptedSpeechEvent(gBully02, "FIGHT_WATCH", 0, "large")
            pLastPed = gBully02
        elseif ped == 2 then
            SoundPlayScriptedSpeechEvent(gBully03, "FIGHT_WATCH", 0, "large")
            pLastPed = gBully03
        elseif ped == 3 then
            SoundPlayScriptedSpeechEvent(gPushers[1], "FIGHT_WATCH", 0, "large")
            pLastPed = gPushers[1]
        else
            SoundPlayScriptedSpeechEvent(gPushers[2], "FIGHT_WATCH", 0, "large")
            pLastPed = gPushers[2]
        end
    end
end
