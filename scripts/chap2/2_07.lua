--[[ Changes to this file:
    * Modified function F_PlayerHasTrophy, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
local mission_running = true
local pedGord = -1
local pedGord_Blip, pedParker, group1
local groupProcess = group1
local gLeaveArea = true
local gJustinAllies = false
local gPrepBikeAttack = true
local path = 2
local pedRicky
local gGordShakeThatTrophy = true
local gObjective01, pedBryce
local Wave_Counter = 1
local bPrepsAlive = false
local bSpawnPreppies = true
local tblSpawnedPreppies = {}
local intCurrentPreppies = 0
local MAX_PREPPIES = 2
local PlayerNotAllowedOnPier = true
local bCanPush = true
local idPrevModel1, idPrevModel2, idPrevModel3
local tblPreppyModels = {
    31,
    32,
    34,
    40
}
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bPlayerReachedBeach = false
local bFightingGord = true
local bGordInPosition = false
local bRemovedGordsTrophy = false
local bGordIsInPosition = false
local bBryceSpawned = false
local bBryceIsInPosition = false
local bParkerAttacked = false
local bBryceAttacked = false
local bGordIsComingOut = false

function MissionSetup()
    --print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
    SoundPlayInteractiveStream("MS_StreetFightLargeLow_Boxing.rsm", 0.6)
    SoundSetMidIntensityStream("MS_StreetFightLargeMid_Boxing.rsm", 0.7)
    SoundSetHighIntensityStream("MS_StreetFightLargeHigh_Boxing.rsm", 0.7)
    shared.gCutsceneRunning = true
    PlayCutsceneWithLoad("2-07", true, true, true)
    shared.gCutsceneRunning = false
    MissionDontFadeIn()
    DATLoad("2_07_BEACHA.DAT", 2)
    DATInit()
    POIGroupsEnabled(false)
    --print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
    --print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
    shared.gRefreshRacePosters = true
    shared.gCutsceneRunning = false
    if F_PedExists(pedRicky) then
        PedSetPedToTypeAttitude(pedRicky, 13, 4)
        PedDismissAlly(gPlayer, pedRicky)
        PedMakeAmbient(pedRicky)
    end
    if PedIsValid(pedGord) then
        PedMakeAmbient(pedGord)
        PlayerSocialDisableActionAgainstPed(pedGord, 30, false)
    end
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    CounterMakeHUDVisible(false)
    gPrepBikeAttack = false
    gLeaveArea = false
    gJustinAllies = false
    UnLoadAnimationGroup("2_07BeachRumble")
    UnLoadAnimationGroup("Boxing")
    DATUnload(2)
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    AreaResetPunishmentAlertLevels()
    SoundStopInteractiveStream()
    POIGroupsEnabled(true)
    AreaSetDoorLocked("DT_trich_SafePrep", false)
    --print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
    --print("()xxxxx[:::::::::::::::> [start] main()")
    F_TableInit()
    F_SetupMission()
    F_Stage1()
    if bMissionFailed then
        SoundPlayMissionEndMusic(false, 10)
        MissionFail()
    end
    --print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_SetupMission()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
    LoadActionTree("Act/Anim/P_2_07_Gord.act")
    LoadActionTree("Act/Conv/2_07.act")
    LoadModels({
        28,
        35,
        32,
        34,
        40,
        31
    })
    LoadAnimationGroup("2_07BeachRumble")
    LoadAnimationGroup("Boxing")
    LoadAnimationGroup("F_NERDS")
    LoadAnimationGroup("Cheer_Posh1")
    while not WeaponRequestModel(385) do
        --print("===Waiting for Trophy to be loaded====")
        Wait(0)
    end
    F_CreateGord()
    AreaTransitionPoint(0, POINTLIST._2_07_PLAYER_START, 1, true)
    CameraLookAtObject(pedGord, 2, true)
    CameraReturnToPlayer()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_TableInit()
    --print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
    --print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_Stage1()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
    F_Stage1_Setup()
    F_Stage1_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
    AreaCancelStoredTransition()
    CreateThread("T_PlayerLeavesRichArea")
    AreaClearAllVehicles()
    F_DeleteAllBikes()
    pedRicky = PedCreatePoint(28, POINTLIST._2_07_GREASER_START)
    PedSetTypeToTypeAttitude(5, 13, 0)
    PedDestroyWeapon(pedRicky, 303)
    CameraFade(500, 1)
    Wait(500)
    PedSetActionTree(pedGord, "/Global/2_07_Gord", "Act/Anim/P_2_07_Gord.act")
    PedFollowPath(pedGord, PATH._2_07_GORD_RUN_TO_BEACH, 0, 2, F_GordToBeach)
    Wait(400)
    TextPrint("2_07_MOBJ_01", 2.5, 1)
    gObjective01 = MissionObjectiveAdd("2_07_MOBJ_02")
    PedMoveToPoint(pedRicky, 1, POINTLIST._2_07_GREASER_RUN)
    Wait(400)
    pedGord_Blip = AddBlipForChar(pedGord, 2, 26, 4)
    PedRecruitAlly(gPlayer, pedRicky)
    PedFaceObject(pedRicky, gPlayer, 3, 1)
    SoundPlayScriptedSpeechEvent(pedRicky, "M_2_07", 6, "large")
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
    while bLoop do
        Stage1_Objectives()
        if bMissionFailed then
            break
        end
        if bGoToStage2 then
            F_Stage2()
            break
        end
        Wait(0)
    end
end

function F_Stage2()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
    F_Stage2_Setup()
    F_Stage2_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
    AreaSetDoorLocked("DT_trich_SafePrep", true)
    gGordShakeThatTrophy = false
    SoundPlayScriptedSpeechEvent(pedGord, "M_2_07", 54, "large")
    PedSetPedToTypeAttitude(pedGord, 13, 0)
    F_SetupParker()
    Wait(1000)
    threadPreppySpawner = CreateThread("T_PrepSpawner")
    Wait(1500)
    F_SetupBryce()
    if not PlayerIsInTrigger(TRIGGER._2_07_THEDOCK) then
        PedLockTarget(pedGord, gPlayer, 3)
        PedSetStationary(pedGord, true)
        PedMakeTargetable(pedGord, true)
        if F_PedExists(pedBryce) then
            PedLockTarget(pedBryce, gPlayer, 3)
            PedAttackPlayer(pedBryce, 1)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
    while bLoop do
        Stage2_Objectives()
        if bMissionPassed or bMissionFailed then
            break
        end
        if bGoToStage3 then
            F_Stage3()
            break
        end
        Wait(0)
    end
end

function F_Stage3()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
    F_Stage3_Setup()
    F_Stage3_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
    MissionObjectiveRemove(gObjective01)
    gObjective02 = MissionObjectiveAdd("2_07_MOBJ_End")
    TextPrint("2_07_MOBJ_End", 4, 1)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
    while bLoop do
        Stage3_Objectives()
        if bMissionPassed or bMissionFailed then
            break
        end
        Wait(0)
    end
end

function Stage1_Objectives()
    if not bPlayerReachedBeach and PlayerIsInTrigger(TRIGGER._2_07_PREPPY_NINJA_TRIG) then
        bGoToStage2 = true
        bPlayerReachedBeach = true
    end
end

function Stage2_Objectives()
    if bGordIsComingOut then
        PedFollowPath(pedGord, PATH._2_07_LIGHTHOUSE_PATH, 0, 2, F_GordIsInPosition)
        bGordIsComingOut = false
    end
    if bGordIsInPosition then
        PedStop(pedGord)
        PedClearObjectives(pedGord)
        Wait(100)
        PedSetStationary(pedGord, true)
        PedFaceHeading(pedGord, 320, 0)
        PedLockTarget(pedGord, gPlayer, 3)
        PedMakeTargetable(pedGord, true)
        Wait(100)
        PedSetCheering(pedGord, true)
        PedSetTaskNode(pedGord, "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
        bGordIsInPosition = false
    end
    if bBryceIsInPosition then
        PedStop(pedBryce)
        PedClearObjectives(pedBryce)
        PedFaceHeading(pedBryce, 330, 0)
        PedLockTarget(pedBryce, gPlayer, 3)
        PedSetStationary(pedBryce, true)
        PedMakeTargetable(pedBryce, true)
        PedSetCheering(pedBryce, true)
        PedSetTaskNode(pedBryce, "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
        bBryceIsInPosition = false
    end
    if bBryceSpawned and not bBryceAttacked and PedIsHit(pedBryce, 2, 100) then
        PedSetCheering(pedBryce, false)
        PedSetTaskNode(pedBryce, "/Global/AI", "Act/AI/AI.act")
        PedClearObjectives(pedBryce)
        PedAttackPlayer(pedBryce, 3)
        PedSetFlag(pedBryce, 108, false)
        bBryceAttacked = true
    end
    if not bParkerAttacked and PedIsHit(pedParker, 2, 100) then
        if F_PedExists(pedParker) then
            RestoreBlocker(pedParker)
        end
        bParkerAttacked = true
    end
    if PlayerHasWeapon(385) then
        bPrepsAlive = false
        PedDestroyWeapon(pedGord, 385)
        PedClearAllWeapons(pedGord)
        F_MakePrepsFlee()
        F_PlayerHasTrophy()
        bMissionPassed = true
    end
    if not bFightingGord and PedIsHit(pedGord, 2, 100) then
        F_GordAttacks()
    end
    if bFightingGord and not bMissionPassed then
        if not bRemovedGordsTrophy and 0 >= PedGetHealth(pedGord) then
            PedDestroyWeapon(pedGord, 385)
            bRemovedGordsTrophy = true
        end
        if PedIsDead(pedGord) then
            bPrepsAlive = false
            if PedIsInTrigger(pedGord, TRIGGER._2_07_BEHINDDOOR) then
                Trophy = PickupCreatePoint(385, POINTLIST._2_07_trophySpawn, 1, 0, "PermanentMission")
            else
                Trophy = PickupCreateFromPed(385, pedGord, "PermanentMission")
            end
            AddBlipForPickup(Trophy, 0, 4)
            PedClearAllWeapons(pedGord)
            bGoToStage3 = true
            bFightingGord = false
        end
    end
end

function Stage3_Objectives()
    if PickupIsPickedUp(Trophy) then
        F_MakePrepsFlee()
        F_PlayerHasTrophy()
        bMissionPassed = true
    end
end

function F_MakePrepsFlee()
    local i, tblEntry
    for i, tblEntry in tblSpawnedPreppies do
        if F_PedExists(tblEntry.id) then
            PedStop(tblEntry.id)
            PedClearObjectives(tblEntry.id)
            PedMakeAmbient(tblEntry.id)
            PedFlee(tblEntry.id, gPlayer)
        end
    end
    if F_PedExists(pedGord) then
        PedMakeAmbient(pedGord)
        PedFlee(pedGord, gPlayer)
    end
    if F_PedExists(pedChad) then
        PedStop(pedChad)
        PedClearObjectives(pedChad)
        PedMakeAmbient(pedChad)
        PedFlee(pedChad, gPlayer)
    end
    if F_PedExists(pedBryce) then
        PedSetStationary(pedBryce, false)
        PedStop(pedBryce)
        PedClearObjectives(pedBryce)
        PedMakeAmbient(pedBryce)
        PedFlee(pedBryce, gPlayer)
    end
    if F_PedExists(pedParker) then
        PedSetStationary(pedParker, false)
        PedStop(pedParker)
        PedClearObjectives(pedParker)
        PedMakeAmbient(pedParker)
        PedFlee(pedParker, gPlayer)
    end
end

function F_GordAttacks()
    if not bFightingGord then
        F_RestoreGord()
        PedAttackPlayer(pedGord, 1)
        bFightingGord = true
    end
end

function F_SetupBryce()
    pedBryce = PedCreatePoint(35, POINTLIST._2_07_LAST_THUGS)
    F_PedSetDropItem(pedBryce, 362, 100, 1)
    PedSetWeaponNow(pedBryce, 312, 100)
    PedSetFlag(pedBryce, 108, true)
    PedMoveToPoint(pedBryce, 1, POINTLIST._2_07_BRYCEMOVE, 1, cbBryceInPosition)
    bBryceSpawned = true
end

function F_BryceAttack()
    if F_PedExists(pedBryce) then
        PedSetCheering(pedBryce, false)
        PedSetTaskNode(pedBryce, "/Global/AI", "Act/AI/AI.act")
        PedClearObjectives(pedBryce)
        PedAttackPlayer(pedBryce, 1)
        PedSetFlag(pedBryce, 108, false)
    end
end

function F_WavesCompleted()
    --print("()xxxxx[:::::::::::::::> [start] F_WavesCompleted()")
    PlayerNotAllowedOnPier = false
    if F_PedExists(pedParker) then
        RestoreBlocker(pedParker)
    end
    F_BryceAttack()
    if F_PedExists(pedBryce) then
        PedAttackPlayer(pedBryce, 3)
    end
    F_GordAttacks()
    --print("()xxxxx[:::::::::::::::> [finish] F_WavesCompleted()")
end

function F_PlayerHasTrophy() -- ! Modified
    --print("()xxxxx[:::::::::::::::> [start] F_PlayerHasTrophy()")
    mission_running = false
    TerminateThread(threadPreppySpawner)
    TerminateThread(threadMonitorPreppies)
    if PedIsValid(pedGord) then
        SoundPlayScriptedSpeechEvent(pedGord, "M_2_07", 55, "large", false, true)
    end
    TextPrintString("", 1, 1)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true, false)
    Wait(500)
    PlayerFaceHeading(135, 0)
    F_PedSetCameraOffsetXYZ(gPlayer, 0.2, 2, 0.8, 0, -0.2, 1.2)
    MinigameSetCompletion("M_PASS", true, 0, "2_07_UNLOCK")
    MinigameAddCompletionMsg("MRESPECT_PM10", 1)
    SoundPlayMissionEndMusic(true, 10)
    if not PlayerIsInAnyVehicle() then
        PedSetActionNode(gPlayer, "/Global/2_07/CelebrateTrophy", "Act/Conv/2_07.act")
        while PedIsPlaying(gPlayer, "/Global/2_07/CelebrateTrophy", true) do
            Wait(0)
        end
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
    end
    --[[
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    ]]-- Moved this inside previous if
    CameraFade(500, 0)
    Wait(501)
    CameraReset()
    CameraReturnToPlayer()
    SetFactionRespect(5, 15)
    if F_PedExists(pedRicky) then
        PedMakeAmbient(pedRicky)
    end
    MissionSucceed(false, false, false)
    Wait(500)
    CameraFade(500, 1)
    Wait(101)
    PlayerSetControl(1)
    --print("()xxxxx[:::::::::::::::> [finish] F_PlayerHasTrophy()")
end

function F_SetUpPeds()
    --print("()xxxxx[:::::::::::::::> [start] F_SetUpPeds()")
    LoadModels({
        32,
        28,
        35
    })
    pedRicky = PedCreatePoint(28, POINTLIST._2_07_GREASER_START)
    PedSetTypeToTypeAttitude(5, 13, 0)
    F_SetupBryce()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetUpPeds()")
end

function F_CreateGord()
    --print("()xxxxx[:::::::::::::::> [start] F_CreateGord()")
    while not PedRequestModel(30) do
        Wait(0)
    end
    pedGord = PedCreatePoint(30, POINTLIST._2_07_GORDFOOTRUN)
    local gGordsHealth = PedGetHealth(pedGord)
    PedSetWeaponNow(pedGord, 385, 1)
    PedSetInfiniteSprint(pedGord, true)
    PedMakeTargetable(pedGord, false)
    PedOverrideStat(pedGord, 31, 60)
    PedIgnoreStimuli(pedGord, true)
    PedSetFlag(pedGord, 107, true)
    PedIgnoreAttacks(pedGord, true)
    PedSetInvulnerable(pedGord, true)
    PlayerSocialDisableActionAgainstPed(pedGord, 30, true)
    PedSetDamageTakenMultiplier(pedGord, 0, 0.1)
    PedSetDamageTakenMultiplier(pedGord, 3, 0.1)
    bFightingGord = false
    --print("()xxxxx[:::::::::::::::> [finish] F_CreateGord()")
end

function F_RestoreGord()
    --print("()xxxxx[:::::::::::::::> [start] F_RestoreGord()")
    if F_PedExists(pedGord) then
        SoundPlayScriptedSpeechEvent(pedGord, "M_2_07", 56, "large")
        if not PedIsDead(pedGord) then
            PedSetDamageTakenMultiplier(pedGord, 0, 1)
            PedSetDamageTakenMultiplier(pedGord, 3, 1)
            PedIgnoreStimuli(pedGord, false)
            PedSetStationary(pedGord, false)
            PedSetCheering(pedGord, false)
            PedSetTaskNode(pedGord, "/Global/AI", "Act/AI/AI.act")
            Wait(5)
            PedLockTarget(pedGord, gPlayer, 1)
            PedAttackPlayer(pedGord, 1)
            PedMakeTargetable(pedGord, true)
            PedIgnoreAttacks(pedGord, false)
            PedSetInvulnerable(pedGord, false)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_RestoreGord()")
end

function CB_BlockerInPosition(pedid)
    --print("()xxxxx[:::::::::::::::> [start] CB_BlockerInPosition()")
    PedFaceHeading(pedid, 150, 0)
    PedSetCheering(pedid, true)
    PedSetTaskNode(pedid, "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
    PedLockTarget(pedid, gPlayer, 3)
    PedIgnoreStimuli(pedid, true)
    --print("()xxxxx[:::::::::::::::> [finish] CB_BlockerInPosition()")
end

function RestoreBlocker(pedid)
    --print("()xxxxx[:::::::::::::::> [start] RestoreBlocker()")
    PedSetEffectedByGravity(pedid, true)
    PedSetCheering(pedid, false)
    PedSetTaskNode(pedid, "/Global/AI", "Act/AI/AI.act")
    PedSetAsleep(pedid, false)
    PedSetCheap(pedid, false)
    PedSetStationary(pedid, false)
    PedRemoveStimulus(pedid, 5)
    PedClearObjectives(pedid)
    PedClearHasAggressed(pedid)
    PedIgnoreStimuli(pedid, false)
    PedAttackPlayer(pedid, 1)
    PedSetInfiniteSprint(pedid, true)
    --print("()xxxxx[:::::::::::::::> [finish] RestoreBlocker()")
end

function F_PushPlayerAway(Side)
    --print("()xxxxx[:::::::::::::::> [start] F_PushPlayerAway()")
    if Side == 1 then
        PedFaceXYZ(pedParker, 245.932, 330.695, 2.41994, 0)
        Wait(5)
        if PlayerIsInAnyVehicle() then
            PedSetActionNode(gPlayer, "/Global/2_07/HitHardFront", "Act/Conv/2_07.act")
        else
            PedSetGrappleTarget(pedParker, gPlayer)
            PedSetActionNode(pedParker, "/Global/2_07/PushPlayer/GrappleSuccess/Yay/AttackIdle", "Act/Conv/2_07.act")
        end
        Wait(800)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_PushPlayerAway()")
end

function F_SummonPreppies()
    --print("()xxxxx[:::::::::::::::> [start] F_SummonPreppies()")
    local idPreppy, idx
    local bPreppyCreated = false
    local moveToPoint, x, y, z
    local RandomPoint = 0
    local spawnLocation = POINTLIST._2_07_LAST_THUGS
    if bSpawnPreppies then
        while intCurrentPreppies < MAX_PREPPIES do
            if PlayerIsInTrigger(TRIGGER._2_07_OUTSIDEDOOR) then
                spawnLocation = POINTLIST._2_07_ALTENEMYSPAWN
            else
                spawnLocation = POINTLIST._2_07_LAST_THUGS
            end
            idPreppy = PedCreatePoint(F_GetPreppyModel(), spawnLocation)
            bPreppyCreated = true
            table.insert(tblSpawnedPreppies, {})
            idx = table.getn(tblSpawnedPreppies)
            tblSpawnedPreppies[idx].id = idPreppy
            tblSpawnedPreppies[idx].KO = false
            tblSpawnedPreppies[idx].moveToPoint = moveToPoint
            intCurrentPreppies = intCurrentPreppies + 1
            math.randomseed(GetTimer())
            RandomPoint = math.random(1, 3)
            if RandomPoint == 1 then
                if PlayerIsInTrigger(TRIGGER._2_07_REAR_PIER) then
                    PedSetNoDamageNextFall(idPreppy, true)
                    PedJump(idPreppy, POINTLIST._2_07_LAST_THUGS_JUMP, 1, 4)
                else
                    PedSetNoDamageNextFall(idPreppy, true)
                    PedJump(idPreppy, POINTLIST._2_07_LAST_THUGS_JUMP, 1, 1)
                end
                Wait(500)
                PedAttackPlayer(idPreppy, 1)
                F_PedSetDropItem(idPreppy, 362, 100, 1)
            elseif RandomPoint == 2 then
                if PlayerIsInTrigger(TRIGGER._2_07_REAR_PIER) then
                    PedSetNoDamageNextFall(idPreppy, true)
                    PedJump(idPreppy, POINTLIST._2_07_LAST_THUGS_JUMP, 1, 5)
                else
                    PedSetNoDamageNextFall(idPreppy, true)
                    PedJump(idPreppy, POINTLIST._2_07_LAST_THUGS_JUMP, 1, 2)
                end
                Wait(500)
                PedAttackPlayer(idPreppy, 1)
                F_PedSetDropItem(idPreppy, 362, 100, 1)
            elseif RandomPoint == 3 then
                if PlayerIsInTrigger(TRIGGER._2_07_REAR_PIER) then
                    PedSetNoDamageNextFall(idPreppy, true)
                    PedJump(idPreppy, POINTLIST._2_07_LAST_THUGS_JUMP, 1, 6)
                else
                    PedSetNoDamageNextFall(idPreppy, true)
                    PedJump(idPreppy, POINTLIST._2_07_LAST_THUGS_JUMP, 1, 3)
                end
                Wait(500)
                PedAttackPlayer(idPreppy, 1)
            end
            PedSetInfiniteSprint(idPreppy, true)
        end
        threadMonitorPreppies = CreateThread("T_MonitorSpawnedPreppies")
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_SummonPreppies()")
end

function F_GetPreppyModel()
    --print("()xxxxx[:::::::::::::::> [start] F_GetPreppyModel()")
    local idModel
    idModel = RandomTableElement(tblPreppyModels)
    while idModel == idPrevModel1 or idModel == idPrevModel2 or idModel == idPrevModel3 do
        idModel = RandomTableElement(tblPreppyModels)
    end
    idPrevModel3 = idPrevModel2
    idPrevModel2 = idPrevModel1
    idPrevModel1 = idModel
    --print("()xxxxx[:::::::::::::::> [finish] F_GetPreppyModel()")
    return idModel
end

function F_Activate_Group(GroupNumber)
    --print("()xxxxx[:::::::::::::::> [start] F_Activate_Group()")
    local tmpTable = {}
    LoadModels({
        31,
        40,
        35
    })
    if GroupNumber == 5 then
        tmpTable = {
            {
                point = POINTLIST._2_07P_ALLEY01,
                model = 31,
                path = nil,
                trigger = nil,
                state = nil,
                pop = true
            },
            {
                point = POINTLIST._2_07P_ALLEY02,
                model = 40,
                path = nil,
                trigger = nil,
                state = nil,
                pop = false
            },
            {
                point = POINTLIST._2_07P_ALLEY03,
                model = 35,
                path = nil,
                trigger = nil,
                state = nil,
                pop = false
            }
        }
        L_PedLoadPoint(group5, tmpTable)
        groupProcess = group5
        L_PedExec(groupProcess, PedAttack, "id", gPlayer, 0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_Activate_Group()")
end

function F_GordTheTrophyShaker()
    if gGordShakeThatTrophy then
        return 1
    else
        return 0
    end
end

function F_SetupParker()
    pedParker = PedCreatePoint(40, POINTLIST._2_07_LAST_THUGS, 1)
    PedMoveToPoint(pedParker, 1, POINTLIST._2_07_MOVEPARKER, 1, cbParkerInPosition)
end

function F_GordComesOut()
    PedSetStationary(pedGord, false)
    PedSetInvulnerable(pedGord, false)
    bGordIsComingOut = true
end

function F_GordIsInPosition(pedID, pathID, nodeID)
    --print("()xxxxx[:::::::::::::::> F_GordIsInPosition() nodeID: " .. nodeID)
    if nodeID == 1 then
        bGordIsInPosition = true
    end
end

function F_DeleteAllBikes()
    local x, y, z = PlayerGetPosXYZ()
    bikes = VehicleFindInAreaXYZ(x, y, z, 100, false)
    --print("[RAUL] - FINDING BIKES ")
    if not bikes then
        return
    end
    --print("[RAUL] - FOUND BIKES ")
    for _, bike in bikes do
        --print("[RAUL] - OTHER BIKE FOUND")
        VehicleDelete(bike)
    end
end

function T_PlayerLeavesRichArea()
    --print("()xxxxx[:::::::::::::::> [start] T_PlayerLeavesRichArea()")
    while mission_running do
        if not PlayerIsInTrigger(TRIGGER._2_07_OUT_OF_AREA) then
            mission_running = false
            if PedIsValid(pedRicky) then
                PedMakeAmbient(pedRicky)
                PedDismissAlly(gPlayer, pedRicky)
            end
            if pedParker ~= nil and PedIsValid(pedParker) then
                PedMakeAmbient(pedParker)
            end
            if pedBryce ~= nil and PedIsValid(pedBryce) then
                PedMakeAmbient(pedBryce)
            end
            SoundPlayMissionEndMusic(false, 10)
            MissionFail(false, true, "2_07_FAIL")
        elseif not PlayerIsInTrigger(TRIGGER._2_07_OUT_OF_AREA_WARN) then
            TextPrint("2_07_MOBJ_02", 1, 1)
        end
        Wait(0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] T_PlayerLeavesRichArea()")
end

function T_PlayerIsFast()
    --print("()xxxxx[:::::::::::::::> [start] T_PlayerIsFast()")
    while PlayerNotAllowedOnPier do
        if PlayerIsInTrigger(TRIGGER._2_07_THEDOCK) then
            Wave_Counter = 4
            Wait(3000)
            F_RestoreGord()
        elseif not PedIsInTrigger(pedGord, TRIGGER._2_07_THEDOCK) then
            F_RestoreGord()
            Wait(1000)
            Wave_Counter = 4
        end
        Wait(0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] T_PlayerIsFast()")
end

function T_PrepSpawner()
    --print("()xxxxx[:::::::::::::::> [start] T_PrepSpawner()")
    while not (not (Wave_Counter <= 3) or PedIsDead(pedGord)) do
        if not bPrepsAlive then
            F_SummonPreppies()
        end
        Wait(0)
    end
    F_WavesCompleted()
    --print("()xxxxx[:::::::::::::::> [finish] T_PrepSpawner()")
end

function T_MonitorSpawnedPreppies()
    --print("()xxxxx[:::::::::::::::> [start] T_MonitorSpawnedPreppies()")
    local i, tblEntry
    bPrepsAlive = true
    while bPrepsAlive do
        for i, tblEntry in tblSpawnedPreppies do
            if not tblEntry.KO and PedIsDead(tblEntry.id) then
                tblEntry.KO = true
                intCurrentPreppies = intCurrentPreppies - 1
                Wait(500)
                tblEntry.id = nil
            end
            if PlayerHasWeapon(385) then
                if tblEntry.id ~= nil then
                    PedMakeAmbient(tblEntry.id)
                end
            elseif Trophy ~= nil and PickupIsPickedUp(Trophy) and tblEntry.id ~= nil then
                PedMakeAmbient(tblEntry.id)
            end
        end
        if intCurrentPreppies <= 1 then
            if Wave_Counter == 1 then
                if PlayerIsInTrigger(TRIGGER._2_07_PREPPY_NINJA_TRIG) and PedIsValid(pedGord) then
                    SoundPlayScriptedSpeechEvent(pedGord, "M_2_07", 51, "large")
                end
                F_GordComesOut()
            elseif Wave_Counter == 2 then
                if PlayerIsInTrigger(TRIGGER._2_07_PREPPY_NINJA_TRIG) and PedIsValid(pedGord) then
                    SoundPlayScriptedSpeechEvent(pedGord, "M_2_07", 53, "large")
                end
            elseif Wave_Counter == 3 and PlayerIsInTrigger(TRIGGER._2_07_PREPPY_NINJA_TRIG) and PedIsValid(pedGord) then
                SoundPlayScriptedSpeechEvent(pedGord, "M_2_07", 52, "large")
            end
            bPrepsAlive = false
            Wave_Counter = Wave_Counter + 1
        end
        Wait(100)
    end
    --print("()xxxxx[:::::::::::::::> [finish] T_MonitorSpawnedPreppies()")
end

function F_GordToBeach(pedID, pathID, nodeID)
    if nodeID == 8 then
        bGordInPosition = true
    end
end

function cbParkerInPosition()
    CB_BlockerInPosition(pedParker)
end

function cbBryceInPosition()
    bBryceIsInPosition = true
end
