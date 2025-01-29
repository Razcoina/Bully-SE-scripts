ImportScript("Library/LibTable.lua")
ImportScript("Library/LibTrigger.lua")
ImportScript("Library/LibSchool.lua")
local gMissionAlreadyExecuted = false
local gTimeRussellStartedHarassing = 0
local gRussellPushed = false
local gEndBlip
local gPrefectReachedPathEnd = false
local bRussellThreatenedPlayer = false
local gSecretary, gVisibleArea
local bDoneHarassing = false
local bLastGuysSpanwed = false
local bPoiFired = false
local eX, eY, eZ
local gOriginalBullyHealth = 0
local gPlayerHealth = 0
local gBully01, gBully02
local gPushers = {}
local gTargetNumber
local gCurrentCombo = 1
local gCurrentPlayerMove = 1
local gMoveLanded = false
local gOriginalHealth = 0
local gLastTimeCheckedHit = 0
local bCanBullyLaunchAttacks = false
local bManageCrowd = true
local bCreateCrowd = false
local gCrowd = {}
local gSequencePassed = false
local gSequenceFailed = false
local gButtonCorrect = false
local bShowedTutorial = false
local bShowedIntroTutorial = false
local nTimesBusted = 0
local bObjectiveTutorial = false
local gPedro, gPedroBully
local bPedroBeingChased = false
local bPedroCleaned = false
local numBully01 = 0
local numBully02 = 0
local numBully03 = 0
local numBully04 = 0
local numBully05 = 0
local numRussell = 0
local numSeth = 0
local numSecretary = 0
local numHispanic = 0
local numWhitey = 0
local numBoy01 = 0
local numBoy02 = 0
local numLefty = 0
local numLucky = 0
local numJustin = 0
local numChad = 0
local numLuis = 0
local numDamon = 0
local bSecretaryCreated = false

function F_CheckInitialPOI(POIPoint)
    local x, y, z = AreaPOIGetPosition(POIPoint)
    if DistanceBetweenCoords3d(x, y, z, 274.305, -70.6824, 5.98641) < 5 then
        --print(" POI IS BEING CREATED!", "x: ", x, "y: ", y, "z: ", z)
        if not bPoiFired then
            --print(" POI IS BEING CREATED!: ", 11)
            bPoiFired = true
            return true
        else
            --print(" POI IS NOT BEING CREATED!!")
            return false
        end
    end
end

function MissionSetup()
    DATLoad("1_01.DAT", 2)
    DATInit()
    LoadActionTree("Act/Conv/1_01.act")
    LoadActionTree("Act/Conv/1_02.act")
    MissionDontFadeIn()
    SoundEnableInteractiveMusic(true)
    ClockSet(8, 30)
    shared.lockClothingManager = true
    if GetMissionAttemptCount("1_01") > 1 then
        MissionSurpressMissionNameText()
        gMissionAlreadyExecuted = true
    end
    if not gMissionAlreadyExecuted then
        shared.gOverrideSchoolGates = false
        shared.gFrontGateOpen = false
        Wait(10)
        PAnimCreate(TRIGGER._TSCHOOL_FRONTGATE)
        AreaSetDoorOpen(TRIGGER._TSCHOOL_FRONTGATE, true)
        PAnimSetActionNode(TRIGGER._TSCHOOL_FRONTGATE, "/Global/1_01/Gates/BarUpHold", "Act/Conv/1_01.act")
        PlayCutsceneWithLoad("1-1-1", true, true, true)
        PAnimDelete(TRIGGER._TSCHOOL_FRONTGATE)
        GeometryInstance("ScGate01Closed", false, 301.439, -72.5059, 8.04657, true)
        GeometryInstance("ScGate02Closed", false, 225.928, 5.79816, 8.39471, true)
    else
        CameraSetWidescreen(false)
    end
end

function F_MissionSetup()
    shared.gMissionEventFunction = F_CheckInitialPOI
    PlayerSetControl(0)
    WeatherSet(0)
    LoadAnimationGroup("Hang_Talking")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadAnimationGroup("Area_School")
    LoadAnimationGroup("SBULL_A")
    LoadAnimationGroup("POI_Smoking")
    LoadAnimationGroup("B_Striker")
    LoadAnimationGroup("NPC_Adult")
    shared.lockClothingManager = true
    shared.gPrincipalCheck = false
    LoadPedModels({
        75,
        85,
        145,
        146,
        102,
        50,
        59,
        69,
        139,
        72,
        73,
        24,
        26,
        34,
        32,
        16,
        12
    })
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
    numRussell = PedGetUniqueModelStatus(75)
    PedSetUniqueModelStatus(75, -1)
    numSeth = PedGetUniqueModelStatus(50)
    PedSetUniqueModelStatus(50, -1)
    numSecretary = PedGetUniqueModelStatus(59)
    PedSetUniqueModelStatus(59, -1)
    numHispanic = PedGetUniqueModelStatus(69)
    PedSetUniqueModelStatus(69, -1)
    numWhitey = PedGetUniqueModelStatus(139)
    PedSetUniqueModelStatus(139, -1)
    numBoy01 = PedGetUniqueModelStatus(72)
    PedSetUniqueModelStatus(72, -1)
    numBoy02 = PedGetUniqueModelStatus(73)
    PedSetUniqueModelStatus(73, -1)
    numLefty = PedGetUniqueModelStatus(24)
    PedSetUniqueModelStatus(24, -1)
    numLucky = PedGetUniqueModelStatus(26)
    PedSetUniqueModelStatus(26, -1)
    numJustin = PedGetUniqueModelStatus(34)
    PedSetUniqueModelStatus(34, -1)
    numChad = PedGetUniqueModelStatus(32)
    PedSetUniqueModelStatus(32, -1)
    numLuis = PedGetUniqueModelStatus(16)
    PedSetUniqueModelStatus(16, -1)
    numDamon = PedGetUniqueModelStatus(12)
    PedSetUniqueModelStatus(12, -1)
    nTimesBusted = PlayerGetNumTimesBusted()
    --print("BEGGINING PlayerGetNumTimesBusted!", PlayerGetNumTimesBusted())
    PedSocialOverrideLoad(6, "Mission/1_01_AngryShove.act")
    PedSocialOverrideLoad(0, "Mission/1_01_AngryShove.act")
    AreaActivatePopulationTrigger(TRIGGER._1_01_SCHOOLTRIG)
    LoadWeaponModels({ 405 })
    SetFactionRespect(11, 25)
    SetFactionRespect(1, 50)
    SetFactionRespect(5, 50)
    SetFactionRespect(4, 50)
    SetFactionRespect(2, 50)
    SetFactionRespect(3, 0)
end

function F_LockDoorGeneral(doorId, state)
    AreaSetDoorLocked(doorId, state)
    AreaSetDoorLockedToPeds(doorId, state)
end

function MissionCleanup()
    ToggleHUDComponentVisibility(21, false)
    if shared.gSecretaryID ~= nil and PedIsValid(shared.gSecretaryID) then
        PedDelete(shared.gSecretaryID)
        shared.gSecretaryID = nil
    end
    ClearTextQueue()
    EnablePOI()
    gMissionRunning = false
    shared.gMissionEventFunction = nil
    if gEndBlip then
        BlipRemove(gEndBlip)
    end
    PedSetUniqueModelStatus(102, numBully01)
    PedSetUniqueModelStatus(99, numBully02)
    PedSetUniqueModelStatus(85, numBully03)
    PedSetUniqueModelStatus(145, numBully04)
    PedSetUniqueModelStatus(146, numBully05)
    PedSetUniqueModelStatus(75, numRussell)
    PedSetUniqueModelStatus(50, numSeth)
    PedSetUniqueModelStatus(59, numSecretary)
    PedSetUniqueModelStatus(69, numHispanic)
    PedSetUniqueModelStatus(139, numWhitey)
    PedSetUniqueModelStatus(72, numBoy01)
    PedSetUniqueModelStatus(73, numBoy02)
    PedSetUniqueModelStatus(24, numLefty)
    PedSetUniqueModelStatus(26, numLucky)
    PedSetUniqueModelStatus(34, numJustin)
    PedSetUniqueModelStatus(32, numChad)
    PedSetUniqueModelStatus(16, numLuis)
    PedSetUniqueModelStatus(12, numDamon)
    UnLoadAnimationGroup("Hang_Talking")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("Area_School")
    UnLoadAnimationGroup("SBULL_A")
    UnLoadAnimationGroup("POI_Smoking")
    UnLoadAnimationGroup("B_Striker")
    UnLoadAnimationGroup("NPC_Adult")
    PlayerSetInvulnerable(false)
    WeatherRelease()
    TutorialRemoveMessage()
    AreaRevertToDefaultPopulation()
    PlayerSetControl(1)
    DATUnload(2)
    PlayerSetPunishmentPoints(0)
end

function CB_RenderObj()
    misObj = MissionObjectiveAdd("1_01_StandGround")
end

function T_Lost()
    local bBreak = false
    while not bBreak do
        if IsMissionCompleated("GameStart") then
            if PlayerGetHealth() > 1 then
                Wait(60000)
                TutorialStart("CheckObjs")
                bBreak = true
            else
                bBreak = true
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function T_Tutorials()
    TutorialShowMessage("TUT_START1A", 4500, false)
    Wait(5000)
    TutorialShowMessage("TUT_START1B", 4500, false)
    Wait(4500)
    TextPrint("TUT_STARTOBJ1", 3, 1)
    Wait(1000)
    TutorialStart("GAMESTART")
    collectgarbage()
end

function main()
    F_MissionSetup()
    stageFunction = F_StageOneSetup
    gMissionRunning = true
    while gMissionRunning do
        UpdateTextQueue()
        stageFunction()
        F_UpdatePopulation()
        Wait(0)
    end
    L_StopMonitoringTriggers()
    L_CutsceneFade()
    TextPrintString("", 1, 1)
    if gMissionSuccess then
        MissionSucceed(true, false, false)
        PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
    else
        SoundPlayMissionEndMusic(false, 10)
        MissionFail()
    end
end

local gPrefect, gRussell
local bCanPush = true
local bMonitorRussellEncounter = true
local bFightingRussell = false
local gPreviousPlayerHealth = 0
local gPreviousRussellHealth = 0

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

function F_SetupFight()
    gPreviousPlayerHealth = PedGetHealth(gPlayer)
end

function CB_MonitorRussell(pedId, pathId, nodeId)
end

function F_SendInThePrefects()
end

function F_StageOneSetup()
    AreaTransitionPoint(0, POINTLIST._1_01_PLAYER_START)
    PedSetAlpha(gPlayer, 0, true)
    PlayerSetControl(0)
    PedClearPOIForAllPeds()
    AreaClearAllPeds()
    F_Setup()
    Wait(5)
    gBully01 = PedCreatePoint(85, POINTLIST._1_01_CHEERPOINTS, 2)
    table.insert(gPushers, PedCreatePoint(99, POINTLIST._1_01_CHEERPOINTS, 1))
    table.insert(gPushers, PedCreatePoint(145, POINTLIST._1_01_SECSPAWN, 3))
    local x, y, z = GetPointFromPointList(POINTLIST._1_01_CHEERPOINTS, 3)
    PedFaceXYZ(gBully01, x, y, z, 0)
    PedFaceXYZ(gPushers[1], x, y, z, 0)
    PedFaceXYZ(gPushers[2], x, y, z, 0)
    PedSetActionNode(gPushers[1], "/Global/1_01/Talking", "Act/Conv/1_01.act")
    PedSetActionNode(gPushers[2], "/Global/1_01/Talking", "Act/Conv/1_01.act")
    PedSetActionNode(gBully01, "/Global/1_01/Talking", "Act/Conv/1_01.act")
    AreaTransitionPoint(0, POINTLIST._1_01_PLAYER_START)
    F_SetupFight()
    CameraReturnToPlayer()
    CameraReset()
    --print(" MISSION OBJ ID = ", misObj)
    CreateThread("F_DoMovementTutorial")
    L_CutsceneFade(true)
    PlayerSetControl(1)
    gEndBlip = BlipAddPoint(POINTLIST._1_01_ENDPOINT, 0)
    CB_RenderObj()
    CreateThread("T_Tutorials")
    CreateThread("T_Lost")
    stageFunction = F_MonitorFight
end

function F_DoBullyNIS()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    CameraFade(500, 0)
    Wait(500)
    CameraSetXYZ(282.76654, -73.90239, 6.329092, 281.8066, -73.70586, 6.528721)
    CameraSetWidescreen(true)
    CameraFade(500, 1)
    Wait(2000)
    PedSetActionNode(gPushers[3], "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
    PedFaceObject(gPushers[3], gPlayer, 3, 0)
    Wait(300)
    PedSetActionNode(gPushers[3], "/Global/1_01/PunchHands", "Act/Conv/1_01.act")
    SoundPlayScriptedSpeechEvent(gPushers[3], "M_1_01", 1, "large")
    Wait(2300)
    PedSetActionNode(gBully01, "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
    PedSetActionNode(gPushers[1], "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
    PedSetActionNode(gPushers[2], "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
    PedFaceObject(gBully01, gPlayer, 3, 0)
    PedFaceObject(gPushers[1], gPlayer, 3, 0)
    PedFaceObject(gPushers[2], gPlayer, 3, 0)
    Wait(500)
    PedMoveToPoint(gBully01, 2, POINTLIST._1_01_PLAYER_START, 1)
    PedMoveToPoint(gPushers[1], 2, POINTLIST._1_01_PLAYER_START, 1)
    PedMoveToPoint(gPushers[2], 2, POINTLIST._1_01_PLAYER_START, 1)
    Wait(1500)
    CameraFade(500, 0)
    Wait(500)
    PedDelete(gBully01)
    for i, ped in gPushers do
        PedDelete(ped)
    end
    gPushers = {}
    table.insert(gPushers, PedCreatePoint(102, POINTLIST._1_01_BEGGININGBULLIES, 1))
    table.insert(gPushers, PedCreatePoint(99, POINTLIST._1_01_BEGGININGBULLIES, 2))
    table.insert(gPushers, PedCreatePoint(145, POINTLIST._1_01_BEGGININGBULLIES, 3))
    PedFaceObject(gPushers[1], gPlayer, 3, 0)
    PedFaceObject(gPushers[2], gPlayer, 3, 0)
    PedSetPedToTypeAttitude(gPushers[1], 13, 2)
    PedSetEmotionTowardsPed(gPushers[1], gPlayer, 3, true)
    PedSetWantsToSocializeWithPed(gPushers[1], gPlayer)
    PedSetPedToTypeAttitude(gPushers[2], 13, 2)
    PedSetEmotionTowardsPed(gPushers[2], gPlayer, 1, true)
    PedSetWantsToSocializeWithPed(gPushers[2], gPlayer)
    gSecretary = PedCreatePoint(59, POINTLIST._1_01_SECRETARY, 1)
    PedFollowPath(gSecretary, PATH._1_01_SECPATH, 0, 0)
    PlayerSetPosPoint(POINTLIST._1_01_PLAYERPICKED, 1)
    CameraSetWidescreen(false)
    CameraReset()
    CameraReturnToPlayer()
    CameraFade(500, 1)
    Wait(500)
    PlayerSetControl(1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_MonitorFight()
    if PlayerIsInTrigger(TRIGGER._1_01_BULLYTRIG) then
        PedMakeAmbient(gBully01)
        PedMakeAmbient(gPushers[1])
        PedMakeAmbient(gPushers[2])
        PedSetActionNode(gBully01, "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
        PedSetActionNode(gPushers[1], "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
        PedSetActionNode(gPushers[2], "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
        PedFaceObject(gBully01, gPlayer, 3, 1)
        PedFaceObject(gPushers[1], gPlayer, 3, 1)
        PedFaceObject(gPushers[2], gPlayer, 3, 1)
        Wait(500)
        PedMoveToPoint(gBully01, 0, POINTLIST._1_01_BEGGININGBULLIES, 1)
        PedMoveToPoint(gPushers[1], 0, POINTLIST._1_01_FIGHTBULLIES, 2)
        PedMoveToPoint(gPushers[2], 0, POINTLIST._1_01_FIGHTBULLIES, 3)
        PedSetPedToTypeAttitude(gBully01, 13, 2)
        PedSetEmotionTowardsPed(gBully01, gPlayer, 1, true)
        PedSetWantsToSocializeWithPed(gBully01, gPlayer)
        PedSetPedToTypeAttitude(gPushers[1], 13, 2)
        PedSetEmotionTowardsPed(gPushers[1], gPlayer, 3, true)
        PedSetWantsToSocializeWithPed(gPushers[1], gPlayer)
        PedSetPedToTypeAttitude(gPushers[2], 13, 2)
        PedSetEmotionTowardsPed(gPushers[2], gPlayer, 1, true)
        PedSetWantsToSocializeWithPed(gPushers[2], gPlayer)
        stageFunction = F_CheckFinish
    end
end

function CB_RunTutorial()
    PedClearObjectives(gSecretary)
    PedFollowPath(gSecretary, PATH._1_01_SECPATH, 0, 0, CB_SecPath)
end

function F_StageTwoSetup()
    if gSecPathNode == PathGetLastNode(PATH._1_01_SECPATH) and gSecretary and PedIsValid(gSecretary) and not PedIsDead(gSecretary) then
        PedDelete(gSecretary)
    end
    if AreaGetVisible() == 2 then
        F_LockDoorGeneral("DT_ISCHOOL_PRINCIPALDOORL", false)
        PlayerFaceHeadingNow(0)
        if gSecretary and PedIsValid(gSecretary) and not PedIsDead(gSecretary) then
            PedStop(gSecretary)
            PedDelete(gSecretary)
            gSecretary = nil
        end
        stageFunction = F_StageThreeSetup
    end
end

function F_StageThreeSetup()
    LoadAnimationGroup("GarbagePickup")
    LoadAnimationGroup("NPC_Principal")
    eX, eY, eZ = GetPointList(POINTLIST._1_01_ENDPOINT)
    F_CheckFinish()
    stageFunction = F_CheckFinish
end

function F_StageThree()
    F_CheckFinish()
    if gMissionSuccess then
        gMissionRunning = false
    end
end

function F_Setup()
    PedSetPunishmentPoints(gPlayer, 0)
    eX, eY, eZ = GetPointList(POINTLIST._1_01_ENDPOINT)
    L_AddTrigger("triggers", {
        trigger5 = {
            trigger = TRIGGER._1_01_PARKDOOR,
            OnEnter = F_ParkDoorClose,
            OnExit = nil,
            ped = gPlayer,
            bTriggerOnlyOnce = true
        },
        trigger6 = {
            trigger = TRIGGER._1_01_NURSELOCK,
            OnEnter = F_LockNurseDoor,
            OnExit = nil,
            ped = gPlayer,
            bTriggerOnlyOnce = true
        }
    })
    AreaClearAllPeds()
    PedSetAlpha(gPlayer, 255, true)
end

function F_CheckFinish()
    local x, y, z = GetPointFromPointList(POINTLIST._1_01_ENDPOINT, 1)
    if PlayerIsInAreaXYZ(x, y, z, 1, 7) then
    end
    if AreaGetVisible() == 2 and not bSecretaryCreated then
        if shared.gSecretaryID ~= nil and PedIsValid(shared.gSecretaryID) then
            PedDelete(shared.gSecretaryID)
        end
        shared.gSecretaryID = PedCreatePoint(59, POINTLIST._1_01_SECRETARYINOFFICE, 1)
        bSecretaryCreated = true
    end
    if not bPedroBeingChased then
        gPedro = PedCreatePoint(69, POINTLIST._1_01_KIDRUN, 2)
        gPedroBully = PedCreatePoint(102, POINTLIST._1_01_KIDRUN, 1)
        PedSetInfiniteSprint(gPedro, true)
        PedSetInfiniteSprint(gPedroBully, true)
        PedMoveToPoint(gPedro, 3, POINTLIST._1_01_KIDRUN, 3)
        Wait(1000)
        PedAttack(gPedroBully, gPedro, 3)
        bPedroBeingChased = true
    end
    if not bPedroCleaned and PlayerIsInTrigger(TRIGGER._1_01_CHECKOBJS1) then
        if gPedro and PedIsValid(gPedro) then
            PedMakeAmbient(gPedro)
        end
        if gPedroBully and PedIsValid(gPedroBully) then
            PedMakeAmbient(gPedroBully)
        end
        gPedroCleaned = true
    end
    if PlayerIsInTrigger(TRIGGER._1_01_PRINCOFFICE) and not gMissionSuccess then
        PlayerSetControl(0)
        PlayerFaceHeading(0, 1)
        if shared.gSecretaryID ~= nil and PedIsValid(shared.gSecretaryID) then
            Wait(500)
            PedSetActionNode(gPlayer, "/Global/1_01/WaveToSec", "Act/Conv/1_01.act")
            SoundPlayScriptedSpeechEvent(gPlayer, "M_1_01", 101, "large")
            Wait(10)
            while SoundSpeechPlaying(gPlayer) do
                Wait(1)
            end
        end
        gMissionSuccess = true
        gMissionRunning = false
        --print(" MISSION OBJ ID = ", misObj)
        MissionObjectiveRemove(misObj)
    end
end

function F_ParkDoorClose()
    PAnimCloseDoor(TRIGGER._TSCHOOL_PARKINGGATE)
    F_LockDoorGeneral(TRIGGER._TSCHOOL_PARKINGGATE, true)
end

function F_LockNurseDoor()
    F_LockDoorGeneral(TRIGGER._DT_INFIRM_DOORGROUNDS, true)
end

function F_SetupFinalFightPed(ped)
    PedLockTarget(ped, gPlayer, 3)
    PedSetActionNode(ped, "/Global/1_02/Talking/Talk", "Act/Conv/1_02.act")
end

function F_SetupTrainingFightPed(ped)
    PedSetAsleep(ped, true)
    PedSetStationary(ped, true)
    PedSetCheap(ped, true)
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
    PedSetActionNode(ped, "/Global/1_01/ShortIdle", "Act/Conv/1_01.act")
    PedSetCheering(ped, true)
    PedSetTaskNode(ped, "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
end

function F_StartCheeringTable(table)
    for i, ped in table do
        F_StartCheeringPed(ped)
    end
end

function F_DoMovementTutorial()
    local timeStarted = GetTimer()
    local x, y, z = GetPointFromPointList(POINTLIST._1_01_PLAYER_START, 1)
    collectgarbage()
end

function F_UpdatePopulation()
    local visibleArea = AreaGetVisible()
    if gVisibleArea ~= 0 and visibleArea == 0 then
        AreaActivatePopulationTrigger(TRIGGER._1_01_SCHOOLTRIG)
        gVisibleArea = visibleArea
    elseif gVisibleArea ~= 2 and visibleArea == 2 then
        AreaRevertToDefaultPopulation()
        gVisibleArea = visibleArea
    end
end

function F_PlayerWasHarassed()
    bDoneHarassing = true
end

function CB_SecPath(pedId, pathId, nodeId)
    gSecPathNode = nodeId
end

function CB_TurnOnHud()
    PedClearObjectives(gSecretary)
    PedFollowPath(gSecretary, PATH._1_01_SECPATH, 0, 0, CB_SecPath)
    misObj = MissionObjectiveAdd("1_01_08")
end

function F_PassedCallback(button)
    gSequencePassed = true
    --print("SDIFMSDKFS!")
end

function F_FailedCallback(button, timesUp)
    ButtonHistoryIgnoreController(false)
    gSequenceFailed = true
end

function F_CorrectButtonPressed(button)
    gButtonCorrect = true
    --print("SDFKLMSKLDFML!!")
end

function F_CanBlock()
    return 1
end

function CB_GotThere1()
    F_SetupTrainingFightPed(gCrowd[1])
    F_StartCheeringPed(gCrowd[1])
end

function CB_GotThere2()
    F_SetupTrainingFightPed(gCrowd[2])
    F_StartCheeringPed(gCrowd[2])
end

function CB_GotThere3()
    F_SetupTrainingFightPed(gCrowd[3])
    F_StartCheeringPed(gCrowd[3])
end

function CB_GotThere4()
    F_SetupTrainingFightPed(gCrowd[4])
    F_StartCheeringPed(gCrowd[4])
end

function CB_GotThere5()
    F_SetupTrainingFightPed(gCrowd[5])
    F_StartCheeringPed(gCrowd[5])
end

function CB_GotThere6()
    F_SetupTrainingFightPed(gCrowd[6])
    F_StartCheeringPed(gCrowd[6])
end

function CB_GotThere7()
    F_SetupTrainingFightPed(gCrowd[7])
    F_StartCheeringPed(gCrowd[7])
end

function CB_GotThere8()
    F_SetupTrainingFightPed(gCrowd[8])
    F_StartCheeringPed(gCrowd[8])
end

function CB_GotThere9()
    F_SetupTrainingFightPed(gCrowd[9])
    F_StartCheeringPed(gCrowd[9])
end

function CB_GotThere10()
    F_SetupTrainingFightPed(gCrowd[10])
    F_StartCheeringPed(gCrowd[10])
end

function F_PushPlayerAway(table)
    local closestPed, closestDistance, distance
    local x, y, z = PlayerGetPosXYZ()
    local x2, y2, z2
    for i, ped in table do
        x2, y2, z2 = PedGetPosXYZ(ped)
        distance = DistanceBetweenCoords3d(x, y, z, x2, y2, z2)
        if closestDistance == nil or closestDistance > distance then
            closestPed = ped
            closestDistance = distance
        end
        Wait(0)
    end
    if gMissionUpdateFunction == F_MonitorTraining1 then
    end
    if closestPed and closestDistance <= 1 then
        local x, y, z = GetPointFromPointList(POINTLIST._1_01_PLAYER_START, 3)
        PedFaceXYZ(closestPed, x, y, z, 0)
        Wait(5)
        PedSetGrappleTarget(closestPed, gPlayer)
        PedSetActionNode(closestPed, "/Global/1_02/PushPlayer/GrappleSuccess/Yay/AttackIdle", "Act/Conv/1_02.act")
        Wait(800)
    end
end

function F_PlayerGrapple()
    if bGrappleAttacks then
        return 1
    end
    return 0
end

function F_PlayerSloppyAttacks()
    if bLightAttacks then
        return 1
    end
    return 0
end

function F_PlayerHeavyAttacks()
    if bHeavyAttacks then
        return 1
    end
    return 0
end
