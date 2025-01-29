local gDefenders = {}
local gSidelines = {}
local gMissionActive = true
local gDamonHealth = 0
local PedsKOD = 0
local gNextStage = false
local gPasserA = { id = 1, speech = 6 }
local gPasserB = { id = 3, speech = 8 }
local gPauseThread = false
local gTedCanAttack = false
local gPassing = false
local tblPeds = {}
local tetherTable = {
    TRIGGER._TETHERD104,
    TRIGGER._TETHERD105
}
local gReinforcementModels = {
    231,
    111,
    109,
    232
}
local gTethers = {}
local respawnTimer01 = false
local respawnTimer02 = false
local gRespawnTime = 10000
local gRespawnTimeB = 25000
local gRespawnTimeB = 25000
local gSecondReinforcement = false
local gDroppedHealth = false

function MissionInit()
    LoadModels({ 331, 400 }, true)
    LoadModels({
        134,
        110,
        112,
        231,
        111,
        109,
        232
    })
    LoadActionTree("Act/Anim/J_Damon.act")
    LoadActionTree("/Act/Conv/4_B2.act")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadAnimationGroup("NIS_4_B2")
    LoadAnimationGroup("SGIRL_S")
    F_BossTeamCreate()
    AreaTransitionPoint(0, POINTLIST._PLAYERSTART, nil, true)
    AreaClearAllVehicles()
    F_DeleteAllBikes()
    PedSaveWeaponInventorySnapshot(gPlayer)
    PedClearAllWeapons(gPlayer)
    PlayerSetPosPoint(POINTLIST._PLAYERSTART)
    PlayerSetControl(0)
    gMaxPlayerHealth = PedGetMaxHealth(gPlayer)
    if PlayerGetHealth() < gMaxPlayerHealth then
        PlayerSetHealth(gMaxPlayerHealth)
    end
    PedSetFlag(gPlayer, 58, true)
    OldFootballLOD = GetWeaponLOD(331)
    SetWeaponLOD(331, 120)
    idObj1, bObj1 = CreatePersistentEntity("tschl_uvCrowd", 1.82043, -72.9178, 3.7707, 0, 0)
    idObj2, bObj2 = CreatePersistentEntity("scBoss_wall", -27.5637, -73.6518, -8.30141, 0, 0)
    idObj3, bObj3 = CreatePersistentEntity("SC_GatCooler", -7.70793, -63.9239, 1.64374, 0, 0)
    GeometryInstance("NOGO_tschoolSOP", true, -67.8271, -116.257, 9.42621, false)
    boardBad01, boardBad02 = CreatePersistentEntity("SC_JocksLEDbad", -53.1448, -73.6493, 6.34204, 0, 0)
    DisablePOI(true, true)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
end

function MissionSetup()
    shared.bFootBallFieldEnabled = false
    SoundEnableInteractiveMusic(false)
    DisablePunishmentSystem(true)
    MissionDontFadeIn()
    ClothingBackup()
    ClothingSetPlayerOutfit("MascotNoHead")
    ClothingBuildPlayer()
    DisablePunishmentSystem(true)
    ClockSet(22, 0)
    PlayCutsceneWithLoad("4-B2", true)
    WeatherSet(2, true)
    NonMissionPedGenerationDisable()
    DATLoad("4_B2.DAT", 2)
    DATInit()
end

function MissionCleanup()
    shared.bFootBallFieldEnabled = true
    DisablePunishmentSystem(false)
    if PedIsValid(gDefenders[1]) then
        PedSetFlag(gDefenders[1], 58, false)
    end
    DisablePunishmentSystem(true)
    WeatherRelease()
    CameraSetWidescreen(false)
    DATUnload(2)
    UnLoadAnimationGroup("NIS_4_B2")
    UnLoadAnimationGroup("SGIRL_S")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    NonMissionPedGenerationEnable()
    CameraAllowChange(true)
    FollowCamDefaultFightShot()
    CameraReturnToPlayer()
    CameraReset()
    PedRestoreWeaponInventorySnapshot(gPlayer)
    PedDeleteWeaponInventorySnapshot(gPlayer)
    SoundFadeoutAmbience(500)
    SoundStopInteractiveStream()
    SoundEnableSpeech_ActionTree()
    SoundEnableInteractiveMusic(true)
    PlayerIgnoreTargeting(false)
    PedHideHealthBar()
    PedSetFlag(gPlayer, 58, false)
    PedSetAIButes("Default")
    if gMissionSucceed then
        ClothingSetPlayerOutfit("Uniform")
    else
        ClothingRestore()
    end
    ClothingBuildPlayer()
    SetWeaponLOD(331, OldFootballLOD)
    DeletePersistentEntity(idObj1, bObj1)
    DeletePersistentEntity(idObj2, bObj2)
    DeletePersistentEntity(idObj3, bObj3)
    F_MakePlayerSafeForNIS(false)
    AreaRevertToDefaultPopulation()
    EnablePOI(true, true)
    GeometryInstance("NOGO_tschoolSOP", false, -67.8271, -116.257, 9.42621, true)
    DeletePersistentEntity(boardBad01, boardBad02)
end

function F_BossTeamCreate()
    gTed = PedCreatePoint(110, POINTLIST._TED)
    PedSetTetherToPoint(gTed, POINTLIST._TED, 1, 2)
    PedOverrideStat(gTed, 34, 0)
    PedSetHealth(gTed, 5000)
    PedSetPedToTypeAttitude(gTed, 13, 0)
    PedSetFlag(gTed, 68, true)
    PedSetInfiniteSprint(gTed, true)
    gDefenders[1] = PedCreatePoint(112, POINTLIST._DEFENSIVELINE01, 1)
    PedSetFlag(gDefenders[1], 58, true)
    gDefenders[2] = PedCreatePoint(231, POINTLIST._DEFENSIVELINE01, 2)
    gDefenders[3] = PedCreatePoint(232, POINTLIST._DEFENSIVELINE01, 3)
    F_SetDefender(gDefenders[1])
    F_SetDefender(gDefenders[2])
    F_SetDefender(gDefenders[3])
    gTethers[1] = TRIGGER._TETHERD101
    gTethers[2] = TRIGGER._TETHERD102
    gTethers[3] = TRIGGER._TETHERD103
    PedSetTetherToTrigger(gDefenders[1], TRIGGER._TETHERD101)
    PedSetTetherToTrigger(gDefenders[2], TRIGGER._TETHERD102)
    PedSetTetherToTrigger(gDefenders[3], TRIGGER._TETHERD103)
    gSidelines[1] = PedCreatePoint(111, POINTLIST._SIDELINE, 1)
    gSidelines[2] = PedCreatePoint(232, POINTLIST._SIDELINE, 2)
    gSidelines[3] = PedCreatePoint(231, POINTLIST._SIDELINE, 3)
    gSidelines[4] = PedCreatePoint(109, POINTLIST._SIDELINE, 4)
    gSidelines[5] = PedCreatePoint(231, POINTLIST._SIDELINE, 5)
    gSidelines[6] = PedCreatePoint(232, POINTLIST._SIDELINE, 6)
    gSidelines[7] = PedCreatePoint(111, POINTLIST._SIDELINE, 7)
    for i, sidePed in gSidelines do
        F_SetSideline(sidePed, true)
    end
    PedSetMaxHealth(gDefenders[1], 200)
    PedSetHealth(gDefenders[1], 200)
    gDamonHealth = PedGetMaxHealth(gDefenders[1])
    CameraSetSecondTarget(gTed)
    FollowCamSetFightShot("4B2")
    CameraSetShot(1, "4B2", true)
end

function F_CreateReinforcement()
    Wait(2000)
    local ped = PedCreatePoint(RandomTableElement(gReinforcementModels), POINTLIST._RESPAWN, 1)
    PedSetPedToTypeAttitude(ped, 3, 0)
    PedClearAllWeapons(ped)
    PedAttackPlayer(ped, 3)
    if gDroppedHealth then
        F_PedSetDropItem(ped, 362)
    end
    gDroppedHealth = not gDroppedHealth
    PedSetFlag(ped, 68, true)
    SoundPlayScriptedSpeechEvent(gTed, "M_4_B2", 13, "jumbo")
    return ped
end

function F_SetDefender(ped)
    PedSetInfiniteSprint(ped, true)
    PedClearAllWeapons(ped)
    PedSetPedToTypeAttitude(ped, 13, 0)
    F_PedSetDropItem(ped, 362)
    PedSetActionTree(ped, "/Global/J_Damon", "Act/Anim/J_Damon.act")
    PedSetFocus(ped, gPlayer)
    PedLockTarget(ped, gPlayer, 3)
    Wait(100)
    PedOverrideStat(ped, 34, 0)
    PedGuardPed(ped, gTed)
    PedSetFlag(ped, 68, false)
    AddBlipForChar(ped, 0, 26, 4)
end

function F_SetSideline(ped, isSideline, final)
    if PedIsValid(ped) and not PedIsDead(ped) then
        if not isSideline then
            PedStop(ped)
            PedClearObjectives(ped)
            PedSetFlag(ped, 68, true)
        end
        PedSetInfiniteSprint(ped, true)
        PedSetInvulnerable(ped, true)
        PedSetStationary(ped, true)
        PedIgnoreAttacks(ped, isSideline)
        PedIgnoreStimuli(ped, isSideline)
        PedSetCheap(ped, isSideline)
        PedClearAllWeapons(ped)
        PedSetPedToTypeAttitude(ped, 3, 4)
        PedSetFlag(ped, 106, false)
        PedMakeTargetable(ped, false)
        if final then
            PedMakeTargetable(ped, true)
            PedSetInvulnerable(ped, false)
            PedSetPedToTypeAttitude(ped, 13, 0)
            PedSetStationary(ped, false)
        end
    end
end

function F_Setup()
    gPetey = PedCreatePoint(134, POINTLIST._PETEY)
    F_SetSideline(gPetey, true)
    SoundPlayStream("MS_JockBossBattle.rsm", 1)
end

function main()
    MissionInit()
    F_Setup()
    gStageFunction = F_Stage01SetupIntro
    gTedCanAttack = true
    while gMissionActive do
        gStageFunction()
        Wait(0)
    end
    if gMissionSucceed then
        Wait(2000)
        --print("Mission Success")
        CameraAllowChange(true)
        CameraReturnToPlayer()
        for i, ped in gDefenders do
            if ped and PedIsValid(ped) then
                PedSetFlag(ped, 58, false)
                PedDelete(ped)
            end
        end
        for i, ped in gSidelines do
            if ped and PedIsValid(ped) then
                PedSetFlag(ped, 58, false)
                PedDelete(ped)
            end
        end
        if gPetey and PedIsValid(gPetey) then
            PedDelete(gPetey)
        end
        ModelNotNeeded(331)
        ModelNotNeeded(400)
        ModelNotNeeded(134)
        ModelNotNeeded(112)
        ModelNotNeeded(231)
        ModelNotNeeded(111)
        ModelNotNeeded(109)
        ModelNotNeeded(232)
        PlayCutsceneWithLoad("4-B2B", true)
        MissionSetAutoRestart(false)
        SetFactionRespect(2, 100)
        SetFactionRespect(1, 100)
        SoundStopInteractiveStream()
        UnlockYearbookPicture(110)
        F_UnlockYearbookReward()
        MissionSucceed(true, false, false)
    elseif gMissionFail then
        local speech = false
        if math.random(1, 100) > 50 and not PedIsDead(gDefenders[1]) then
            speech = gDefenders[1]
        end
        speech = speech or gTed
        SoundPlayScriptedSpeechEvent(speech, "VICTORY_TEAM", 0, "jumbo")
        Wait(1500)
        --print("Mission Fail")
        MinigameSetCompletion("M_FAIL", false)
        Wait(1000)
        MissionSetAutoRestart(false)
        SoundPlayMissionEndMusic(false, 10)
        MissionFail(true, true, "M_FAIL_DEAD")
    end
end

function F_Stage01SetupIntro()
    SoundPlayAmbience("FootballGameAmbience.rsm", 0.5)
    Wait(1000)
    F_MakePlayerSafeForNIS(true, true)
    CameraSetWidescreen(true)
    CameraSetFOV(40)
    CameraSetPath(PATH._INTROCAM, true)
    CameraSetSpeed(2, 2, 2)
    CameraLookAtPath(PATH._INTROLOOKAT, true)
    CameraLookAtPathSetSpeed(2, 2, 2)
    CameraFade(-1, 1)
    PedSetActionNode(gDefenders[1], "/Global/4_B2/Defensive/IntoPose", "Act/Conv/4_B2.act")
    Wait(500)
    PedSetActionNode(gDefenders[2], "/Global/4_B2/Defensive/IntoPose", "Act/Conv/4_B2.act")
    TutorialShowMessage("4_B2_Tut1", 9500, true)
    SoundPlayScriptedSpeechEvent(gDefenders[1], "FIGHT_INITIATE", 0, "jumbo")
    F_SetSideline(gSidelines[gPasserA.id], false)
    PedSetWeapon(gSidelines[gPasserA.id], 331, 1)
    PedSetPedToTypeAttitude(gTed, 13, 4)
    PedStop(gTed)
    PedClearObjectives(gTed)
    PedFaceObject(gSidelines[gPasserA.id], gTed, 2, 1)
    PedFaceObject(gTed, gSidelines[gPasserA.id], 2, 1)
    Wait(500)
    PedSetActionNode(gDefenders[3], "/Global/4_B2/Defensive/IntoPose", "Act/Conv/4_B2.act")
    Wait(1000)
    SoundPlayScriptedSpeechEvent(gTed, "FIGHT_INITIATE", 0, "jumbo")
    PedPassBall(gSidelines[gPasserA.id], gTed, 4000)
    PedReceiveBall(gTed, gSidelines[gPasserA.id], 4000)
    Wait(3000)
    F_SetSideline(gSidelines[gPasserA.id], true)
    PedClearAllWeapons(gTed)
    PedSetWeapon(gTed, 400, 1)
    PedLockTarget(gTed, gPlayer, 3)
    PedOverrideStat(gTed, 11, 100)
    PedAttackPlayer(gTed)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraReset()
    CameraDefaultFOV()
    PlayerSetControl(1)
    CameraSetSecondTarget(gTed)
    FollowCamSetFightShot("4B2")
    CameraSetShot(1, "4B2", false)
    CameraAllowChange(false)
    CreateThread("T_ForcePlayerGrapple")
    CreateThread("T_MonitorPeds")
    gObjective = MissionObjectiveAdd("4_B2_Obj1", 0, -1)
    TextPrint("4_B2_Obj1", 3, 1)
    gStageFunction = F_Stage01FirstLine
    F_MakePlayerSafeForNIS(false, true)
    DisablePunishmentSystem(true)
    PedAttackPlayer(gTed)
end

function F_Stage01FirstLine()
    if not firstShot then
        Wait(3000)
        CreateThread("T_TedGetBalls")
        firstShot = true
    end
    for i, defender in gDefenders do
        if PedIsValid(defender) and F_IsDead(defender) or not PedIsValid(defender) then
            PedsKOD = PedsKOD + 1
        end
    end
    if 0 < PedsKOD then
        F_TetherDefenders(PedsKOD, 1)
    end
    if gNextStage then
        --print("[RAUL] - Stage 01 Ends ")
        gStageFunction = F_Stage02Setup
        gPauseThread = true
        gTedCanAttack = false
        gNextStage = false
    end
    PedsKOD = 0
end

function F_Stage02Setup()
    --print("[RAUL] - INITIALIZE Stage 02 ")
    while gPassing do
        Wait(0)
    end
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true, true)
    CameraAllowChange(true)
    PedSetPosPoint(gDefenders[1], POINTLIST._DEFENSIVELINE01, 1)
    F_PedSetCameraOffsetXYZ(gDefenders[1], 1, 2.5, 2, 0, 0, 1)
    CameraAllowChange(false)
    PedIgnoreAttacks(gPlayer, true)
    if PedHasWeapon(gTed, 400) then
        PedDestroyWeapon(gTed, 400)
    end
    ObjectRemovePickupsInTrigger(TRIGGER._FOOTBALLFIELD)
    PedSetPedToTypeAttitude(gTed, 13, 4)
    gPasserA.id = 4
    gPasserA.speech = 5
    gPasserB.id = 6
    gPasserB.speech = 9
    PedSetActionNode(gTed, "/Global/4_B2/4_B2_Blank", "Act/Conv/4_B2.act")
    PedClearTether(gTed)
    PedStop(gTed)
    PedClearObjectives(gTed)
    PedClearAllWeapons(gTed)
    PedMoveToPoint(gTed, 1, POINTLIST._TED02)
    PedSetTetherToPoint(gTed, POINTLIST._TED02, 1, 2)
    local x, y, z = GetPointFromPointList(POINTLIST._PLAYERSTART, 2)
    PlayerSetPosSimple(x, y, z)
    PedSetMaxHealth(gDefenders[1], 200)
    PedSetHealth(gDefenders[1], 200)
    PedMoveToPoint(gPlayer, 1, POINTLIST._PLAYERSTART)
    PedStop(gDefenders[1])
    CameraSetFOV(40)
    PedSetActionNode(gDefenders[1], "/Global/4_B2/ReactionAnims/GetUpEasy", "/Act/Conv/4_B2.act")
    CameraSetXYZ(-26.82692, -67.17024, 1.988937, -27.018621, -68.151535, 1.986971)
    Wait(1000)
    SoundStopCurrentSpeechEvent(gDefenders[1])
    Wait(100)
    F_PlaySpeechAndWait(gDefenders[1], "LAUGH_CRUEL", 0, "jumbo", true)
    PedSetActionNode(gDefenders[1], "/Global/4_B2/ReactionAnims/GetUpEasy/GetUpEasy2", "/Act/Conv/4_B2.act")
    Wait(500)
    F_PlaySpeechAndWait(gDefenders[1], "M_4_B2", 12, "jumbo", true)
    PedSetActionNode(gDefenders[1], "/Global/J_Damon/Default_KEY/Idle", "Act/Anim/J_Damon.act")
    F_SetSideline(gSidelines[1], false, true)
    F_SetSideline(gSidelines[2], false, true)
    F_SetSideline(gSidelines[3], false, true)
    PedMoveToPoint(gSidelines[2], 1, POINTLIST._DEFENSIVELINE02, 2)
    PedMoveToPoint(gSidelines[3], 1, POINTLIST._DEFENSIVELINE02, 3)
    gDefenders[2] = gSidelines[2]
    gDefenders[3] = gSidelines[3]
    SoundPlayScriptedSpeechEvent(gTed, "M_4_B2", 13, "jumbo")
    F_SetDefender(gDefenders[1])
    F_SetDefender(gDefenders[2])
    F_SetDefender(gDefenders[3])
    PedSetTetherToTrigger(gDefenders[1], TRIGGER._TETHERD201)
    PedSetTetherToTrigger(gDefenders[2], TRIGGER._TETHERD202)
    PedSetTetherToTrigger(gDefenders[3], TRIGGER._TETHERD203)
    gTethers[1] = TRIGGER._TETHERD201
    gTethers[2] = TRIGGER._TETHERD202
    gTethers[3] = TRIGGER._TETHERD203
    local x, y, z = GetPointList(POINTLIST._TED02)
    while not PedIsInAreaXYZ(gTed, x, y, z, 2, 0) do
        Wait(0)
    end
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedFaceObject(gPlayer, gTed, 2, 0)
    PedMakeTargetable(gDefenders[1], true)
    CameraAllowChange(true)
    CameraDefaultFOV()
    CameraSetSecondTarget(gTed)
    FollowCamSetFightShot("4B2")
    CameraSetShot(1, "4B2", true)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false, true)
    DisablePunishmentSystem(true)
    PedIgnoreAttacks(gPlayer, false)
    PedSetPedToTypeAttitude(gTed, 13, 0)
    PedAttackPlayer(gSidelines[1])
    CameraAllowChange(false)
    respawnTimer01 = false
    respawnTimer02 = false
    gPauseThread = false
    gTedCanAttack = true
    gStageFunction = F_Stage02SecondLine
    DisablePunishmentSystem(true)
end

function F_Stage02SecondLine()
    for i, defender in gDefenders do
        if PedIsValid(defender) and F_IsDead(defender) or not PedIsValid(defender) then
            PedsKOD = PedsKOD + 1
        end
    end
    if 0 < PedsKOD then
        F_TetherDefenders(PedsKOD, 2)
    end
    if not respawnTimer01 and F_IsDead(gSidelines[1]) then
        --print("[RAUL] SIDELINES GUY IS NOW DEAD")
        respawnTimer01 = GetTimer()
    elseif respawnTimer01 and GetTimer() - respawnTimer01 > gRespawnTime then
        --print("[RAUL] SPAWNING A NEW GUY")
        respawnTimer01 = false
        gSidelines[1] = F_CreateReinforcement()
    end
    if gNextStage then
        --print("[RAUL] - Stage 02 Ends ")
        gStageFunction = F_Stage03Setup
        gPauseThread = true
        gTedCanAttack = false
        gNextStage = false
    end
    PedsKOD = 0
end

function F_Stage03Setup()
    while gPassing do
        Wait(0)
    end
    --print("[RAUL] - INITIALIZE Stage 03 ")
    gPasserA.id = 7
    gPasserA.speech = 6
    gPasserB = false
    CameraSetWidescreen(true)
    if PedHasWeapon(gTed, 400) then
        PedDestroyWeapon(gTed, 400)
    end
    PlayerSetControl(0)
    CameraAllowChange(true)
    F_MakePlayerSafeForNIS(true, true)
    PedSetPosPoint(gDefenders[1], POINTLIST._DEFENSIVELINE02, 1)
    PedFaceObject(gDefenders[1], gPlayer, 3, 0)
    F_PedSetCameraOffsetXYZ(gDefenders[1], 1, 2.5, 2, 0, 0, 1)
    if PedIsValid(gSidelines[1]) then
        PedDelete(gSidelines[1])
    end
    CameraAllowChange(false)
    PedIgnoreAttacks(gPlayer, true)
    PedSetActionNode(gTed, "/Global/4_B2/4_B2_Blank", "Act/Conv/4_B2.act")
    ObjectRemovePickupsInTrigger(TRIGGER._FOOTBALLFIELD)
    PedSetPedToTypeAttitude(gTed, 13, 4)
    PedStop(gTed)
    PedClearObjectives(gTed)
    PedClearTether(gTed)
    PedClearAllWeapons(gTed)
    PedMoveToPoint(gTed, 1, POINTLIST._TED03)
    PedSetTetherToPoint(gTed, POINTLIST._TED03, 1, 2)
    F_SetSideline(gSidelines[4], false, true)
    F_SetSideline(gSidelines[5], false, true)
    F_SetSideline(gSidelines[6], false, true)
    PedMoveToPoint(gSidelines[5], 1, POINTLIST._DEFENSIVELINE03, 2)
    PedMoveToPoint(gSidelines[6], 1, POINTLIST._DEFENSIVELINE03, 3)
    gDefenders[2] = gSidelines[5]
    gDefenders[3] = gSidelines[6]
    local x, y, z = GetPointFromPointList(POINTLIST._PLAYERSTART, 2)
    PlayerSetPosSimple(x, y, z)
    PedSetMaxHealth(gDefenders[1], 100)
    PedSetHealth(gDefenders[1], 100)
    PedMoveToPoint(gPlayer, 1, POINTLIST._PLAYERSTART)
    PedSetActionNode(gDefenders[1], "/Global/4_B2/ReactionAnims/GetUpHard", "/Act/Conv/4_B2.act")
    CameraSetXYZ(-27.107243, -82.0929, 1.560844, -27.50147, -83.00643, 1.659717)
    Wait(1000)
    SoundStopCurrentSpeechEvent(gDefenders[1])
    F_PlaySpeechAndWait(gDefenders[1], "BIKE_SEE_TRICK_FAIL", 0, "jumbo", true)
    SoundPlayScriptedSpeechEvent(gDefenders[1], "M_4_B2", 12, "jumbo", true)
    Wait(2000)
    PedSetActionNode(gDefenders[1], "/Global/J_Damon/Default_KEY/Idle", "Act/Anim/J_Damon.act")
    Wait(1000)
    F_SetDefender(gDefenders[1])
    F_SetDefender(gDefenders[2])
    F_SetDefender(gDefenders[3])
    gTethers[1] = TRIGGER._TETHERD301
    gTethers[2] = TRIGGER._TETHERD302
    gTethers[3] = TRIGGER._TETHERD303
    PedSetTetherToTrigger(gDefenders[1], TRIGGER._TETHERD301)
    PedSetTetherToTrigger(gDefenders[2], TRIGGER._TETHERD302)
    PedSetTetherToTrigger(gDefenders[3], TRIGGER._TETHERD303)
    PedSetFlag(gDefenders[1], 58, false)
    PedMakeTargetable(gDefenders[1], true)
    local x, y, z = GetPointList(POINTLIST._TED03)
    while not PedIsInAreaXYZ(gTed, x, y, z, 2, 0) do
        Wait(0)
    end
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedFaceObject(gPlayer, gTed, 2, 0)
    CameraAllowChange(true)
    CameraSetSecondTarget(gTed)
    FollowCamSetFightShot("4B2")
    CameraSetShot(1, "4B2", true)
    CameraSetWidescreen(false)
    CameraAllowChange(false)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false, true)
    DisablePunishmentSystem(true)
    gSecondReinforcement = F_CreateReinforcement()
    PedIgnoreAttacks(gPlayer, false)
    PedSetPedToTypeAttitude(gTed, 13, 0)
    F_SetSideline(gSidelines[4], false, true)
    PedAttackPlayer(gSidelines[4], 3)
    PedSetFocus(gSidelines[4], gPlayer)
    respawnTimer01 = false
    respawnTimer02 = false
    gTedCanAttack = true
    gPauseThread = false
    DisablePunishmentSystem(true)
    gStageFunction = F_Stage03ThirdLine
end

function F_Stage03ThirdLine()
    for i, defender in gDefenders do
        if PedIsValid(defender) and F_IsDead(defender) or not PedIsValid(defender) then
            if not gDamonLastSpeech and i == 1 then
                gDamonLastSpeech = true
                SoundPlayScriptedSpeechEvent(defender, "FIGHT_BEATEN", 0, "jumbo")
            end
            PedsKOD = PedsKOD + 1
        end
    end
    if not respawnTimer01 and F_IsDead(gSidelines[4]) then
        --print("[RAUL] SIDELINES GUY IS NOW DEAD")
        respawnTimer01 = GetTimer()
    elseif respawnTimer01 and GetTimer() - respawnTimer01 > gRespawnTimeB then
        --print("[RAUL] SPAWNING A NEW GUY")
        respawnTimer01 = false
        gSidelines[4] = F_CreateReinforcement()
    end
    if not respawnTimer02 and F_IsDead(gSecondReinforcement) then
        --print("[RAUL] SECOND SIDELINES GUY IS NOW DEAD")
        respawnTimer02 = GetTimer()
    elseif respawnTimer02 and GetTimer() - respawnTimer02 > gRespawnTimeB then
        --print("[RAUL] SPAWNING A SECOND GUY")
        respawnTimer02 = false
        gSecondReinforcement = F_CreateReinforcement()
    end
    if 0 < PedsKOD then
        F_TetherDefenders(PedsKOD, 3)
    end
    if gNextStage then
        --print("[RAUL] - Stage 03 Ends ")
        gStageFunction = F_Stage04Setup
        gPauseThread = true
        gNextStage = false
    end
    PedsKOD = 0
end

function F_Stage04Setup()
    while gPassing do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(500)
    PedSetPedToTypeAttitude(gTed, 13, 3)
    --print("[RAUL] - INITIALIZING STAGE 04 ")
    gPasserA = false
    gPasserB = false
    PedSetHealth(gTed, 5)
    PedSetMaxHealth(gTed, 5)
    CameraAllowChange(true)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    CameraAllowChange(true)
    PedSetPosPoint(gTed, POINTLIST._TED03)
    PedSetActionNode(gTed, "/Global/4_B2/4_B2_Blank", "/Act/Conv/4_B2.act")
    F_PedSetCameraOffsetXYZ(gTed, 1, 2.5, 2, 0, 0, 1)
    local x, y, z = GetPointFromPointList(POINTLIST._PLAYEREND, 1)
    PlayerSetPosSimple(x, y, z)
    if PedIsValid(gSidelines[4]) then
        PedDelete(gSidelines[4])
    end
    if PedIsValid(gSecondReinforcement) then
        PedDelete(gSecondReinforcement)
    end
    CameraAllowChange(false)
    PedClearAllWeapons(gTed)
    PedSetWeaponNow(gTed, -1, 0)
    CameraSetXYZ(-34.66981, -98.39723, 3.770149, -33.902256, -98.98998, 3.526339)
    CameraFade(500, 1)
    PedMoveToPoint(gPlayer, 1, POINTLIST._PLAYEREND, 2)
    Wait(1000)
    PedClearTether(gTed)
    PedStop(gTed)
    PedClearObjectives(gTed)
    PedIgnoreAttacks(gTed, true)
    PedIgnoreStimuli(gTed, true)
    PedSetFlag(gTed, 68, false)
    PedSetActionNode(gTed, "/Global/4_B2/4_B2_Blank", "/Act/Conv/4_B2.act")
    Wait(10)
    gTedOnPoint = false
    PedFaceObject(gPlayer, gTed, 2, 1, true)
    PedMoveToPoint(gTed, 2, POINTLIST._TEDFLEEPOINTS, 2, CbTedFleeToPoint, 1)
    SoundStopCurrentSpeechEvent(gTed)
    SoundPlayScriptedSpeechEvent(gTed, "TAUNT", 0, "xtralarge", true, true)
    Wait(1000)
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_TAUNT_FLEE", 0, "xtralarge", true)
    PedMoveToPoint(gPlayer, 1, POINTLIST._TEDFLEEPOINTS, 2)
    CameraAllowChange(true)
    CameraSetXYZ(-25.981438, -106.347115, 3.519231, -26.608736, -105.58522, 3.358158)
    Wait(1000)
    FollowCamDefaultFightShot()
    CameraReturnToPlayer(false)
    Wait(500)
    PedShowHealthBar(gTed, true, "4_B2_01", true)
    MissionObjectiveComplete(gObjective)
    gObjective2 = MissionObjectiveAdd("4_B2_Obj2", 0, -1)
    TextPrint("4_B2_Obj2", 3, 1)
    gStageFunction = F_Stage04FinalFight
    gTedFleePoint = 2
    gTX, gTY, gTZ = PedGetPosXYZ(gTed)
    DisablePunishmentSystem(true)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PlayerSetControl(1)
    SoundPlayScriptedSpeechEvent(gPetey, "M_4_B2", 1, "xtralarge", true)
    F_SetSideline(gSidelines[7], false, true)
    PedAttackPlayer(gSidelines[7], 3)
    PedSetFocus(gSidelines[7], gPlayer)
    AddBlipForChar(gTed, 0, 26, 4)
    CameraSetWidescreen(false)
end

function F_Stage04FinalFight()
    TextPrint("4_B2_Obj2", 1, 1)
    if gTedOnPoint then
        gTX, gTY, gTZ = PedGetPosXYZ(gTed)
        if GetTimer() - gTedOnPointTime > 3000 then
            --print("TED IS TAUNTING")
            PedFaceObject(gTed, gPlayer, 3, 0)
            PedSetActionNode(gTed, "/Global/4_B2/ReactionAnims/Taunt", "Act/Conv/4_B2.act")
            SoundPlayScriptedSpeechEvent(gTed, "TAUNT", 0, "supersize")
            gTedOnPointTime = GetTimer()
        end
        if PlayerIsInAreaXYZ(gTX, gTY, gTZ, 7, 0) then
            --print("PLAYER IS IN AREA")
            while PedIsPlaying(gTed, "/Global/4_B2/ReactionAnims/Taunt", true) do
                Wait(0)
            end
            gTedFleePoint = F_ChooseFleePoint(gTedFleePoint, 0)
            gTedOnPoint = false
            PedStop(gTed)
            PedClearObjectives(gTed)
            PedClearTether(gTed)
            PedLockTarget(gTed, -1)
            SoundStopCurrentSpeechEvent(gTed)
            SoundPlayScriptedSpeechEvent(gTed, "INDIGNANT", 0, "jumbo")
            PedSetPedToTypeAttitude(gTed, 13, 3)
            PedMoveToPoint(gTed, 2, POINTLIST._TEDFLEEPOINTS, gTedFleePoint, CbTedFleeToPoint, 2)
        end
    end
end

function F_ChooseFleePoint(currentPoint, timesPassed)
    local new = math.random(1, 4)
    if new == currentPoint then
        timesPassed = timesPassed + 1
        if 3 <= timesPassed then
            if new == 1 then
                move = 2
            else
                move = 1
            end
        else
            new = F_ChooseFleePoint(currentPoint, timesPassed)
        end
    end
    --print("GOING TO POINT...", new)
    return new
end

function CbTedFleeToPoint(ped)
    --print("TED GOT TO POINT")
    PedFaceObject(ped, gPlayer, 3, 0)
    PedSetActionNode(gTed, "/Global/4_B2/ReactionAnims/Taunt", "Act/Conv/4_B2.act")
    PedLockTarget(ped, gPlayer, 3)
    PedSetPedToTypeAttitude(gTed, 13, 0)
    SoundPlayScriptedSpeechEvent(gTed, "TAUNT", 0, "jumbo")
    gTedOnPoint = true
    gTedOnPointTime = GetTimer()
end

function F_TetherDefenders(noOfKOS, number)
    tetherTable[1] = TRIGGER._TETHERD104
    tetherTable[2] = TRIGGER._TETHERD105
    if not gKODOnce and noOfKOS == 1 then
        if number == 2 then
            tetherTable[1] = TRIGGER._TETHERD204
            tetherTable[2] = TRIGGER._TETHERD205
        elseif number == 3 then
            tetherTable[1] = TRIGGER._TETHERD304
            tetherTable[2] = TRIGGER._TETHERD305
        end
        local tetheredPeds = 0
        for i, defender in gDefenders do
            SoundPlayScriptedSpeechEvent(gPetey, "CONGRATULATIONS", 0, "speech")
            if PedIsValid(defender) and not F_IsDead(defender) then
                tetheredPeds = tetheredPeds + 1
                PedClearTether(defender)
                PedSetTetherToTrigger(defender, tetherTable[tetheredPeds])
            end
        end
        gKODOnce = true
    elseif not gKODTwice and noOfKOS == 2 then
        SoundPlayScriptedSpeechEvent(gPetey, "CONGRATULATIONS", 0, "speech")
        for i, defender in gDefenders do
            if PedIsValid(defender) and not F_IsDead(defender) then
                PedClearTether(defender)
            end
        end
        gKODTwice = true
    elseif noOfKOS == 3 then
        SoundPlayScriptedSpeechEvent(gPetey, "CONGRATULATIONS", 0, "jumbo")
        gNextStage = true
    end
end

function T_MonitorPeds()
    while gMissionActive do
        if F_PlayerIsDead() then
            gMissionFail = true
            gMissionActive = false
        elseif PedIsValid(gTed) and PedIsDead(gTed) then
            F_AllFlee()
            gMissionSucceed = true
            gMissionActive = false
        elseif not PedIsValid(gTed) then
            F_AllFlee()
            gMissionSucceed = true
            gMissionActive = false
        end
        Wait(10)
    end
end

function T_TedGetBalls()
    gTedStartTime = GetTimer()
    gInitialTime = true
    local currentPasser
    local randNo = 0
    local tx, ty, tz = 0, 0, 0
    while gMissionActive do
        if not gPauseThread and gTedCanAttack and (gInitialTime or GetTimer() - gTedStartTime > 2000 and DistanceBetweenPeds2D(gPlayer, gTed) > 6) then
            gInitialTime = false
            gPassing = true
            if gPasserA and gPasserB then
                if math.random(1, 100) > 50 then
                    currentPasser = gPasserA
                else
                    currentPasser = gPasserB
                end
            elseif gPasserA then
                currentPasser = gPasserA
            else
                currentPasser = false
            end
            if currentPasser then
                while PedHasWeapon(gTed, 400) and gMissionActive and gTedCanAttack do
                    Wait(0)
                end
                PedSetPedToTypeAttitude(gTed, 13, 4)
                F_SetSideline(gSidelines[currentPasser.id], false)
                Wait(500)
                PedStop(gTed)
                PedClearObjectives(gTed)
                PedSetWeapon(gSidelines[currentPasser.id], 331, 1)
                PedLockTarget(gTed, -1, 0)
                PedLockTarget(gTed, gSidelines[currentPasser.id], 0)
                PedRemoveStimulus(gTed)
                PedStop(gTed)
                PedClearObjectives(gTed)
                PedFaceObject(gSidelines[currentPasser.id], gTed, 2, 1)
                PedFaceObject(gTed, gSidelines[currentPasser.id], 2, 1)
                PedFaceObject(gTed, gSidelines[currentPasser.id], 2, 1)
                randNo = math.random(1, 100)
                if 60 < randNo then
                    SoundPlayScriptedSpeechEvent(gTed, "M_4_03", 18, "jumbo")
                elseif 30 < randNo then
                    SoundPlayScriptedSpeechEvent(gSidelines[currentPasser.id], "M_4_B2", currentPasser.speech, "jumbo")
                else
                    SoundPlayScriptedSpeechEvent(gSidelines[currentPasser.id], "TAUNT", 0, "jumbo")
                end
                Wait(1500)
                PedRemoveStimulus(gTed)
                PedStop(gTed)
                PedClearObjectives(gTed)
                if not PedHasWeapon(gTed, 331) then
                    PedPassBall(gSidelines[currentPasser.id], gTed, 4000)
                end
                PedReceiveBall(gTed, gSidelines[currentPasser.id], 4000)
                waitForBallTime = GetTimer()
                while waitForBallTime do
                    if 4000 < GetTimer() - waitForBallTime then
                        waitForBallTime = false
                    end
                    if PedHasWeapon(gTed, 331) then
                        waitForBallTime = false
                    end
                    if gPauseThread then
                        waitForBallTime = false
                    end
                    Wait(0)
                end
                ObjectRemovePickupsInTrigger(TRIGGER._FOOTBALLFIELD, 331)
                PedLockTarget(gTed, -1, 3)
                PedLockTarget(gTed, gPlayer, 3)
                Wait(500)
                tx, ty, tz = PedGetPosXYZ(gTed)
                F_ClearBalls(tx, ty, tz)
                if gTedCanAttack then
                    PedClearAllWeapons(gTed)
                    PedSetWeapon(gTed, 400, 1)
                    Wait(500)
                    PedOverrideStat(gTed, 11, 100)
                    PedAttackPlayer(gTed)
                else
                    PedClearAllWeapons(gTed)
                end
                F_SetSideline(gSidelines[currentPasser.id], true)
                PedSetPedToTypeAttitude(gTed, 13, 0)
            end
            gTedStartTime = GetTimer()
            gPassing = false
        end
        Wait(0)
    end
end

function T_ForcePlayerGrapple()
    while gMissionActive do
        if not gPauseThread and DistanceBetweenPeds2D(gPlayer, gTed) <= 6 then
            F_GrappleNow(F_FindClosestDefender())
        end
        Wait(0)
    end
end

function F_FindClosestDefender()
    local distance = 1000
    local ped
    for i, defender in gDefenders do
        if PedIsValid(defender) and not F_IsDead(defender) and distance > DistanceBetweenPeds2D(gPlayer, defender) then
            distance = DistanceBetweenPeds2D(gPlayer, defender)
            ped = defender
        end
    end
    return ped
end

function F_DamonStandUp(playSpeech)
    if PedIsPlaying(gDefenders[1], "/Global/HitTree/Standing/PostHit/BellyDown", true) then
        PedSetActionNode(gDefenders[1], "/Global/4_B2/ReactionAnims/GetUpBelly", "/Act/Conv/4_B2.act")
        if playSpeech then
            Wait(2000)
            SoundPlayScriptedSpeechEvent(gDefenders[1], "BIKE_SEE_TRICK_FAIL", 0, "jumbo")
        end
        while PedIsPlaying(gDefenders[1], "/Global/4_B2/ReactionAnims/GetUpBelly", true) do
            Wait(0)
        end
    else
        PedSetActionNode(gDefenders[1], "/Global/4_B2/ReactionAnims/GetUp", "/Act/Conv/4_B2.act")
        while PedIsPlaying(gDefenders[1], "/Global/4_B2/ReactionAnims/GetUp", true) do
            Wait(0)
        end
    end
    PedMakeTargetable(gDefenders[1], true)
end

function F_IsDead(ped)
    if PedIsDead(ped) or PedGetHealth(ped) <= 0 then
        BlipRemoveFromChar(ped)
        PedMakeTargetable(ped, false)
        return true
    end
    return false
end

function F_GrappleNow(ped)
    if ped and not PedIsPlaying(gPlayer, "/Global/J_Damon/Offense/Medium/Grapples/GrapplesAttempt/TakeDown", true) then
        PedSetAsleep(ped, true)
        --print("=======Forcing grapple======")
        PedLockTarget(ped, gPlayer, 3)
        PedSetActionNode(ped, "/Global/J_Damon/Offense/SpecialStart/StartRun", "Act/Anim/J_Damon.act")
        Wait(3500)
        SoundPlayScriptedSpeechEvent(gTed, "M_4_B2", 11, "large")
    end
end

function F_FaceRightWay(ped)
    --print("==right way==")
    if PedIsInTrigger(ped, gTethers[2]) then
        PedFaceHeading(ped, 270, 1)
    elseif PedIsInTrigger(ped, gTethers[3]) then
        PedFaceHeading(ped, 90, 1)
    else
        PedFaceHeading(ped, 0, 1)
    end
end

function F_FaceRightWayClear(ped)
    --print("==clear==")
    PedClearObjectives(ped)
    PedSetAsleep(ped, false)
end

function F_ClearBalls(x, y, z)
    PickupDestroyTypeInAreaXYZ(x, y, z, 100, 331)
end

function F_AllFlee()
    for i, ped in gSidelines do
        if PedIsValid(ped) and not F_IsDead(ped) then
            F_FleeNow(ped, gPlayer)
        end
    end
    if PedIsValid(gSecondReinforcement) and not F_IsDead(gSecondReinforcement) then
        F_FleeNow(gSecondReinforcement, gPlayer)
    end
end

function F_FleeNow(ped)
    PedStop(ped)
    PedClearObjectives(ped)
    PedSetPedToTypeAttitude(ped, 13, 3)
    PedFlee(ped, gPlayer)
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
