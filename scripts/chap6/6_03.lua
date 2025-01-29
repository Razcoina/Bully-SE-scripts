local gCops = {}
local gRussell, gStageUpdateFunction
local gMissionStage = "running"
local gStageEvent = false
local gPeds = {}
local gEdgar
local gCurrentRussellNode = 0
local bNerdBoss, bGreaserBoss, bJockBoss, bPreppyBoss
local bUpdatePlayerLoc = true
local gNerdThread, gJockThread, gGreaserThread, gPreppyThread, gTriggerActivated
local gObjectiveBlips = {}
local gGary
local gGaryAttacking = 1
local gGaryCurrentNode = 0
local gOriginalGaryHealth = 0
local bGaryAlive = true
local gGaryPos = {}
local geometryTable = {}
local gGirlsHaveAttacked = false
local bBossesKilled = false
local gPreviousRussellHealth = 0
local nPlayerEnd = 0
local nRussellEnd = 0
local nPrefectEnd = 0
local tObjectiveTable = {}
local bLastLeader = false
local bRussellDied = false
local bKeepGuysSpawning = true
local bPlayingLowIntensityMusic = false
local bLeftSchool = false
local gFireEffects = {}
local gGaryTextTable = {
    "6_03_GARY01",
    "6_03_GARY02",
    "6_03_GARY03",
    "6_03_GARY04",
    "6_03_GARY05"
}
local bTransitionFadeEnabled = false

function MissionCleanup()
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("NIS_6_03")
    F_CleanupFire()
    PedSetUniqueModelStatus(48, 1)
    PedSetUniqueModelStatus(39, 1)
    PedSetUniqueModelStatus(74, 1)
    PedSetUniqueModelStatus(66, 1)
    PedSetUniqueModelStatus(68, 1)
    PedSetUniqueModelStatus(137, 1)
    PedSetUniqueModelStatus(138, 1)
    PedSetUniqueModelStatus(67, 1)
    PedSetUniqueModelStatus(25, 1)
    PedSetUniqueModelStatus(14, 1)
    PedSetUniqueModelStatus(3, 1)
    PedSetUniqueModelStatus(38, 1)
    AreaEnableAllPatrolPaths()
    AreaRevertToDefaultPopulation()
    EnablePOI(true, true)
    SoundStopInteractiveStream()
    SoundEnableSpeech_ActionTree()
    F_RemoveObjectiveBlip()
    for i, entity in geometryTable do
        DeletePersistentEntity(entity[2], entity[3])
    end
    shared.g_603_NerdBlip = nil
    shared.g_603_JockBlip = nil
    shared.g_603_PreppyBlip = nil
    shared.g_603_GreaserBlip = nil
    PedResetTypeAttitudesToDefault()
    PedSetGlobalAttitude_Rumble(false)
    DisablePunishmentSystem(false)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLFRONTDOORL", false)
    F_LockDoorGeneral("TSCHOOL_SCHOOLFRONTDOORR", false)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLLEFTFRONTDOOR", false)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLLEFTBACKDOOR", false)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLRIGHTBACKDOOR", false)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR", false)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLSIDEDOORL", false)
    F_LockDoorGeneral("DT_TSCHOOL_POOLL", false)
    F_LockDoorGeneral("GYMPOOL_DOORL", false)
    F_LockDoorGeneral("GYMPOOL_DOORR", false)
    AreaSetDoorLocked("DT_GYM_DOORL", false)
    AreaSetDoorLocked("DT_POOL_DOORL", false)
    AreaSetDoorLocked("GYML_DOORR", false)
    AreaSetDoorLocked("POOL_DOORR", false)
    AreaSetDoorLocked("DT_GDORM_DOORL", false)
    AreaSetDoorLocked("GDORM_UPPERDOORSTORAGE", false)
    AreaSetDoorLocked("GDORM_DOORR", false)
    AreaSetDoorLocked("DT_GDORM_DOORLEXIT", false)
    AreaSetDoorLocked("ESCDOORL", false)
    AreaSetDoorLocked("DT_LIBRARYEXITR", false)
    AreaSetDoorLocked("DT_PREPTOMAIN", false)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
end

function F_LockDoorGeneral(doorId, state)
    AreaSetDoorLocked(doorId, state)
end

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("6_02.DAT", 2)
    DATInit()
    PedSetUniqueModelStatus(176, -1)
    AreaDisableAllPatrolPaths()
    AreaDisableCameraControlForTransition(true)
    AreaTransitionPoint(0, POINTLIST._INDUS_POINTS, 12, true)
    PAnimCreate(TRIGGER._TSCHOOL_FRONTGATE)
    PAnimCreate(TRIGGER._TSCHOOL_PARKINGGATE)
    PlayCutsceneWithLoad("6-02B", true, true)
end

function F_MissionSetup()
    F_LockDoorGeneral("DT_TSCHOOL_PREPPYL", false)
    F_LockDoorGeneral("DT_TSCHOOL_GYML", false)
    F_LockDoorGeneral("DT_TSCHOOL_GIRLSDORML", false)
    F_LockDoorGeneral("DT_TSCHOOL_LIBRARYL", false)
    F_LockDoorGeneral("DT_TSCHOOL_BOYSDORML", false)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLFRONTDOORL", true)
    F_LockDoorGeneral("TSCHOOL_SCHOOLFRONTDOORR", true)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLLEFTFRONTDOOR", true)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLLEFTBACKDOOR", true)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLRIGHTBACKDOOR", true)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR", true)
    F_LockDoorGeneral("DT_TSCHOOL_SCHOOLSIDEDOORL", true)
    F_LockDoorGeneral("DT_TSCHOOL_POOLL", true)
    F_LockDoorGeneral("GYMPOOL_DOORL", true)
    F_LockDoorGeneral("GYMPOOL_DOORR", true)
    DisablePunishmentSystem(true)
    bPlayingLowIntensityMusic = true
    SoundPlayInteractiveStreamLocked("MS_StreetFightLargeLow_Boxing.rsm", 0.85)
    PedSetUniqueModelStatus(48, -1)
    PedSetUniqueModelStatus(39, -1)
    PedSetUniqueModelStatus(74, -1)
    PedSetUniqueModelStatus(66, -1)
    PedSetUniqueModelStatus(68, -1)
    PedSetUniqueModelStatus(137, -1)
    PedSetUniqueModelStatus(138, -1)
    PedSetUniqueModelStatus(67, -1)
    PedSetUniqueModelStatus(25, -1)
    PedSetUniqueModelStatus(14, -1)
    PedSetUniqueModelStatus(3, -1)
    PedSetUniqueModelStatus(38, -1)
    LoadAnimationGroup("NIS_6_03")
    LoadPedModels({
        176,
        46,
        42,
        91,
        83,
        97
    })
    LoadVehicleModels({ 295 })
    LoadActionTree("Act/Conv/6_02.act")
    local index, simpleObject = CreatePersistentEntity("DPE_Dumpster", 79.0067, -418.112, 0.710667, -169.314, 0)
    table.insert(geometryTable, {
        "DPE_Dumpster",
        index,
        simpleObject
    })
    shared.g6_03_GreasersAlive = true
    shared.g6_03_NerdsAlive = true
    shared.g6_03_PreppiesAlive = true
    shared.g6_03_JocksAlive = true
    shared.g6_03_AreaReady = false
    shared.g1_08_bGymPop = false
    POIGroupsEnabled(false)
    DisablePOI(true, true)
    PedSetGlobalAttitude_Rumble(true)
    AreaSetPopulationSexGeneration(false, true)
    PedSaveWeaponInventorySnapshot(gPlayer)
end

function F_CBGaryFollowPath(pedId, pathId, nodeId)
    gGaryCurrentNode = nodeId
end

function CB_OttoDied()
    SoundPlayMissionEndMusic(false, 10)
    MissionFail(false)
end

local bDoorsLocked = false

function F_Stage5()
    local gAreaVisible = AreaGetVisible()
    local x, y, z = GetPointFromPointList(POINTLIST._6_03_SCHOOLENTRANCE, 1)
    if PlayerIsInAreaXYZ(x, y, z, 1.2, 7) then
        CameraFade(500, 0)
        Wait(501)
        AreaTransitionPoint(2, POINTLIST._6_03_ENDNIS, 1, false)
        LoadPedModels({
            50,
            49,
            130,
            99,
            85,
            145,
            91
        })
        LoadAnimationGroup("NPC_Adult")
        LoadAnimationGroup("NPC_AggroTaunt")
        LoadAnimationGroup("NIS_6_03")
        LoadAnimationGroup("Russell")
        LoadAnimationGroup("IDLE_DOUT_D")
        bKeepGuysSpawning = false
        AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        AreaClearAllPeds()
        while IsStreamingBusy() do
            Wait(0)
        end
        SoundDisableSpeech_ActionTree()
        PedDismissAlly(gPlayer, gRussell)
        PedSetMissionCritical(gRussell, false, nil, false)
        AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        AreaClearAllPeds()
        PedSetFlag(gPlayer, 2, false)
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        while WeaponEquipped() do
            PlayerUnequip()
            Wait(200)
        end
        WeaponRequestModel(306)
        DisablePunishmentSystem(false)
        ClockSet(22, 1)
        PedSetTypeToTypeAttitude(0, 11, 4)
        PedSetTypeToTypeAttitude(0, 3, 4)
        gEdgar = PedCreatePoint(91, POINTLIST._6_03_ENDNIS, 2)
        local gPrefect1 = PedCreatePoint(50, POINTLIST._6_03_ENDNIS, 5)
        local gPrefect2 = PedCreatePoint(49, POINTLIST._6_03_ENDNIS, 4)
        local gBully01 = PedCreatePoint(99, POINTLIST._6_03_ENDNISBULLIES, 1)
        local gBully02 = PedCreatePoint(85, POINTLIST._6_03_ENDNISBULLIES, 2)
        local gBully03 = PedCreatePoint(145, POINTLIST._6_03_ENDNISBULLIES, 3)
        F_EnableRussell(false)
        PedSetPosPoint(gRussell, POINTLIST._6_03_ENDNIS, 3)
        PedSetFlag(gPlayer, 2, false)
        PedLockTarget(gEdgar, gPlayer, 3)
        SoundDisableSpeech_ActionTree()
        PedSetAsleep(gBully01, true)
        PedSetAsleep(gBully02, true)
        PedSetAsleep(gBully03, true)
        Wait(50)
        PedSetActionNode(gBully01, "/Global/6_02/GaryNIS/Bullies/Bully01", "Act/Conv/6_02.act")
        PedSetActionNode(gBully02, "/Global/6_02/GaryNIS/Bullies/Bully02", "Act/Conv/6_02.act")
        PedSetActionNode(gBully03, "/Global/6_02/GaryNIS/Bullies/Bully03", "Act/Conv/6_02.act")
        DoublePedShadowDistance(true)
        CameraSetFOV(80)
        CameraSetXYZ(-627.471, -315.071, 1.911162, -628.01794, -314.28592, 1.620989)
        CameraFade(500, 1)
        PedSetActionNode(gEdgar, "/Global/6_02/GaryNIS/Edgar/EdgarCocky", "Act/Conv/6_02.act")
        F_PlaySpeechWait(gEdgar, "M_6_03", 76, "supersize", false)
        SoundPlayScriptedSpeechEvent(gEdgar, "LAUGH_CRUEL", 0, "supersize")
        CameraSetFOV(80)
        PedMoveToPoint(gPlayer, 1, POINTLIST._6_03_ENDNISMOVETO, 1)
        PedMoveToPoint(gRussell, 1, POINTLIST._6_03_ENDNISMOVETO, 2)
        Wait(50)
        CameraSetXYZ(-628.848, -308.4398, 0.96035, -629.1296, -309.39328, 0.853643)
        SoundPlayScriptedSpeechEvent(gPlayer, "M_6_03", 62, "supersize")
        Wait(1000)
        CameraSetFOV(30)
        CameraSetXYZ(-625.28986, -308.62173, 1.843411, -625.7746, -309.48752, 1.719774)
        PedSetActionNode(gEdgar, "/Global/6_02/GaryNIS/Edgar/EdgarBlank", "Act/Conv/6_02.act")
        PedMoveToPoint(gEdgar, 1, POINTLIST._6_03_ENDNIS, 8)
        Wait(2500)
        CameraSetFOV(30)
        CameraSetXYZ(-626.6524, -316.94232, 1.619864, -627.1652, -316.0904, 1.516163)
        PedLockTarget(gPlayer, gEdgar, 3)
        PedLockTarget(gEdgar, gPlayer, 3)
        PedFaceObject(gEdgar, gPlayer, 3, 1, false)
        PedFaceObject(gPlayer, gEdgar, 2, 1, false)
        CameraSetFOV(30)
        CameraSetXYZ(-625.28986, -308.62173, 1.843411, -625.7746, -309.48752, 1.719774)
        PedSetActionNode(gPlayer, "/Global/6_02/GaryNIS/Player/Player02", "Act/Conv/6_02.act")
        SoundPlayScriptedSpeechEvent(gPlayer, "M_6_03", 59, "large")
        Wait(1000)
        PedMoveToPoint(gRussell, 0, POINTLIST._6_03_ENDNISMOVETO, 4)
        F_WaitForSpeech(gPlayer)
        CameraSetFOV(30)
        CameraSetXYZ(-627.0591, -317.09448, 1.785446, -627.46313, -316.1909, 1.643565)
        PedSetActionNode(gEdgar, "/Global/6_02/GaryNIS/Edgar/Edgar02", "Act/Conv/6_02.act")
        F_PlaySpeechWait(gEdgar, "M_6_03", 63, "large", false)
        SoundPlayScriptedSpeechEvent(gEdgar, "LAUGH_FRIENDLY", 0, "large")
        PedFollowPath(gEdgar, PATH._6_03_ENDEDGARPATH, 0, 2)
        Wait(3000)
        PedLockTarget(gPlayer, -1)
        PedSetActionNode(gPlayer, "/Global/6_02/GaryNIS/Player/Blank", "Act/Conv/6_02.act")
        PedClearAllWeapons(gPrefect1)
        PedIgnoreStimuli(gPrefect1, true)
        PedMoveToObject(gPrefect1, gPlayer, 3, 2)
        PedLockTarget(gPrefect1, gPlayer, 3)
        SoundPlayScriptedSpeechEvent(gPrefect1, "M_6_03", 69, "jumbo")
        Wait(1500)
        PedLockTarget(gPlayer, gPrefect1, 3)
        Wait(500)
        SoundPlayScriptedSpeechEvent(gPrefect1, "M_6_03", 68, "jumbo")
        PedMoveToPoint(gPrefect2, 1, POINTLIST._6_03_ENDNIS, 7)
        PedSetPunishmentPoints(gEdgar, 0)
        PedSetPunishmentPoints(gRussell, 0)
        PedSetPunishmentPoints(gPlayer, 3)
        while not PlayerIsInAreaObject(gPrefect1, 2, 1.5, 0) do
            Wait(0)
        end
        PedStop(gPrefect1)
        Wait(50)
        CameraSetFOV(30)
        CameraSetXYZ(-626.73755, -309.03946, 2.145183, -627.05145, -309.96512, 1.936732)
        PedStop(gPlayer)
        PedLockTarget(gPrefect1, gPlayer, 3)
        PedFaceObjectNow(gPrefect1, gPlayer, 3)
        Wait(50)
        PedFaceObjectNow(gPlayer, gPrefect1, 2)
        PedLockTarget(gPrefect1, gPlayer, 3)
        PedSetGrappleTarget(gPrefect1, gPlayer, 3)
        Wait(50)
        PedSetActionNode(gPlayer, "/Global/6_02/Blank", "Act/Conv/6_02.act")
        Wait(50)
        PedSetActionNode(gPrefect1, "/Global/6_02/PlayerBusted/BustThatBitch", "Act/Conv/6_02.act")
        PedSetActionNode(gPlayer, "/Global/Weapons/SelectActions/WeaponSelect/Deselect/DropDirect/PutAway", "Act/Weapons.act")
        F_WaitForSpeech(gPrefect1)
        SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 70, "jumbo")
        F_WaitForSpeech(gRussell)
        PedLockTarget(gPrefect2, gRussell, 3)
        PedLockTarget(gPrefect1, -1)
        PedLockTarget(gPlayer, -1)
        SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 71, "jumbo")
        F_WaitForSpeech(gRussell)
        CameraSetFOV(80)
        CameraSetXYZ(-625.1142, -314.43323, 0.56602, -624.40936, -315.0099, 0.979045)
        SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 9, "jumbo")
        PedSetActionNode(gRussell, "/Global/6_02/GaryNIS/Russell/Russell01", "Act/Conv/6_02.act")
        PedStop(gPrefect2)
        PedFaceObjectNow(gRussell, gPrefect1, 2)
        PedFaceObjectNow(gPrefect1, gRussell, 2)
        PedFaceObjectNow(gPrefect2, gRussell, 2)
        Wait(500)
        PedLockTarget(gPrefect1, gRussell, 3)
        Wait(1000)
        CameraSetFOV(40)
        CameraSetXYZ(-620.5806, -314.26575, 1.316027, -621.5791, -314.29663, 1.276388)
        PedSetActionNode(gPrefect1, "/Global/6_02/BeScared", "Act/Conv/6_02.act")
        Wait(300)
        PedSetActionNode(gPrefect2, "/Global/6_02/BeScared", "Act/Conv/6_02.act")
        Wait(2000)
        PedFollowPath(gPrefect1, PATH._6_03_ENDRUSSPATH, 0, 2)
        PedFollowPath(gPrefect2, PATH._6_03_ENDEDGARPATH, 0, 2)
        Wait(1000)
        CameraSetFOV(40)
        CameraSetXYZ(-623.86444, -303.73737, 2.039076, -624.4549, -304.53897, 1.946003)
        PedSetActionNode(gRussell, "/Global/6_02/GaryNIS/Russell/RussellLoco", "Act/Conv/6_02.act")
        PedFollowPath(gRussell, PATH._6_03_ENDRUSSPATH, 0, 2)
        SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 72, "supersize")
        F_WaitForSpeech(gRussell)
        CameraSetFOV(40)
        CameraSetXYZ(-631.27814, -310.23486, 0.264245, -630.7142, -311.0525, 0.374735)
        PedSetActionNode(gPlayer, "/Global/6_02/PlayerGetUp/GetUp", "Act/Conv/6_02.act")
        SoundPlayScriptedSpeechEvent(gPlayer, "M_1_02B", 85, "jumbo")
        F_WaitForSpeech(gPlayer)
        local gGary = PedCreatePoint(130, POINTLIST._6_03_ENDNIS, 6)
        SoundPlayScriptedSpeechEvent(gGary, "M_6_03", 67, "jumbo", true)
        Wait(1500)
        CameraSetFOV(80)
        CameraSetXYZ(-634.7213, -303.7864, 12.334122, -634.3309, -304.42026, 11.667567)
        PedSetActionNode(gPlayer, "/Global/6_02/GaryNIS/Player/PlayerLookAround", "Act/Conv/6_02.act")
        F_WaitForSpeech(gGary)
        CameraSetFOV(80)
        CameraSetXYZ(-628.92804, -313.7767, 1.268898, -628.2281, -314.48843, 1.326908)
        CameraLookAtObject(gPlayer, 3, true, 0.75)
        SoundPlayScriptedSpeechEvent(gPlayer, "M_6_03", 63, "jumbo", true)
        F_WaitForSpeech(gPlayer)
        Wait(1000)
        CameraSetFOV(20)
        CameraSetXYZ(-630.33594, -322.91156, 0.898735, -630.2008, -321.9209, 0.91337)
        PedSetActionNode(gGary, "/Global/6_02/GaryCrazy/GoOff", "Act/Conv/6_02.act")
        SoundPlayScriptedSpeechEvent(gGary, "M_6_03", 64, "jumbo")
        Wait(1000)
        CameraSetFOV(20)
        CameraSetXYZ(-628.9045, -303.9589, 2.522108, -628.808, -302.9773, 2.685092)
        PedSetActionNode(gPlayer, "/Global/6_02/GaryNIS/Player/Blank", "Act/Conv/6_02.act")
        PedFaceObject(gPlayer, gGary, 2, 1)
        F_WaitForSpeech(gGary)
        PedFollowPath(gGary, PATH._GARYPATH, 0, 2, nil, 3)
        PedFollowPath(gPlayer, PATH._6_03_ENDNISJIMMYRUNS, 0, 2, nil, 3)
        Wait(500)
        CameraSetFOV(70)
        CameraSetXYZ(-632.5693, -315.48975, 0.752947, -632.1101, -314.60782, 0.859204)
        Wait(4000)
        SoundFadeWithCamera(true)
        MusicFadeWithCamera(true)
        CameraFade(500, 0)
        Wait(501)
        CameraDefaultFOV()
        DoublePedShadowDistance(false)
        PedStop(gGary)
        PedStop(gPlayer)
        PlayerSetControl(1)
        CameraSetWidescreen(false)
        F_MakePlayerSafeForNIS(false)
        SoundEnableSpeech_ActionTree()
        gMissionStage = "passed"
    end
end

function CB_PLAYEREND(pedId, pathId, nodeId)
    nPlayerEnd = nodeId
end

function CB_RUSSELLEND(pedId, pathId, nodeId)
    nRussellEnd = nodeId
end

function CB_PREFECTEND(pedId, pathId, nodeId)
    nPrefectEnd = nodeId
end

function F_Stage5Setup()
    gStageUpdateFunction = F_Stage5
end

function F_Stage4Setup()
    F_RemoveMissionObjective("6_03_OBJLAST", true)
    for i, ped in gPeds do
        if ped and PedIsValid(ped) then
            PedDelete(ped)
        end
    end
    gPeds = {}
    F_AddObjectiveBlip("POINT", POINTLIST._OBJECTIVELOCS, 5)
    F_AddMissionObjective("6_03_OBJ02C", true)
    gTriggerActivated = false
    gStageUpdateFunction = F_Stage5Setup
end

function F_Stage3()
    if F_ObjectiveAlreadyComplete("6_03_OBJ01") and F_ObjectiveAlreadyComplete("6_03_OBJ02") and F_ObjectiveAlreadyComplete("6_03_OBJ03") and F_ObjectiveAlreadyComplete("6_03_OBJ04") then
        gStageUpdateFunction = F_Stage4Setup
    elseif shared.g6_03_NerdsAlive == false or shared.g6_03_GreasersAlive == false or shared.g6_03_JocksAlive == false or shared.g6_03_PreppiesAlive == false then
        F_UpdateBosses()
    end
end

function F_Stage3Setup()
    gStageEvent = false
    F_RemoveObjectiveBlip()
    PlayerSetControl(0)
    if gRussell then
        PedDelete(gRussell)
    end
    F_SideSchoolNIS()
    F_SetupBosses()
    PedRecruitAlly(gPlayer, gRussell)
    PedMakeTargetable(gRussell, false)
    PedSetHealth(gRussell, PedGetHealth(gRussell) * 7)
    --print("RUSSELL's health: ", PedGetHealth(gRussell))
    PAnimOpenDoor(TRIGGER._TSCHOOL_PARKINGGATE)
    F_UpdateGlobalHatred()
    gStageUpdateFunction = F_Stage3
end

function main()
    F_MissionSetup()
    F_AddMissionObjective("6_03_OBJ00", false)
    F_RestoreAllBlips()
    CreateThread("T_LeaveingFail")
    CreateThread("T_MonitorBarriers")
    gStageUpdateFunction = F_Stage3Setup
    while gMissionStage == "running" do
        gStageUpdateFunction()
        UpdateTextQueue()
        F_UpdateGates()
        Wait(0)
        if bRussellDied then
            gMissionStage = "failed"
            break
        end
    end
    if gMissionStage == "passed" then
        MissionSucceed(false, false, false)
    elseif gMissionStage == "failed" then
        PedRestoreWeaponInventorySnapshot(gPlayer)
        SoundPlayMissionEndMusic(false, 10)
        if bRussellDied then
            MissionFail(true, true, "6_03_RUSSDIED")
        elseif bLeftSchool then
            TextPrintString("", 1, 1)
            MissionFail(true, true, "6_03_FAILLEAVE")
        else
            MissionFail(true, true)
        end
    end
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
            gObjectiveBlip = BlipAddXYZ(x, y, z + 0.1, 0)
        elseif blipType == "CHAR" and not PedIsDead(point) then
            Wait(100)
            gObjectiveBlip = AddBlipForChar(point, index, 0, blipEnum)
        end
    end
end

function F_RussellDied()
    --print("RUSSELL DIED!!!")
    if PedGetHealth(gRussell) <= 0 then
        bRussellDied = true
    end
end

function F_SideSchoolNIS()
    AreaDisableCameraControlForTransition(true)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    CameraSetWidescreen(true)
    CameraSetFOV(80)
    CameraSetXYZ(235.07718, 6.766103, 6.505191, 234.1353, 6.554569, 6.765789)
    gRussell = PedCreatePoint(176, POINTLIST._SIDESCHOOLPOINTS, 4)
    local ped = PedCreatePoint(46, POINTLIST._SIDESCHOOLPOINTS, 2)
    table.insert(gPeds, ped)
    local ped = PedCreatePoint(42, POINTLIST._SIDESCHOOLPOINTS, 3)
    table.insert(gPeds, ped)
    gEdgar = PedCreatePoint(91, POINTLIST._SIDESCHOOLPOINTS, 1)
    PedSetInfiniteSprint(gEdgar, true)
    PedSetInfiniteSprint(gPeds[1], true)
    PedSetInfiniteSprint(gPeds[2], true)
    PedOverrideStat(gRussell, 39, 80)
    gPreviousRussellHealth = PedGetHealth(gRussell)
    PedSetMissionCritical(gRussell, true, F_RussellDied, false)
    if AreaGetVisible() == 0 then
        GeometryInstance("ScGate01Opened", true, 299.988, -72.5031, 8.04657, false)
        GeometryInstance("ScGate02Opened", true, 224.477, 5.8009, 8.39471, false)
        GeometryInstance("ScGate01Closed", true, 301.439, -72.5059, 8.04657, false)
        GeometryInstance("ScGate02Closed", true, 225.928, 5.79816, 8.39471, false)
        for i, gate in shared.gSchoolGates do
            DeletePersistentEntity(gate.id, gate.bPool)
        end
        shared.gSchoolGates = {}
        AreaSetPathableInRadius(303.1998, -72.23503, 5.583573, 0.5, 3, true)
        AreaSetPathableInRadius(226.3478, 5.853811, 5.758574, 0.5, 3, true)
    end
    local x, y, z = GetPointFromPointList(POINTLIST._INDUS_POINTS, 12)
    PlayerSetPosXYZ(x, y, z)
    PedSetTypeToTypeAttitude(3, 13, 2)
    Wait(1000)
    CameraFade(500, 1)
    Wait(500)
    PedSetActionNode(gPlayer, "/Global/6_02/SchoolGatesNIS/Jimmy/Jimmy01", "Act/Conv/6_02.act")
    F_PlaySpeechWait(gPlayer, "M_6_03", 18, "jumbo", false, false)
    CameraSetFOV(40)
    CameraSetXYZ(234.62921, 6.093278, 7.087561, 233.65298, 5.897002, 7.178473)
    PedSetActionNode(gRussell, "/Global/6_02/SchoolGatesNIS/Russell/Russell01", "Act/Conv/6_02.act")
    F_PlaySpeechWait(gRussell, "M_6_03", 19, "jumbo", false, false)
    PedFaceObjectNow(gPeds[1], gRussell, 2)
    PedFaceObjectNow(gPeds[2], gRussell, 2)
    PedFaceObjectNow(gEdgar, gRussell, 2)
    CameraSetFOV(80)
    CameraSetXYZ(235.07718, 6.766103, 6.505191, 234.1353, 6.554569, 6.765789)
    PedFollowPath(gRussell, PATH._RUSSELLTOGATE, 0, 1, CB_RussellNIS)
    SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 9, "jumbo")
    while gCurrentRussellNode ~= PathGetLastNode(PATH._RUSSELLTOGATE) do
        Wait(0)
    end
    local x, y, z = GetPointFromPointList(POINTLIST._6_03_GATEXYZ, 1)
    PedFaceXYZ(gRussell, x, y, z, 0)
    Wait(10)
    PedSetActionNode(gRussell, "/Global/6_02/HeadButt/HeadButt_AnticStart", "Act/Conv/6_02.act")
    Wait(4000)
    CameraSetFOV(80)
    CameraSetXYZ(225.26263, 6.327565, 6.599787, 226.20638, 6.022959, 6.727721)
    SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 20, "jumbo")
    Wait(2500)
    PedFaceObjectNow(gPlayer, gEdgar, 2)
    PedFaceObjectNow(gPeds[1], gPlayer, 2)
    PedFaceObjectNow(gPeds[2], gPlayer, 2)
    PedFaceObjectNow(gEdgar, gPlayer, 2)
    CameraSetFOV(40)
    CameraSetXYZ(231.01746, 8.849008, 7.747287, 231.31964, 7.91919, 7.537743)
    PedSetActionNode(gPlayer, "/Global/6_02/SchoolGatesNIS/Jimmy/Jimmy02", "Act/Conv/6_02.act")
    F_PlaySpeechWait(gPlayer, "M_6_03", 22, "jumbo", false, false)
    PedFaceObject(gRussell, gPlayer, 3, 1, false, false)
    PedStop(gEdgar)
    PedClearObjectives(gEdgar)
    PedMoveToPoint(gEdgar, 3, POINTLIST._6_03_DODEST, 5, nil, 0.3, true)
    PedMoveToPoint(gPeds[1], 3, POINTLIST._6_03_DODEST, 1, nil, 0.3, true)
    PedMoveToPoint(gPeds[2], 3, POINTLIST._6_03_DODEST, 2, nil, 0.3, true)
    UnLoadAnimationGroup("NIS_6_03")
    AreaDisableCameraControlForTransition(false)
    PedSetAsleep(gPlayer, false)
    F_MakePlayerSafeForNIS(false)
    SoundEnableSpeech_ActionTree()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    CameraReset()
    CameraReturnToPlayer()
    TextPrint("6_03_OBJ00", 4, 1)
end

function F_UpdateGlobalHatred()
    PedSetTypeToTypeAttitude(4, 1, 0)
    PedSetTypeToTypeAttitude(2, 1, 0)
    PedSetTypeToTypeAttitude(5, 1, 0)
    PedSetTypeToTypeAttitude(1, 13, 1)
    PedSetTypeToTypeAttitude(1, 4, 0)
    PedSetTypeToTypeAttitude(2, 4, 0)
    PedSetTypeToTypeAttitude(5, 4, 0)
    PedSetTypeToTypeAttitude(4, 13, 1)
    PedSetTypeToTypeAttitude(1, 2, 0)
    PedSetTypeToTypeAttitude(4, 2, 0)
    PedSetTypeToTypeAttitude(5, 2, 0)
    PedSetTypeToTypeAttitude(2, 13, 1)
    PedSetTypeToTypeAttitude(1, 5, 0)
    PedSetTypeToTypeAttitude(2, 5, 0)
    PedSetTypeToTypeAttitude(4, 5, 0)
    PedSetTypeToTypeAttitude(5, 13, 1)
    DisablePOI(true, true)
    AreaSetPopulationSexGeneration(false, true)
    AreaOverridePopulation(14, 0, 3, 3, 0, 3, 3, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
    PedSetGlobalAttitude_Rumble(true)
end

function CB_RussellNIS(pedId, pathId, nodeId)
    gCurrentRussellNode = nodeId
end

function F_SetupBosses()
    bNerdBoss = nil
    bGreaserBoss = nil
    bJockBoss = nil
    bPreppyBoss = nil
end

function F_PlayerEnteredNerdBossArea()
end

function F_UpdateBosses()
    if bNerdBoss == nil and gNerdThread == nil and shared.g6_03_NerdsAlive == false then
        --print("NERD BOSS CREATE THREAD!")
        gNerdThread = CreateThread("T_MonitorNerdBoss")
    end
    if bGreaserBoss == nil and gGreaserThread == nil and shared.g6_03_GreasersAlive == false then
        --print("GREASER BOSS CREATE THREAD!")
        gGreaserThread = CreateThread("T_MonitorGreaserBoss")
    end
    if bJockBoss == nil and gJockThread == nil and shared.g6_03_JocksAlive == false then
        --print("JOCK BOSS CREATE THREAD!")
        gJockThread = CreateThread("T_MonitorJockBoss")
    end
    if bPreppyBoss == nil and gPreppyThread == nil and shared.g6_03_PreppiesAlive == false then
        --print("PREPPY BOSS CREATE THREAD!")
        gPreppyThread = CreateThread("T_MonitorPreppyBoss")
    end
    if not bPlayingLowIntensityMusic and AreaGetVisible() == 0 then
        bPlayingLowIntensityMusic = true
        SoundPlayInteractiveStreamLocked("MS_StreetFightLargeLow_Boxing.rsm", 0.8)
    end
end

function T_MonitorNerdBoss()
    bNerdBoss = 0
    local lackey1, lackey2
    local bPedsAreDead = false
    local nTableEntry = 0
    bUpdatePlayerLoc = false
    --print("NERD BOSS FIGHT")
    while AreaGetVisible() == 13 or AreaIsLoading() do
        Wait(100)
        if bNerdBoss == 0 then
            --print("WTF??, THIS IS EXECUTING MULTIPLE TIMES???")
            bPlayingLowIntensityMusic = false
            SoundPlayInteractiveStreamLocked("MS_StreetFightLargeHigh_Boxing.rsm", 0.85)
            LoadPedModels({
                215,
                8,
                11
            })
            LoadWeaponModels({ 301, 299 })
            LoadAnimationGroup("NIS_6_03")
            LoadAnimationGroup("4_04_FUNHOUSEFUN")
            bNerdBoss = PedCreatePoint(215, POINTLIST._GARAGEROOF, 2)
            lackey1 = PedCreatePoint(8, POINTLIST._GARAGEROOF, 1)
            lackey2 = PedCreatePoint(11, POINTLIST._GARAGEROOF, 3)
            PedSetWeapon(lackey1, 301, 5)
            PedSetWeapon(lackey2, 299, 1)
            F_CleanupAllBlips()
            AddBlipForChar(bNerdBoss, 1, 2, 4)
            AddBlipForChar(lackey1, 1, 2, 4)
            AddBlipForChar(lackey2, 1, 2, 4)
            F_ExecuteNerdNIS(lackey1, lackey2)
            SoundFadeWithCamera(true)
            MusicFadeWithCamera(true)
        elseif not bPedsAreDead and not bUpdatePlayerLoc then
            if PedIsDead(bNerdBoss) and PedIsDead(lackey1) and PedIsDead(lackey2) then
                bPedsAreDead = true
            end
            if bPedsAreDead and gMissionStage == "running" then
                UnLoadAnimationGroup("4_04_FUNHOUSEFUN")
                UnLoadAnimationGroup("NIS_6_03")
                ModelNotNeeded(10)
                ModelNotNeeded(8)
                ModelNotNeeded(11)
                ModelNotNeeded(301)
                ModelNotNeeded(299)
                AreaSetDoorLocked("DT_GYM_DOORL", false)
                AreaSetDoorLocked("DT_POOL_DOORL", false)
                AreaSetDoorLocked("GYML_DOORR", false)
                AreaSetDoorLocked("POOL_DOORR", false)
                AreaDisableCameraControlForTransition(false)
                AreaClearAllPeds()
                AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                DisablePOI(true, true)
                bNerdBoss = false
                F_LeaderKOd()
                ClearTextQueue()
                bUpdatePlayerLoc = true
                F_CompleteMissionObjective("6_03_OBJ03")
                F_RestoreAllBlips()
            end
        end
    end
    F_CleanupFire()
    shared.g6_03_NerdsAlive = nil
    F_UpdateGlobalHatred()
    --print("Nerd boss battle done!")
    collectgarbage()
end

function T_MonitorGreaserBoss()
    --print("CREATING GREASER BOSS!!")
    bGreaserBoss = 0
    local lackey1, lackey2
    local bPedsAreDead = false
    local nTableEntry = 0
    bUpdatePlayerLoc = false
    --print("GREASER BOSS FIGHT")
    while AreaGetVisible() == 35 or AreaIsLoading() do
        Wait(100)
        if bGreaserBoss == 0 then
            --print("WTF??, THIS IS EXECUTING MULTIPLE TIMES???")
            bPlayingLowIntensityMusic = false
            SoundPlayInteractiveStreamLocked("MS_StreetFightLargeHigh_Boxing.rsm", 0.8)
            LoadPedModels({
                217,
                21,
                22
            })
            LoadWeaponModels({ 303 })
            LoadAnimationGroup("NIS_6_03")
            LoadAnimationGroup("CHEER_COOL1")
            bGreaserBoss = PedCreatePoint(217, POINTLIST._GIRLSDORM, 3)
            lackey1 = PedCreatePoint(21, POINTLIST._GIRLSDORM, 1)
            lackey2 = PedCreatePoint(22, POINTLIST._GIRLSDORM, 2)
            PedSetWeapon(lackey1, 303, 999)
            PedSetWeapon(lackey2, 303, 999)
            F_CleanupAllBlips()
            AddBlipForChar(bGreaserBoss, 4, 26, 4)
            AddBlipForChar(lackey1, 4, 26, 4)
            AddBlipForChar(lackey2, 4, 26, 4)
            F_ExecuteGreaserNIS(lackey1, lackey2)
            SoundFadeWithCamera(true)
            MusicFadeWithCamera(true)
        elseif not bPedsAreDead and not bUpdatePlayerLoc then
            if PedIsDead(bGreaserBoss) and PedIsDead(lackey1) and PedIsDead(lackey2) then
                bPedsAreDead = true
            end
            if bPedsAreDead and gMissionStage == "running" then
                UnLoadAnimationGroup("NIS_6_03")
                UnLoadAnimationGroup("CHEER_COOL1")
                ModelNotNeeded(23)
                ModelNotNeeded(21)
                ModelNotNeeded(22)
                ModelNotNeeded(303)
                AreaSetDoorLocked("DT_GDORM_DOORL", false)
                AreaSetDoorLocked("GDORM_UPPERDOORSTORAGE", false)
                AreaSetDoorLocked("GDORM_DOORR", false)
                AreaSetDoorLocked("DT_GDORM_DOORLEXIT", false)
                AreaDisableCameraControlForTransition(false)
                AreaClearAllPeds()
                AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                DisablePOI(true, true)
                bGreaserBoss = false
                F_LeaderKOd()
                ClearTextQueue()
                bUpdatePlayerLoc = true
                F_CompleteMissionObjective("6_03_OBJ01")
                F_RestoreAllBlips()
            end
        end
    end
    shared.g6_03_GreasersAlive = nil
    F_UpdateGlobalHatred()
    collectgarbage()
end

function T_MonitorJockBoss()
    bJockBoss = 0
    local lackey1, lackey2
    local bPedsAreDead = false
    local nTableEntry = 0
    bUpdatePlayerLoc = false
    --print("JOCK BOSS FIGHT")
    while AreaGetVisible() == 9 or AreaIsLoading() do
        Wait(100)
        if bJockBoss == 0 then
            --print("WTF??, THIS IS EXECUTING MULTIPLE TIMES???")
            bPlayingLowIntensityMusic = false
            SoundPlayInteractiveStreamLocked("MS_StreetFightLargeHigh_Boxing.rsm", 0.8)
            AreaClearAllPeds()
            AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            DisablePOI(true, true)
            LoadPedModels({
                216,
                12,
                18
            })
            LoadWeaponModels({ 300 })
            LoadAnimationGroup("NIS_6_03")
            LoadAnimationGroup("CHEER_COOL3")
            bJockBoss = PedCreatePoint(216, POINTLIST._LIBPEDS, 1)
            lackey1 = PedCreatePoint(12, POINTLIST._LIBPEDS, 2)
            lackey2 = PedCreatePoint(18, POINTLIST._LIBPEDS, 3)
            PedSetWeapon(lackey1, 300, 1)
            PedSetWeapon(lackey2, 300, 1)
            F_CleanupAllBlips()
            AddBlipForChar(bJockBoss, 2, 26, 4)
            AddBlipForChar(lackey1, 2, 26, 4)
            AddBlipForChar(lackey2, 2, 26, 4)
            F_ExecuteJockNIS(lackey1, lackey2)
            SoundFadeWithCamera(true)
            MusicFadeWithCamera(true)
        elseif not bPedsAreDead and not bUpdatePlayerLoc then
            if PedIsDead(bJockBoss) and PedIsDead(lackey1) and PedIsDead(lackey2) then
                bPedsAreDead = true
            end
            if bPedsAreDead and gMissionStage == "running" then
                UnLoadAnimationGroup("NIS_6_03")
                UnLoadAnimationGroup("CHEER_COOL3")
                ModelNotNeeded(19)
                ModelNotNeeded(12)
                ModelNotNeeded(18)
                ModelNotNeeded(300)
                AreaSetDoorLocked("ESCDOORL", false)
                AreaSetDoorLocked("DT_LIBRARYEXITR", false)
                AreaDisableCameraControlForTransition(false)
                AreaClearAllPeds()
                AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                DisablePOI(true, true)
                bJockBoss = false
                F_LeaderKOd()
                ClearTextQueue()
                bUpdatePlayerLoc = true
                F_CompleteMissionObjective("6_03_OBJ04")
                F_RestoreAllBlips()
            end
        end
    end
    F_CleanupFire()
    shared.g6_03_JocksAlive = nil
    F_UpdateGlobalHatred()
    collectgarbage()
end

function T_MonitorPreppyBoss()
    bPreppyBoss = 0
    local lackey1, lackey2
    local bPedsAreDead = false
    local nTableEntry = 0
    bUpdatePlayerLoc = false
    --print("PREP BOSS FIGHT")
    while AreaGetVisible() == 32 or AreaIsLoading() do
        Wait(100)
        if bPreppyBoss == 0 then
            --print("WTF??, THIS IS EXECUTING MULTIPLE TIMES???")
            bPlayingLowIntensityMusic = false
            SoundPlayInteractiveStreamLocked("MS_StreetFightLargeHigh_Boxing.rsm", 0.85)
            LoadPedModels({
                218,
                35,
                32
            })
            LoadWeaponModels({ 302 })
            LoadAnimationGroup("NIS_6_03")
            bPreppyBoss = PedCreatePoint(218, POINTLIST._HARRINGTONHOUSE, 2)
            lackey1 = PedCreatePoint(32, POINTLIST._HARRINGTONHOUSE, 1)
            lackey2 = PedCreatePoint(35, POINTLIST._HARRINGTONHOUSE, 3)
            PedSetWeapon(lackey1, 302, 1)
            BlipRemove(gObjectiveBlips.gPreppies)
            F_CleanupAllBlips()
            AddBlipForChar(bPreppyBoss, 5, 26, 4)
            AddBlipForChar(lackey1, 5, 26, 4)
            AddBlipForChar(lackey2, 5, 26, 4)
            F_ExecutePreppyNIS(lackey1, lackey2)
            SoundFadeWithCamera(true)
            MusicFadeWithCamera(true)
        elseif not bPedsAreDead and not bUpdatePlayerLoc then
            if PedIsDead(bPreppyBoss) and PedIsDead(lackey1) and PedIsDead(lackey2) then
                bPedsAreDead = true
            end
            if bPedsAreDead and gMissionStage == "running" then
                UnLoadAnimationGroup("NIS_6_03")
                ModelNotNeeded(37)
                ModelNotNeeded(35)
                ModelNotNeeded(32)
                ModelNotNeeded(302)
                AreaSetDoorLocked("DT_PREPTOMAIN", false)
                AreaDisableCameraControlForTransition(false)
                AreaClearAllPeds()
                AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                DisablePOI(false, false)
                bPreppyBoss = false
                F_LeaderKOd()
                ClearTextQueue()
                bUpdatePlayerLoc = true
                F_CompleteMissionObjective("6_03_OBJ02")
                F_RestoreAllBlips()
            end
        end
    end
    shared.g6_03_PreppiesAlive = nil
    F_UpdateGlobalHatred()
    collectgarbage()
end

function T_MonitorBarriers()
    local barriersVisible = false
    while gMissionStage == "running" do
        if PlayerIsInTrigger(TRIGGER._INDUSTRIALGATES) then
            if not barriersVisible then
                GeometryInstance("inBarricade01", true, 79.5555, -465.53, 4.48682, false)
                GeometryInstance("inBarricade02", true, 51.0747, -416.872, 1.88779, false)
                barriersVisible = true
            end
        else
            barriersVisible = barriersVisible and false
        end
        Wait(0)
    end
    collectgarbage()
end

function F_UpdateGates()
    if not PAnimIsOpen(TRIGGER._TSCHOOL_PARKINGGATE) then
        PAnimOpenDoor(TRIGGER._TSCHOOL_PARKINGGATE)
    end
end

function F_UpdateCops()
    local cops = {}
    while mission == "running" do
        if PlayerIsInTrigger(TRIGGER._POWERSTATIONTRIG) and table.getn(cops) == 0 then
            local ped = PedCreatePoint(83, POINTLIST._COPS, 3)
            table.insert(cops, ped)
            PedSetPedToTypeAttitude(ped, 3, 0)
            local ped = PedCreatePoint(97, POINTLIST._COPS, 4)
            table.insert(cops, ped)
            PedSetPedToTypeAttitude(ped, 3, 0)
            local ped = PedCreatePoint(83, POINTLIST._COPS, 5)
            table.insert(cops, ped)
            PedSetPedToTypeAttitude(ped, 3, 0)
        elseif table.getn(cops) > 0 then
        end
    end
end

function F_ExecuteNerdNIS(lackey1, lackey2)
    F_MakeDropOutsAmbient()
    while not shared.g6_03_AreaReady do
        Wait(0)
    end
    shared.g6_03_AreaReady = false
    F_AddMissionObjective("6_03_OBJ03", false)
    F_RemoveMissionObjective("6_03_OBJ00")
    F_RemoveMissionObjective("6_03_OBJLAST")
    F_EnableRussell(false)
    F_MagicalJasonsByRobertoTransition(13, POINTLIST._GARAGEROOF, 4, true)
    PedSetPosPoint(gRussell, POINTLIST._GARAGEROOF, 5)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(true)
    AreaSetDoorLocked("DT_GYM_DOORL", true)
    AreaSetDoorLocked("DT_POOL_DOORL", true)
    AreaSetDoorLocked("GYML_DOORR", true)
    AreaSetDoorLocked("POOL_DOORR", true)
    gFireEffects[1] = F_CreateFire(TRIGGER._6_03_NISNERD01, "BarrelFire")
    gFireEffects[2] = F_CreateFire(TRIGGER._6_03_NISNERD02, "boilerfire2")
    gFireEffects[3] = F_CreateFire(TRIGGER._6_03_NISNERD03, "SmokeStackBLK")
    gFireEffects[4] = F_CreateFire(TRIGGER._6_03_NISNERD04, "BarrelFire")
    gFireEffects[5] = F_CreateFire(TRIGGER._6_03_NISNERD05, "BarrelFire")
    AreaClearAllPeds()
    CameraSetFOV(70)
    CameraSetPath(PATH._6_03_CAM_GYM, true)
    CameraSetSpeed(0.5, 0, 0)
    CameraLookAtPath(PATH._6_03_CAM_GYMLOOK, true)
    Wait(500)
    --print("SDLKMFSDKFMKSDMFKSDMFSD")
    CameraFade(500, 1)
    SoundSetAudioFocusCamera()
    CameraSetFOV(70)
    Wait(100)
    --print("SSKDLFMSDLFMSDFMSDFMS")
    PedSetActionNode(bNerdBoss, "/Global/6_02/FactionLeaderNIS/Nerds/Cheering/Cheering01", "Act/Conv/6_02.act")
    PedSetActionNode(lackey1, "/Global/6_02/FactionLeaderNIS/Nerds/Cheering/Cheering02", "Act/Conv/6_02.act")
    PedSetActionNode(lackey2, "/Global/6_02/FactionLeaderNIS/Nerds/Cheering/Cheering03", "Act/Conv/6_02.act")
    SoundPlayScriptedSpeechEvent(lackey2, "FIGHT_WATCH", 0, "supersize")
    SoundPlayScriptedSpeechEvent(lackey1, "M_6_03", 66, "supersize")
    F_WaitForSpeech(lackey1)
    Wait(1250)
    PedMoveToPoint(gPlayer, 2, POINTLIST._LIBPEDS, 9)
    PedMoveToPoint(gRussell, 1, POINTLIST._LIBPEDS, 8)
    SoundPlayScriptedSpeechEvent(gPlayer, "M_6_03", 51, "large", true)
    Wait(1000)
    CameraSetFOV(40)
    CameraSetXYZ(-623.36285, -60.276676, 60.594265, -623.20233, -61.262047, 60.60873)
    Wait(1000)
    F_WaitForSpeech(gPlayer)
    PedStop(bNerdBoss)
    PedStop(lackey1)
    PedStop(lackey2)
    PedSetActionNode(lackey1, "/Global/6_02/FactionLeaderNIS/Nerds/Blank", "Act/Conv/6_02.act")
    PedSetActionNode(lackey2, "/Global/6_02/FactionLeaderNIS/Nerds/Blank", "Act/Conv/6_02.act")
    PedFaceObject(bNerdBoss, gPlayer, 3, 0)
    PedFaceObject(lackey1, gPlayer, 3, 0)
    PedFaceObject(lackey2, gPlayer, 3, 0)
    PedFaceObjectNow(gRussell, bNerdBoss, 2)
    PedFaceObjectNow(gPlayer, bNerdBoss, 2)
    PedLockTarget(gPlayer, bNerdBoss, 3)
    CameraSetFOV(40)
    CameraSetXYZ(-628.40564, -66.91058, 60.33899, -627.48016, -66.535164, 60.388054)
    PedSetActionNode(bNerdBoss, "/Global/6_02/FactionLeaderNIS/Nerds/Earnest01", "Act/Conv/6_02.act")
    F_PlaySpeechWait(bNerdBoss, "M_6_03", 52, "large", false, false)
    CameraSetFOV(20)
    CameraSetXYZ(-618.38586, -58.026012, 61.302357, -618.8778, -58.89509, 61.25317)
    PedSetActionNode(gPlayer, "/Global/6_02/FactionLeaderNIS/Player/Nerds/Player02", "Act/Conv/6_02.act")
    F_PlaySpeechWait(gPlayer, "M_6_03", 53, "large", false, false)
    CameraSetFOV(20)
    CameraSetXYZ(-626.2766, -66.11127, 60.93996, -625.3649, -65.700676, 60.92569)
    PedSetActionNode(bNerdBoss, "/Global/6_02/FactionLeaderNIS/Nerds/Earnest02", "Act/Conv/6_02.act")
    F_PlaySpeechWait(bNerdBoss, "M_6_03", 54, "large", false, false)
    CameraSetFOV(20)
    CameraSetXYZ(-618.38586, -58.026012, 61.302357, -618.8778, -58.89509, 61.25317)
    PedSetActionNode(gPlayer, "/Global/6_02/FactionLeaderNIS/Player/Nerds/Player03", "Act/Conv/6_02.act")
    F_PlaySpeechWait(gPlayer, "M_6_03", 55, "large", false, false)
    F_EnableRussell(true)
    CameraReset()
    CameraReturnToPlayer()
    SoundSetAudioFocusPlayer()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(false)
    DisablePunishmentSystem(true)
    PedShowHealthBar(gRussell, true, "6_03_RUSSELL", false)
    TextPrint("6_03_OBJ03", 4, 1)
    GameSetPedStat(lackey1, 0, 362)
    GameSetPedStat(lackey1, 1, 100)
    GameSetPedStat(lackey2, 0, 362)
    GameSetPedStat(lackey2, 1, 100)
    PedLockTarget(gPlayer, -1, 3)
    Wait(500)
    PedAttack(bNerdBoss, gPlayer, 1)
    PedAttack(lackey1, gRussell, 1)
    PedAttack(lackey2, gRussell, 1)
    PedAttack(lackey1, gPlayer, 1)
    PedAttack(lackey2, gPlayer, 1)
    PedAttack(gRussell, lackey2, 1)
    PedAttack(gRussell, lackey1, 1)
    PedAttack(gRussell, bNerdBoss, 1)
end

function F_ExecuteGreaserNIS(lackey1, lackey2)
    F_MakeDropOutsAmbient()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    while not shared.g6_03_AreaReady do
        Wait(0)
    end
    F_AddMissionObjective("6_03_OBJ01", false)
    F_RemoveMissionObjective("6_03_OBJ00")
    F_RemoveMissionObjective("6_03_OBJLAST")
    shared.g6_03_AreaReady = false
    F_EnableRussell(false)
    PlayerSetPosPoint(POINTLIST._GIRLSDORM, 4)
    PedSetPosPoint(gRussell, POINTLIST._GIRLSDORM, 5)
    PedFaceObjectNow(gRussell, lackey2, 2)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(true)
    AreaSetDoorOpen("DT_GDORM_DOORL", false)
    AreaSetDoorOpen("GDORM_UPPERDOORSTORAGE", false)
    AreaSetDoorOpen("GDORM_DOORR", false)
    AreaSetDoorOpen("DT_GDORM_DOORLEXIT", false)
    AreaSetDoorLocked("DT_GDORM_DOORL", true)
    AreaSetDoorLocked("GDORM_UPPERDOORSTORAGE", true)
    AreaSetDoorLocked("GDORM_DOORR", true)
    AreaSetDoorLocked("DT_GDORM_DOORLEXIT", true)
    CameraSetFOV(70)
    CameraSetPath(PATH._6_03_CAM_GDORM, true)
    CameraSetSpeed(1, 0, 0)
    CameraLookAtPath(PATH._6_03_CAM_GDORMLOOK, true)
    Wait(500)
    CameraFade(500, 1)
    CameraSetFOV(80)
    PedSetActionNode(bGreaserBoss, "/Global/6_02/FactionLeaderNIS/Greasers/JohnnyCheer", "Act/Conv/6_02.act")
    PedSetActionNode(lackey1, "/Global/6_02/FactionLeaderNIS/Greasers/Peanut", "Act/Conv/6_02.act")
    PedSetActionNode(lackey2, "/Global/6_02/FactionLeaderNIS/Greasers/Hal", "Act/Conv/6_02.act")
    SoundPlayScriptedSpeechEvent(lackey2, "BOISTEROUS", 0, "supersize")
    F_WaitForSpeech(lackey2)
    Wait(800)
    PedMoveToPoint(gPlayer, 2, POINTLIST._6_03_MOVETOPLAYER, 1)
    PedMoveToPoint(gRussell, 1, POINTLIST._6_03_MOVETOPLAYER, 2)
    Wait(1500)
    CameraSetFOV(40)
    CameraSetXYZ(-451.57382, 311.19818, -6.86422, -450.57474, 311.1691, -6.842947)
    PedFaceObject(bGreaserBoss, gPlayer, 3, 0)
    PedFaceObject(lackey1, gPlayer, 3, 0)
    PedFaceObject(lackey2, gPlayer, 3, 0)
    PedSetActionNode(gPlayer, "/Global/6_02/FactionLeaderNIS/Player/Greasers/Player01", "Act/Conv/6_02.act")
    SoundPlayScriptedSpeechEvent(gPlayer, "M_6_03", 33, "large", true)
    F_WaitForSpeech(gPlayer)
    Wait(500)
    CameraSetFOV(40)
    CameraSetXYZ(-447.61053, 310.91913, -6.696242, -448.47675, 310.42462, -6.626305)
    PedSetActionNode(bGreaserBoss, "/Global/6_02/FactionLeaderNIS/Greasers/Johnny01", "Act/Conv/6_02.act")
    SoundPlayScriptedSpeechEvent(bGreaserBoss, "M_6_03", 34, "large", true)
    F_WaitForSpeech(bGreaserBoss)
    CameraSetFOV(40)
    CameraSetXYZ(-451.57382, 311.19818, -6.86422, -450.57474, 311.1691, -6.842947)
    PedSetActionNode(gPlayer, "/Global/6_02/FactionLeaderNIS/Player/Greasers/Player02", "Act/Conv/6_02.act")
    SoundPlayScriptedSpeechEvent(gPlayer, "M_6_03", 35, "large", true)
    F_WaitForSpeech(gPlayer)
    F_EnableRussell(true)
    CameraReset()
    CameraReturnToPlayer()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(false)
    DisablePunishmentSystem(true)
    PedShowHealthBar(gRussell, true, "6_03_RUSSELL", false)
    TextPrint("6_03_OBJ01", 4, 1)
    Wait(500)
    GameSetPedStat(lackey1, 0, 362)
    GameSetPedStat(lackey1, 1, 100)
    GameSetPedStat(lackey2, 0, 362)
    GameSetPedStat(lackey2, 1, 100)
    PedAttack(bGreaserBoss, gPlayer, 1)
    PedAttack(lackey1, gRussell, 1)
    PedAttack(lackey2, gRussell, 1)
    PedAttack(lackey1, gPlayer, 1)
    PedAttack(lackey2, gPlayer, 1)
    PedAttack(gRussell, lackey1, 1)
    PedAttack(gRussell, lackey2, 1)
    PedAttack(gRussell, bGreaserBoss, 1)
end

function F_ExecutePreppyNIS(lackey1, lackey2)
    F_MakeDropOutsAmbient()
    while not shared.g6_03_AreaReady do
        --print("IN this state?")
        Wait(0)
    end
    DoublePedShadowDistance(true)
    F_AddMissionObjective("6_03_OBJ02", false)
    F_RemoveMissionObjective("6_03_OBJ00")
    F_RemoveMissionObjective("6_03_OBJLAST")
    shared.g6_03_AreaReady = false
    F_EnableRussell(false)
    PlayerSetPosPoint(POINTLIST._HARRINGTONHOUSE, 4)
    PedSetPosPoint(gRussell, POINTLIST._HARRINGTONHOUSE, 5)
    PedFaceObjectNow(gRussell, lackey2, 2)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(true)
    AreaSetDoorLocked("DT_PREPTOMAIN", true)
    CameraSetFOV(65)
    CameraSetPath(PATH._6_03_CAM_HARR, true)
    CameraSetSpeed(1, 0, 0)
    CameraLookAtPath(PATH._6_03_CAM_HARRLOOK, true)
    Wait(500)
    --print("SFDLMDSKFMSDKLFMLSMFLKSDMFLKSMFKSMFKS")
    CameraFade(500, 1)
    Wait(50)
    PedMoveToPoint(gPlayer, 2, POINTLIST._HARRINGTONHOUSE, 6)
    PedMoveToPoint(gRussell, 1, POINTLIST._HARRINGTONHOUSE, 7)
    PedSetActionNode(lackey1, "/Global/6_02/FactionLeaderNIS/Preps/Chad01", "Act/Conv/6_02.act")
    F_PlaySpeechWait(lackey1, "M_6_03", 45, "large", false)
    CameraSetFOV(30)
    CameraSetXYZ(-545.4811, 135.23799, 47.860825, -544.5277, 134.94911, 47.774487)
    PedSetActionNode(bPreppyBoss, "/Global/6_02/FactionLeaderNIS/Preps/Darby01", "Act/Conv/6_02.act")
    SoundPlayScriptedSpeechEvent(bPreppyBoss, "M_6_03", 46, "large", true)
    Wait(2000)
    CameraSetFOV(30)
    CameraSetXYZ(-535.2138, 134.00621, 47.483803, -534.3774, 133.46892, 47.590523)
    F_WaitForSpeech(bPreppyBoss)
    CameraSetFOV(30)
    CameraSetXYZ(-537.1888, 133.6532, 47.362743, -538.14264, 133.36417, 47.442993)
    PedSetActionNode(gPlayer, "/Global/6_02/FactionLeaderNIS/Player/Preps/Player01", "Act/Conv/6_02.act")
    F_PlaySpeechWait(gPlayer, "M_6_03", 47, "large", false)
    F_EnableRussell(true)
    CameraReset()
    CameraReturnToPlayer()
    DoublePedShadowDistance(false)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(false)
    DisablePunishmentSystem(true)
    PedShowHealthBar(gRussell, true, "6_03_RUSSELL", false)
    TextPrint("6_03_OBJ02", 4, 1)
    Wait(500)
    GameSetPedStat(lackey1, 0, 362)
    GameSetPedStat(lackey1, 1, 100)
    GameSetPedStat(lackey2, 0, 362)
    GameSetPedStat(lackey2, 1, 100)
    PedAttack(bPreppyBoss, gPlayer, 1)
    PedAttack(lackey1, gRussell, 1)
    PedAttack(lackey2, gRussell, 1)
    PedAttack(lackey1, gPlayer, 1)
    PedAttack(lackey2, gPlayer, 1)
    PedAttack(gRussell, lackey2, 1)
    PedAttack(gRussell, lackey1, 1)
    PedAttack(gRussell, bPreppyBoss, 1)
end

function F_ExecuteJockNIS(lackey1, lackey2)
    --print("?????SDFSDFSDF!!! 1")
    F_MakeDropOutsAmbient()
    while not shared.g6_03_AreaReady do
        Wait(0)
    end
    --print("?????SDFSDFSDF!!! 2")
    shared.g6_03_AreaReady = false
    F_AddMissionObjective("6_03_OBJ04", false)
    F_RemoveMissionObjective("6_03_OBJ00")
    F_RemoveMissionObjective("6_03_OBJLAST")
    F_EnableRussell(false)
    PlayerSetPosPoint(POINTLIST._LIBPEDS, 4)
    PedSetPosPoint(gRussell, POINTLIST._LIBPEDS, 5)
    PedFaceObjectNow(gRussell, lackey2, 2)
    --print("?????SDFSDFSDF!!!3")
    gFireEffects[1] = F_CreateFire(TRIGGER._6_03_NISJOCK01, "BarrelFire")
    gFireEffects[2] = F_CreateFire(TRIGGER._6_03_NISJOCK02, "boilerfire2")
    gFireEffects[3] = F_CreateFire(TRIGGER._6_03_NISJOCK03, "SmokeStackBLK")
    gFireEffects[4] = F_CreateFire(TRIGGER._6_03_NISJOCK04, "BarrelFire")
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(true)
    AreaSetDoorLocked("ESCDOORL", true)
    AreaSetDoorLocked("DT_LIBRARYEXITR", true)
    CameraSetFOV(70)
    CameraSetPath(PATH._6_03_CAM_LIB, true)
    CameraSetSpeed(1, 0, 0)
    CameraLookAtPath(PATH._6_03_CAM_LIBLOOK, true)
    --print("?????SDFSDFSDF!!!")
    CameraFade(500, 1)
    SoundSetAudioFocusCamera()
    Wait(100)
    PedSetActionNode(bJockBoss, "/Global/6_02/FactionLeaderNIS/Jocks/Cheering", "Act/Conv/6_02.act")
    PedSetActionNode(lackey1, "/Global/6_02/FactionLeaderNIS/Jocks/Cheering/Cheering01", "Act/Conv/6_02.act")
    PedSetActionNode(lackey2, "/Global/6_02/FactionLeaderNIS/Jocks/Cheering/Cheering01/Cheering02", "Act/Conv/6_02.act")
    SoundPlayScriptedSpeechEvent(lackey2, "M_6_03", 75, "supersize")
    Wait(2000)
    PedMoveToPoint(gPlayer, 2, POINTLIST._LIBPEDS, 6)
    PedMoveToPoint(gRussell, 1, POINTLIST._LIBPEDS, 7)
    Wait(500)
    CameraSetFOV(40)
    CameraSetXYZ(-771.9085, 191.86423, 91.44863, -772.4205, 192.723, 91.43143)
    SoundPlayScriptedSpeechEvent(gPlayer, "M_6_03", 39, "large", true)
    F_WaitForSpeech(gPlayer)
    PedStop(bJockBoss)
    PedStop(lackey1)
    PedStop(lackey2)
    PedSetActionNode(lackey1, "/Global/6_02/FactionLeaderNIS/Jocks/blank", "Act/Conv/6_02.act")
    PedSetActionNode(lackey2, "/Global/6_02/FactionLeaderNIS/Jocks/blank", "Act/Conv/6_02.act")
    PedFaceObject(bJockBoss, gPlayer, 3, 0)
    PedFaceObject(lackey1, gPlayer, 3, 0)
    PedFaceObject(lackey2, gPlayer, 3, 0)
    CameraSetFOV(40)
    CameraSetXYZ(-773.52386, 195.38268, 91.5359, -773.37354, 194.3946, 91.50741)
    PedSetActionNode(bJockBoss, "/Global/6_02/FactionLeaderNIS/Jocks/Ted01", "Act/Conv/6_02.act")
    F_PlaySpeechWait(bJockBoss, "M_6_03", 40, "large", false, false)
    CameraSetFOV(40)
    CameraSetXYZ(-772.8252, 192.53395, 91.43997, -773.26776, 193.43034, 91.4346)
    PedSetActionNode(gPlayer, "/Global/6_02/FactionLeaderNIS/Player/Jocks/Player02", "Act/Conv/6_02.act")
    F_PlaySpeechWait(gPlayer, "M_6_03", 41, "large", false, false)
    F_EnableRussell(true)
    CameraReset()
    CameraReturnToPlayer()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    SoundSetAudioFocusPlayer()
    F_MakePlayerSafeForNIS(false)
    DisablePunishmentSystem(true)
    PedShowHealthBar(gRussell, true, "6_03_RUSSELL", false)
    TextPrint("6_03_OBJ04", 4, 1)
    Wait(500)
    GameSetPedStat(lackey1, 0, 362)
    GameSetPedStat(lackey1, 1, 100)
    GameSetPedStat(lackey2, 0, 362)
    GameSetPedStat(lackey2, 1, 100)
    PedAttack(bJockBoss, gPlayer, 1)
    PedAttack(lackey1, gRussell, 1)
    PedAttack(lackey2, gRussell, 1)
    PedAttack(lackey1, gPlayer, 1)
    PedAttack(lackey2, gPlayer, 1)
    PedAttack(gRussell, lackey1, 1)
    PedAttack(gRussell, lackey2, 1)
    PedAttack(gRussell, bJockBoss, 1)
end

function F_LeaderKOd()
    if bNerdBoss == nil or bJockBoss == nil or bPreppyBoss == nil or bGreaserBoss == nil then
        TextPrint("6_03_OBJ01C", 3, 1)
    end
end

function F_CleanupAllBlips()
    if gObjectiveBlips.gNerds then
        BlipRemove(gObjectiveBlips.gNerds)
        gObjectiveBlips.gNerds = nil
    end
    if gObjectiveBlips.gJocks then
        BlipRemove(gObjectiveBlips.gJocks)
        gObjectiveBlips.gJocks = nil
    end
    if gObjectiveBlips.gPreppies then
        BlipRemove(gObjectiveBlips.gPreppies)
        gObjectiveBlips.gPreppies = nil
    end
    if gObjectiveBlips.gGreasers then
        BlipRemove(gObjectiveBlips.gGreasers)
        gObjectiveBlips.gGreasers = nil
    end
end

function F_EnableRussell(bEnable)
    if gRussell and PedIsValid(gRussell) and not PedIsDead(gRussell) then
        if bEnable then
            PedClearObjectives(gRussell)
            PedRecruitAlly(gPlayer, gRussell)
            PedSetHealth(gRussell, gPreviousRussellHealth)
            PedMakeTargetable(gRussell, false)
        else
            PedClearObjectives(gRussell)
            gPreviousRussellHealth = PedGetHealth(gRussell)
            PedDismissAlly(gPlayer, gRussell)
        end
    end
end

function F_RestoreAllBlips()
    local nBlips = 0
    if bNerdBoss == nil and gObjectiveBlips.gNerds == nil then
        gObjectiveBlips.gNerds = BlipAddPoint(POINTLIST._OBJECTIVELOCS, 0, 4)
        nBlips = nBlips + 1
    end
    if bJockBoss == nil and gObjectiveBlips.gJocks == nil then
        gObjectiveBlips.gJocks = BlipAddPoint(POINTLIST._OBJECTIVELOCS, 0, 2)
        nBlips = nBlips + 1
    end
    if bPreppyBoss == nil and gObjectiveBlips.gPreppies == nil then
        gObjectiveBlips.gPreppies = BlipAddPoint(POINTLIST._OBJECTIVELOCS, 0, 3)
        nBlips = nBlips + 1
    end
    if bGreaserBoss == nil and gObjectiveBlips.gGreasers == nil then
        gObjectiveBlips.gGreasers = BlipAddPoint(POINTLIST._OBJECTIVELOCS, 0, 1)
        nBlips = nBlips + 1
    end
    if nBlips == 1 then
        bLastLeader = true
        F_AddMissionObjective("6_03_OBJLAST", true)
    elseif 1 < nBlips then
        F_AddMissionObjective("6_03_OBJ00", true)
    end
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient, bSkip)
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while SoundSpeechPlaying() do
            if bSkip then
                if WaitSkippable(1) then
                    return true
                end
            else
                Wait(1)
            end
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while SoundSpeechPlaying() do
            if bSkip then
                if WaitSkippable(1) then
                    return true
                end
            else
                Wait(1)
            end
        end
    end
    return false
end

function F_NISDoorOpening()
    if not bGateOpen then
        return 1
    end
    return 0
end

function F_OpenSchoolGate()
    AreaSetDoorOpen(TRIGGER._TSCHOOL_PARKINGGATE, true)
    PAnimDoorStayOpen(TRIGGER._TSCHOOL_PARKINGGATE)
end

function F_MakeDropOutsAmbient()
    if gPeds[1] and PedIsValid(gPeds[1]) then
        PedMakeAmbient(gPeds[1])
        gPeds[1] = nil
    end
    if gPeds[2] and PedIsValid(gPeds[2]) then
        PedMakeAmbient(gPeds[2])
        gPeds[2] = nil
    end
    if gEdgar and PedIsValid(gEdgar) then
        PedMakeAmbient(gEdgar)
        gEdgar = nil
    end
end

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

function F_AddMissionObjective(reference, bTextPrint)
    if F_ObjectiveAlreadyGiven(reference) then
        for i, objective in tObjectiveTable do
            if objective.ref == reference then
                return objective.id
            end
        end
    end
    local objId = MissionObjectiveAdd(reference)
    table.insert(tObjectiveTable, {
        id = objId,
        ref = reference,
        bComplete = false
    })
    --print("Mission objective added! ", reference)
    if bTextPrint then
        --print("SD:FLMSDLF<SDLF<S:DF<!!!")
        TextPrint(reference, 4, 1)
    end
    return objId
end

function F_WaitForSpeech(pedID)
    --print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeech()")
    if pedID == nil then
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        while SoundSpeechPlaying(pedID) do
            Wait(0)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeech()")
end

function T_LeaveingFail()
    local bFailWarning = false
    local bGirlsCop = false
    local gCop1, gCop2, gCopCar
    while gMissionStage == "running" do
        if not bFailWarning then
            if PlayerIsInTrigger(TRIGGER._6_03_WARNFAIL01) or PlayerIsInTrigger(TRIGGER._6_03_WARNFAIL02) or PlayerIsInTrigger(TRIGGER._6_03_WARNFAIL03) then
                TextPrint("6_03_FAILWARN", 4, 1)
                if PlayerIsInTrigger(TRIGGER._6_03_WARNFAIL01) and not gCop1 then
                    gCop1 = PedCreatePoint(83, POINTLIST._6_02_COPSBACKENTRANCE, 2)
                    gCop2 = PedCreatePoint(97, POINTLIST._6_02_COPSBACKENTRANCE, 3)
                    gCopCar = VehicleCreatePoint(295, POINTLIST._6_02_COPSBACKENTRANCE, 1)
                    PedIgnoreStimuli(gCop1, true)
                    PedIgnoreStimuli(gCop2, true)
                    PedSetInvulnerable(gCop2, true)
                    PedWarpIntoCar(gCop2, gCopCar)
                    Wait(10)
                    VehicleEnableSiren(gCopCar, true)
                end
                bFailWarning = true
            elseif PlayerIsInTrigger(TRIGGER._GIRLSTRIG) and not gCop1 then
                gCop1 = PedCreatePoint(83, POINTLIST._6_02_COPSFRONTENTRANCE, 1)
                gCop2 = PedCreatePoint(97, POINTLIST._6_02_COPSFRONTENTRANCE, 3)
                gCopCar = VehicleCreatePoint(295, POINTLIST._6_02_COPSFRONTENTRANCE, 2)
                bGirlsCop = true
                PedIgnoreStimuli(gCop1, true)
                PedIgnoreStimuli(gCop2, true)
                PedSetInvulnerable(gCop2, true)
                PedWarpIntoCar(gCop2, gCopCar)
                Wait(10)
                VehicleEnableSiren(gCopCar, true)
            end
        elseif not PlayerIsInTrigger(TRIGGER._6_03_WARNFAIL01) or PlayerIsInTrigger(TRIGGER._6_03_WARNFAIL02) or PlayerIsInTrigger(TRIGGER._6_03_WARNFAIL03) then
            bFailWarning = false
            if gCop1 or gCop2 or gCopCar then
                if gCop1 and PedIsValid(gCop1) then
                    PedMakeAmbient(gCop1)
                    gCop1 = nil
                end
                if gCop2 and PedIsValid(gCop2) then
                    PedExitVehicle(gCop2)
                    PedMakeAmbient(gCop2)
                    gCop2 = nil
                end
                if gCopCar and PedIsValid(gCopCar) then
                    VehicleMakeAmbient(gCopCar, false)
                    gCopCar = nil
                end
            end
        elseif bGirlsCop and not PlayerIsInTrigger(TRIGGER._GIRLSTRIG) and (gCop1 or gCop2 or gCopCar) then
            if gCop1 and PedIsValid(gCop1) then
                PedMakeAmbient(gCop1)
                gCop1 = nil
            end
            if gCop2 and PedIsValid(gCop2) then
                PedExitVehicle(gCop2)
                PedMakeAmbient(gCop2)
                gCop2 = nil
            end
            if gCopCar and PedIsValid(gCopCar) then
                VehicleMakeAmbient(gCopCar, false)
                gCopCar = nil
            end
        end
        if PlayerIsInTrigger(TRIGGER._6_03_FAIL01) or PlayerIsInTrigger(TRIGGER._6_03_FAIL02) or PlayerIsInTrigger(TRIGGER._6_03_FAIL03) then
            gMissionStage = "failed"
            bLeftSchool = true
        end
        Wait(10)
    end
    collectgarbage()
end

function F_CreateFire(trigger, effectName)
    local fireId = FireCreate(trigger, 1000, 20, 100, 115, effectName)
    FireSetScale(fireId, 1)
    FireSetDamageRadius(fireId, 1)
    PAnimHideHealthBar(fireId)
    return fireId
end

function F_CleanupFire()
    for i, fire in gFireEffects do
        FireDestroy(fire)
    end
    gFireEffects = {}
end
