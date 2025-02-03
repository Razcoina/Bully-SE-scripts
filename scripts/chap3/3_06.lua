local gObjectiveBlip, missionStage
local missionCondition = "running"
local gAmbientEventTable = {}
local gRooftopPeds1 = {}
local bPoliceCreated1 = false
local gGreaserToPreppyAttitude, gGreaserToJockAttitude, gJockToGreaserAttitude, gPreppyToGreaserAttitude, gGreaserAttacker, gPeanut, gPeanutBike
local bPeanutOnBike = false
local bAlleyWarning = false
local failTimer = 0
local geometryTable = {}
local gMissionObjectives = {}
local bSecondFightCreated = false
local bThirdFightCreated = false
local bPlayerInArea = true
local gPeanutBlip
local nLolaMaxUnique = PedGetUniqueModelStatus(25)
local nPinkyMaxUnique = PedGetUniqueModelStatus(38)
local nPeanutMaxUnique = PedGetUniqueModelStatus(21)
local nJohnnyMaxUnique = PedGetUniqueModelStatus(23)
local nPeanutNode = -1
local bPeanutNode = false
local gVanceBlip, gPeanutBlip, gRooftopPedsBlip
ImportScript("Library/LibTrigger.lua")
local greaserTable = {}

function MissionSetup()
    MissionDontFadeIn()
    SoundStopInteractiveStream(0)
    MusicFadeWithCamera(false)
    SoundPlayInteractiveStreamLocked("MS_EpicConfrontationHigh.rsm", 0.6, 0, 500)
    PlayCutsceneWithLoad("3-06", true, true)
    DATLoad("3_06New.DAT", 2)
    DATInit()
end

function F_MissionSetup()
    SetPopulationFastCulling(true)
    POIGroupsEnabled(false)
    PedSetUniqueModelStatus(25, -1)
    PedSetUniqueModelStatus(38, -1)
    PedSetUniqueModelStatus(21, -1)
    PedSetUniqueModelStatus(23, -1)
    WeaponRequestModel(303)
    WeaponRequestModel(311)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    VehicleOverrideAmbient(0, 0, 0, 0)
    PlayerSetControl(0)
    LoadPedModels({
        24,
        27,
        29
    })
    gGreaserToPreppyAttitude = PedGetTypeToTypeAttitude(4, 5)
    gGreaserToJockAttitude = PedGetTypeToTypeAttitude(4, 2)
    gJockToGreaserAttitude = PedGetTypeToTypeAttitude(2, 4)
    gPreppyToGreaserAttitude = PedGetTypeToTypeAttitude(5, 4)
    PedSetTypeToTypeAttitude(4, 5, 0)
    PedSetTypeToTypeAttitude(4, 2, 0)
    PedSetTypeToTypeAttitude(2, 4, 0)
    PedSetTypeToTypeAttitude(2, 13, 3)
    PedSetTypeToTypeAttitude(5, 4, 0)
    PedSetTypeToTypeAttitude(5, 13, 3)
    LoadAnimationGroup("Cop_Frisk")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadAnimationGroup("IDLE_GREAS_C")
    LoadAnimationGroup("NIS_3_06")
    LoadPedModels({
        22,
        26,
        24,
        28,
        27,
        29,
        21,
        23,
        295,
        97,
        83,
        33,
        31,
        32,
        40,
        34,
        35,
        30
    })
    LoadVehicleModels({ 272 })
    LoadActionTree("Act/Conv/3_06.act")
    shared.gMissionEventFunction = F_DecideIfPOIShouldBeCreated
    shared.gDisableBusStops = true
    AreaTransitionPoint(0, POINTLIST._STARTINGPOINT, 1)
    PlayerSetControl(1)
    PedSetGlobalAttitude_Rumble(true)
    local index, simpleObject = CreatePersistentEntity("3_06BinBarr02", 525.404, -355.873, 5.53122, 0, 0)
    table.insert(geometryTable, {
        "3_06BinBarr02",
        index,
        simpleObject
    })
    index, simpleObject = CreatePersistentEntity("3_06CarBarr03", 525.512, -321.417, 4.40922, 1.00179E-5, 0)
    table.insert(geometryTable, {
        "3_06CarBarr03",
        index,
        simpleObject
    })
    index, simpleObject = CreatePersistentEntity("TrainCarA", 466.871, -247.614, 1.96113, -1.00179E-5, 0)
    table.insert(geometryTable, {
        "TrainCarA",
        index,
        simpleObject
    })
    index, simpleObject = CreatePersistentEntity("hydroSup", 516.191, -301.681, 7.78087, 180, 0)
    table.insert(geometryTable, {
        "hydroSup",
        index,
        simpleObject
    })
end

function MissionCleanup()
    shared.gDisableBusStops = false
    SoundStopInteractiveStream()
    SoundEnableInteractiveMusic(true)
    SoundEnableSpeech_ActionTree()
    SoundFadeWithCamera(true)
    UnLoadAnimationGroup("Cop_Frisk")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("IDLE_GREAS_C")
    UnLoadAnimationGroup("NIS_3_06")
    PedSetGlobalAttitude_Rumble(false)
    SetPopulationFastCulling(false)
    POIGroupsEnabled(true)
    shared.gMissionEventFunction = nil
    if gVanceBlip then
        BlipRemove(gVanceBlip)
        gVanceBlip = nil
    end
    if gPeanutBlip then
        BlipRemove(gPeanutBlip)
        gPeanutBlip = nil
    end
    if gRooftopPedsBlip then
        BlipRemove(gRooftopPedsBlip)
        gRooftopPedsBlip = nil
    end
    RegisterTriggerEventHandler(TRIGGER._AMBIENTEVENT1, 0, nil)
    RegisterTriggerEventHandler(TRIGGER._AMBIENTEVENT1, 3, nil)
    RegisterTriggerEventHandler(TRIGGER._AMBIENTEVENT2, 0, nil)
    RegisterTriggerEventHandler(TRIGGER._AMBIENTEVENT2, 3, nil)
    TextPrintString("", 1, 1)
    PedHideHealthBar()
    AreaRevertToDefaultPopulation()
    PlayerSetInvulnerable(false)
    DATUnload(2)
    PedSetUniqueModelStatus(25, nLolaMaxUnique)
    PedSetUniqueModelStatus(38, nPinkyMaxUnique)
    PedSetUniqueModelStatus(21, nPeanutMaxUnique)
    PedSetUniqueModelStatus(23, nJohnnyMaxUnique)
    F_RemoveObjectiveBlip()
    if gPeanutBike and VehicleIsValid(gPeanutBike) then
        VehicleMakeAmbient(gPeanutBike)
    end
    for i, entity in geometryTable do
        DeletePersistentEntity(entity[2], entity[3])
    end
    if gPeanutBlip then
        BlipRemove(gPeanutBlip)
    end
    CameraSetWidescreen(false)
end

local bGetBackObj, bPeanutObj

function F_Stage3()
    if bAlleyWarning then
        if MissionTimerHasFinished() or not PlayerIsInTrigger(TRIGGER._3_06_FailTrig) then
            ToggleHUDComponentVisibility(3, false)
            missionCondition = "LeftFight"
            if gRooftopPeds1[1] and PedIsValid(gRooftopPeds1[1]) then
                PedMakeAmbient(gRooftopPeds1[1])
            end
            if gRooftopPeds1[2] and PedIsValid(gRooftopPeds1[2]) then
                PedMakeAmbient(gRooftopPeds1[2])
            end
            if gPeanut and PedIsValid(gPeanut) then
                PedMakeAmbient(gPeanut)
            end
        elseif PlayerIsInTrigger(TRIGGER._FINALFIGHTTRIG) then
            bAlleyWarning = false
            if bGetBackObj then
                MissionObjectiveRemove(bGetBackObj)
                TextPrint("3_06_FightPeanut", 4, 1)
                bPeanutObj = MissionObjectiveAdd("3_06_FightPeanut")
                bGetBackObj = nil
            end
        end
    elseif not bAlleyWarning and not PlayerIsInTrigger(TRIGGER._FINALFIGHTTRIG) then
        bAlleyWarning = true
        MissionObjectiveRemove(bPeanutObj)
        bPeanutObj = nil
        TextPrint("3_06_Obj05", 1000000, 1)
        bGetBackObj = MissionObjectiveAdd("3_06_Obj05")
    end
    local passed = true
    if not ((not (gRooftopPeds1[1] and PedIsValid(gRooftopPeds1[1])) or PedIsDead(gRooftopPeds1[1])) and (not (gRooftopPeds1[2] and PedIsValid(gRooftopPeds1[2])) or PedIsDead(gRooftopPeds1[2]))) or gPeanut and PedIsValid(gPeanut) and not PedIsDead(gPeanut) then
        passed = false
    end
    if passed then
        SoundStopInteractiveStream()
        SoundPlayStreamNoLoop("MS_EpicConfrontationEnding.rsm", 0.6, 0, 500)
        Wait(3500)
        CameraFade(500, 0)
        Wait(500)
        if bPeanutObj then
            MissionObjectiveComplete(bPeanutObj)
        end
        if bGetBackObj then
            MissionObjectiveComplete(bGetBackObj)
        end
        missionCondition = "passed"
    end
    UpdateTextQueue()
end

function F_Stage3Setup()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    PedExitVehicle(gPeanut)
    PlayerSetControl(0)
    CameraFade(500, 0)
    Wait(501)
    F_DoPlayerAlleyNIS()
    PedMakeTargetable(gPeanut, true)
    PedAttack(gRooftopPeds1[1], gPlayer, 1)
    PedAttack(gRooftopPeds1[2], gPlayer, 1)
    PedAttack(gPeanut, gPlayer, 1)
    PedSetInvulnerable(gPeanut, false)
    PedSetHealth(gPeanut, 300)
    F_RemoveObjectiveBlip()
    PedSetActionNode(gRooftopPeds1[1], "/Global/3_06/CreateAuthFight", "Act/Conv/3_06.act")
    TextPrint("3_06_FightPeanut", 4, 1)
    MissionObjectiveComplete(gMissionObjectives[2])
    bPeanutObj = MissionObjectiveAdd("3_06_FightPeanut")
    failTimer = 0
    missionStage = F_Stage3
end

function F_Stage2()
    if (GetTimer() - gPeanutTimer) / 1000 > 300 then
        SoundPlayMissionEndMusic(false, 10)
        MissionFail(false, false, false)
    end
    if PlayerIsInTrigger(TRIGGER._3_06_FIGHTTRIG) or PlayerIsInTrigger(TRIGGER._3_06_FailTrig) and (gRooftopPeds1[1] and PedIsValid(gRooftopPeds1[1]) and PedGetWhoHitMeLast(gRooftopPeds1[1]) == gPlayer or gRooftopPeds1[2] and PedIsValid(gRooftopPeds1[2]) and PedGetWhoHitMeLast(gRooftopPeds1[2]) == gPlayer or gPeanut and PedIsValid(gPeanut) and PedGetWhoHitMeLast(gPeanut) == gPlayer) then
        PedSetAsleep(gPeanut, true)
        PedSetStationary(gPeanut, true)
        missionStage = F_Stage3Setup
    end
    if not bThirdFightCreated and PlayerIsInTrigger(TRIGGER._THIRDFIGHT) then
        bThirdFightCreated = true
        local gPrep1 = PedCreatePoint(31, POINTLIST._3_06_PREPS, 1)
        local gPrep2 = PedCreatePoint(32, POINTLIST._3_06_PREPS, 2)
        local gGreaser1 = PedCreatePoint(26, POINTLIST._3_06_GREASERS, 1)
        local gGreaser2 = PedCreatePoint(24, POINTLIST._3_06_GREASERS, 2)
        local gGreaser4 = PedCreatePoint(29, POINTLIST._3_06_GREASERS, 3)
        PedAttack(gPrep1, gGreaser1, 1)
        PedAttack(gGreaser1, gPrep1, 1)
        PedAttack(gPrep2, gGreaser2, 1)
        PedAttack(gGreaser2, gPrep2, 1)
        PedAttack(gGreaser4, gPlayer, 1)
        PedMakeAmbient(gPrep1)
        PedMakeAmbient(gPrep2)
        PedMakeAmbient(gGreaser1)
        PedMakeAmbient(gGreaser2)
        PedMakeAmbient(gGreaser4)
    end
end

function F_Stage2Setup()
    gVance = PedCreatePoint(27, POINTLIST._FINALFIGHT, 3)
    table.insert(gRooftopPeds1, gVance)
    table.insert(gRooftopPeds1, PedCreatePoint(24, POINTLIST._FINALFIGHT, 4))
    table.insert(gRooftopPeds1, gPeanut)
    PedSetStationary(gRooftopPeds1[1], true)
    PedSetStationary(gRooftopPeds1[2], true)
    PedSetAsleep(gRooftopPeds1[1], true)
    PedSetAsleep(gRooftopPeds1[2], true)
    TextPrint("3_06_PENTFLLW", 4, 1)
    MissionObjectiveComplete(gMissionObjectives[1])
    table.insert(gMissionObjectives, MissionObjectiveAdd("3_06_PENTFLLW"))
    missionStage = F_Stage2
end

function F_PeanutRun()
    MissionTimerStop()
    BlipRemove(gPeanutBlip)
    F_AddObjectiveBlip("CHAR", gPeanut, 4, 4)
    bPeanutOnBike = true
    PedIgnoreStimuli(gPeanut, true)
    PedStop(gPeanut)
    PedLockTarget(gPeanut, -1)
    gPeanutTimer = GetTimer()
    PedMoveToPoint(gPeanut, 2, POINTLIST._FINALFIGHT, 5)
end

function F_Stage1()
    if bSecondFightCreated and gPeanut and (PlayerIsInAreaObject(gPeanut, 2, 20, 0) or PedIsHit(gPeanut, 2, 1000) and PedGetWhoHitMeLast(gPeanut) == gPlayer) then
        MissionTimerStop()
        ToggleHUDComponentVisibility(3, false)
        F_PeanutRun()
        missionStage = F_Stage2Setup
    end
    if gGreaserAttacker ~= nil and PedIsValid(gGreaserAttacker) and (PlayerIsInAreaObject(gGreaserAttacker, 2, 15, 0) or PedIsHit(gGreaserAttacker, 2, 1000) and PedGetWhoHitMeLast(gGreaserAttacker) == gPlayer) then
        F_RemoveObjectiveBlip()
        PedClearObjectives(gGreaserAttacker)
        PedAttack(gGreaserAttacker, gPlayer, 3)
        PedMakeAmbient(gGreaserAttacker)
        PedSetInvulnerable(gGreaserAttacker, false)
        gGreaserAttacker = nil
    end
    if not PlayerIsInTrigger(TRIGGER._3_06_INNERAREA) then
        if bPlayerInArea then
            bPlayerInArea = false
            TextPrint("3_06_GetBackRumble", 4, 1)
        end
    elseif not bPlayerInArea then
        bPlayerInArea = true
        TextPrint("", 1, 1)
    end
    if not PlayerIsInTrigger(TRIGGER._3_06_OUTERAREA) then
        missionCondition = "LeftFight"
    end
    if not bSecondFightCreated and PlayerIsInTrigger(TRIGGER._STAG2TRIG) then
        bSecondFightCreated = true
        local gPrep1 = PedCreatePoint(31, POINTLIST._3_06_PREPS, 1)
        local gPrep2 = PedCreatePoint(32, POINTLIST._3_06_PREPS, 2)
        local gGreaser1 = PedCreatePoint(29, POINTLIST._3_06_GREASERS, 1)
        local gGreaser2 = PedCreatePoint(24, POINTLIST._3_06_GREASERS, 2)
        local gGreaser4 = PedCreatePoint(26, POINTLIST._3_06_GREASERS, 3)
        PedAttack(gPrep1, gGreaser1, 1)
        PedAttack(gGreaser1, gPrep1, 1)
        PedAttack(gPrep2, gGreaser2, 1)
        PedAttack(gGreaser2, gPrep2, 1)
        PedAttack(gGreaser4, gPlayer, 1)
        PedMakeAmbient(gPrep1)
        PedMakeAmbient(gPrep2)
        PedMakeAmbient(gGreaser1)
        PedMakeAmbient(gGreaser2)
        PedMakeAmbient(gGreaser4)
    end
end

function F_Stage1Setup()
    AreaSetTriggerMonitoringRules(TRIGGER._AMBIENTEVENT1, true)
    AreaSetTriggerMonitoringRules(TRIGGER._AMBIENTEVENT2, true)
    PlayerSetControl(1)
    CameraReset()
    CameraReturnToPlayer()
    Wait(100)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    VehicleOverrideAmbient(0, 0, 0, 0)
    local gPrep1 = PedCreatePoint(31, POINTLIST._INITIALPREPS, 1)
    local gPrep2 = PedCreatePoint(32, POINTLIST._INITIALPREPS, 2)
    local gGreaser1 = PedCreatePoint(26, POINTLIST._INTRONIS, 7)
    local gGreaser2 = PedCreatePoint(24, POINTLIST._INTRONIS, 8)
    gGreaserAttacker = PedCreatePoint(28, POINTLIST._INTRONIS, 10)
    PedAttack(gPrep1, gGreaser1, 1)
    PedAttack(gGreaser1, gPrep1, 1)
    PedAttack(gPrep2, gGreaser2, 1)
    PedAttack(gGreaser2, gPrep2, 1)
    PedAttack(gGreaserAttacker, gPrep2, 1)
    PedSetInvulnerable(gGreaserAttacker, true)
    MissionTimerStart(300)
    Wait(1000)
    CameraFade(500, 1)
    Wait(501)
    PedMakeAmbient(gPrep1)
    PedMakeAmbient(gPrep2)
    PedMakeAmbient(gGreaser1)
    PedMakeAmbient(gGreaser2)
    TextPrint("3_06_Obj01", 4, 1)
    table.insert(gMissionObjectives, MissionObjectiveAdd("3_06_Obj01"))
    gPeanut = PedCreatePoint(21, POINTLIST._3_06_GREASERS, 4)
    PedMakeTargetable(gPeanut, false)
    PedSetInvulnerable(gPeanut, true)
    PedIgnoreStimuli(gPeanut, true)
    gPeanutBike = VehicleCreatePoint(272, POINTLIST._3_06_PEANUTBIKE)
    PedPutOnBike(gPeanut, gPeanutBike)
    Wait(10)
    gPeanutBlip = BlipAddPoint(POINTLIST._3_06_GREASERS, 0, 4, 4)
    ToggleHUDComponentVisibility(3, true)
    Wait(1000)
    AreaOverridePopulation(8, 0, 0, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0)
    missionStage = F_Stage1
end

function main()
    F_MissionSetup()
    RegisterGlobalEventHandler(7, F_PedWasAttacked, 1)
    missionStage = F_Stage1Setup
    while missionCondition == "running" do
        missionStage()
        F_ManageAmbientEvents()
        F_CheckPlayerLocation()
        Wait(0)
    end
    if missionCondition == "LeftFight" then
        MissionFail(false, true, "3_06_LEFTTRIG")
        SoundPlayMissionEndMusic(false, 10)
    elseif missionCondition == "PeanutRan" then
        --print("PEANUT RAN AWAY!")
        MissionFail(false, true, "3_06_PEANUTRAN")
        SoundPlayMissionEndMusic(false, 10)
    elseif missionCondition == "failed" then
        --print("SOMETHING ELSE?!")
        SoundPlayMissionEndMusic(false, 10)
        MissionFail(true, false, false)
    elseif missionCondition == "passed" then
        SoundStopInteractiveStream()
        if not IsMissionCompleated("3_08_PostDummy") then
            AreaLoadSpecialEntities("Christmas", false)
            MissionForceCompleted("3_08_PostDummy")
            MissionSuccessCountInc("3_08_PostDummy")
        end
        MissionSucceed(false, false, false)
    end
end

function F_CheckPlayerLocation()
    if MissionTimerHasFinished() then
        missionCondition = "PeanutRan"
        MissionTimerStop()
        ToggleHUDComponentVisibility(3, false)
    end
    if missionStage == F_Stage2 then
        if failTimer ~= 0 then
            if PlayerIsInTrigger(TRIGGER._306POORAREA) then
                failTimer = 0
                MissionTimerStop()
                ToggleHUDComponentVisibility(3, false)
            end
        elseif failTimer == 0 and not PlayerIsInTrigger(TRIGGER._306POORAREA) then
            failTimer = GetTimer()
            TextPrint("3_06_Warn02", 4, 1)
            MissionTimerStart(15)
            ToggleHUDComponentVisibility(3, true)
        end
    end
end

function F_ManageAmbientEvents()
    if PlayerIsInTrigger(TRIGGER._AMBIENTEVENT1) and not bPoliceCreated1 then
        F_CreateAmbientEvent1(nil, gPlayer)
    elseif not PlayerIsInTrigger(TRIGGER._AMBIENTEVENT1) and bPoliceCreated1 then
        F_CleanupAmbientEvent1(nil, gPlayer)
    end
end

function F_CreateAmbientEvent1(triggerId, pedId)
    --print("Create event!")
    if not bPoliceCreated1 and pedId == gPlayer then
        --print("Event was created!")
        bPoliceCreated1 = true
        local copCar, cop1, cop2, cop3, vandal1
        copCar = VehicleCreatePoint(295, POINTLIST._AMBIENTEVENT1, 1)
        VehicleEnableEngine(copCar, true)
        VehicleEnableSiren(copCar, true)
        cop1 = F_CreateTetheredEntity(97, POINTLIST._AMBIENTEVENT1, 2, 10)
        cop2 = F_CreateTetheredEntity(83, POINTLIST._AMBIENTEVENT1, 3, 10)
        vandal1 = F_CreateCopBustPeds(29, POINTLIST._AMBIENTEVENT1, 4)
        cop3 = F_CreateCopBustPeds(83, POINTLIST._AMBIENTEVENT1, 5)
        PedSetPosPoint(vandal1, POINTLIST._AMBIENTEVENT1, 4)
        PedSetPosPoint(cop1, POINTLIST._AMBIENTEVENT1, 2)
        PedSetPosPoint(cop2, POINTLIST._AMBIENTEVENT1, 3)
        PedWarpIntoCar(cop2, copCar)
        PedIgnoreStimuli(cop2, true)
        PedSetCheap(cop2, true)
        PedSetPosPoint(cop3, POINTLIST._AMBIENTEVENT1, 5)
        gAmbientEventTable = {
            tCopCar = copCar,
            tCop1 = cop1,
            tCop2 = cop2,
            tCop3 = cop3,
            tVandal = vandal1
        }
        PedLockTarget(cop3, vandal1, 1)
        PedLockTarget(vandal1, cop3, 1)
        PedSetActionNode(cop3, "/Global/3_06/Frisk/GrappleAttempt", "Act/Conv/3_06.act")
        CreateThread("T_Cop1Thread")
    end
end

function F_CleanupAmbientEvent1(triggerId, pedId)
    if bPoliceCreated1 and pedId == gPlayer then
        if gAmbientEventTable.tCopCar and VehicleIsValid(gAmbientEventTable.tCopCar) then
            VehicleDelete(gAmbientEventTable.tCopCar)
        end
        if gAmbientEventTable.tCop1 and PedIsValid(gAmbientEventTable.tCop1) then
            PedDelete(gAmbientEventTable.tCop1)
        end
        if gAmbientEventTable.tCop2 and PedIsValid(gAmbientEventTable.tCop2) then
            PedDelete(gAmbientEventTable.tCop2)
        end
        if gAmbientEventTable.tCop3 and PedIsValid(gAmbientEventTable.tCop3) then
            PedDelete(gAmbientEventTable.tCop3)
        end
        if gAmbientEventTable.tVandal and PedIsValid(gAmbientEventTable.tVandal) then
            PedDelete(gAmbientEventTable.tVandal)
        end
        gAmbientEventTable = {}
        collectgarbage()
    end
end

function T_Cop1Thread()
    while bPoliceCreated1 == true do
        if gAmbientEventTable.tCop1 and PedIsValid(gAmbientEventTable.tCop1) and PedGetTargetPed(gAmbientEventTable.tCop1) == gPlayer then
            PedMakeAmbient(gAmbientEventTable.tCop1)
        end
        if gAmbientEventTable.tCop2 and PedIsValid(gAmbientEventTable.tCop2) and PedGetTargetPed(gAmbientEventTable.tCop2) == gPlayer then
            PedMakeAmbient(gAmbientEventTable.tCop2)
        end
        Wait(100)
    end
    collectgarbage()
end

function F_CreateTetheredEntity(modelNum, point, pointNum, radius)
    local ped
    ped = PedCreatePoint(modelNum, point, pointNum)
    PedSetTetherToPoint(ped, point, pointNum, radius or 10)
    PedSetTetherMoveToCenter(ped, true)
    PedSetCheap(ped, true)
    PedSetUsesCollisionScripted(ped, true)
    return ped
end

function F_CreateCopBustPeds(model, point, pointNum)
    local ped = PedCreatePoint(model, point, pointNum)
    PedSetCheap(ped, true)
    PedIgnoreStimuli(ped, true)
    PedSetAsleep(ped, true)
    return ped
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

function F_SetupFinalFightPed(table)
    for i, ped in table do
        PedLockTarget(ped, gPlayer, 3)
        PedAttack(ped, gPlayer, 3)
        PedSetTetherToTrigger(ped, TRIGGER._FINALFIGHTTRIG)
    end
end

function F_CreateNISPed(model, point, pointNum)
    local ped = PedCreatePoint(model, point, pointNum)
    PedIgnoreStimuli(ped, true)
    PedSetInfiniteSprint(ped, true)
    PedMakeTargetable(ped, false)
    PedSetInvulnerable(ped, true)
    return ped
end

function F_DoPlayerAlleyNIS()
    AreaClearAllVehicles()
    SoundFadeWithCamera(false)
    SoundStopInteractiveStream()
    SoundPlayStream("MS_EpicConfrantation_NIS.rsm", 0.6, 0, 500)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    --print("ASLEEP?!?!")
    if gPeanut and PedIsValid(gPeanut) then
        PedDelete(gPeanut)
    end
    if gRooftopPeds1[2] and PedIsValid(gRooftopPeds1[2]) then
        PedDelete(gRooftopPeds1[2])
    end
    if gVance and PedIsValid(gVance) then
        PedDelete(gVance)
    end
    gRooftopPeds1 = {}
    gVance = PedCreatePoint(27, POINTLIST._FINALFIGHT, 2)
    gPeanut = PedCreatePoint(21, POINTLIST._FINALFIGHT, 5)
    table.insert(gRooftopPeds1, gVance)
    table.insert(gRooftopPeds1, PedCreatePoint(24, POINTLIST._FINALFIGHT, 3))
    table.insert(gRooftopPeds1, gPeanut)
    PedMakeTargetable(gPlayer, false)
    PedSetAsleep(gPeanut, true)
    PedSetAsleep(gRooftopPeds1[2], true)
    PedSetAsleep(gVance, true)
    PlayerSetPosPoint(POINTLIST._FINALFIGHTNIS, 4)
    Wait(10)
    PedSetPosPoint(gPeanut, POINTLIST._FINALFIGHT, 5)
    PedSetPosPoint(gRooftopPeds1[2], POINTLIST._FINALFIGHT, 3)
    PedSetPosPoint(gVance, POINTLIST._FINALFIGHT, 2)
    Wait(10)
    PedClearWeapon(gPeanut, 323)
    PedClearWeapon(gRooftopPeds1[2], 323)
    PedClearWeapon(gVance, 323)
    Wait(10)
    PedFaceObject(gPeanut, gPlayer, 3, 0)
    PedFaceObject(gVance, gPlayer, 3, 0)
    PedFaceObject(gRooftopPeds1[2], gPlayer, 3, 0)
    PedFaceObject(gPlayer, gPeanut, 2, 1)
    PedLockTarget(gPlayer, gPeanut)
    PedLockTarget(gPeanut, gPlayer)
    CameraSetFOV(70)
    CameraSetXYZ(547.71875, -464.30264, 8.510677, 547.0781, -464.96863, 8.129441)
    Wait(10)
    PedMakeTargetable(gPeanut, true)
    CameraFade(500, 1)
    PedMoveToPoint(gPlayer, 0, POINTLIST._FINALFIGHTNIS, 3)
    F_PlaySpeechWait(gPlayer, "M_3_06", 39, "large")
    CameraSetFOV(30)
    CameraSetXYZ(543.55676, -470.79813, 5.353992, 543.4832, -469.80347, 5.424284)
    CameraSetFOV(30)
    local x, y, z = GetPointFromPointList(POINTLIST._FINALFIGHTNIS, 1)
    PedFaceXYZ(gPlayer, x, y, z, 0)
    PedSetActionNode(gPeanut, "/Global/3_06/GreaserIdles", "Act/Conv/3_06.act")
    PedSetActionNode(gRooftopPeds1[2], "/Global/3_06/GreaserIdles", "Act/Conv/3_06.act")
    PedSetActionNode(gVance, "/Global/3_06/GreaserNIS", "Act/Conv/3_06.act")
    F_PlaySpeechWait(gVance, "M_3_06", 40, "large")
    CameraFade(500, 0)
    Wait(501)
    SoundPlayInteractiveStreamLocked("MS_EpicConfrontationHighPart2.rsm", 0.6, 0, 500)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    if bLeftSide then
        PlayerSetPosPoint(POINTLIST._FINALFIGHTNIS, 2)
    else
        PlayerSetPosPoint(POINTLIST._3_06_RIGHTSIDE, 1)
    end
    PedLockTarget(gPlayer, -1)
    PedLockTarget(gPeanut, -1)
    Wait(500)
    PedFaceObjectNow(gPlayer, gVance, 2)
    PedFaceObjectNow(gVance, gPlayer, 2)
    PedFaceObjectNow(gPeanut, gPlayer, 2)
    PedFaceObjectNow(gRooftopPeds1[2], gPlayer, 2)
    Wait(10)
    PedSetActionNode(gVance, "/Global/3_06/IdleOneFrame", "Act/Conv/3_06.act")
    PedSetActionNode(gPeanut, "/Global/3_06/IdleOneFrame", "Act/Conv/3_06.act")
    PedSetActionNode(gRooftopPeds1[2], "/Global/3_06/IdleOneFrame", "Act/Conv/3_06.act")
    CameraReset()
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    SoundEnableSpeech_ActionTree()
    gVanceBlip = AddBlipForChar(gVance, 4, 26, 4)
    gPeanutBlip = AddBlipForChar(gPeanut, 4, 26, 4)
    gRooftopPedsBlip = AddBlipForChar(gRooftopPeds1[2], 4, 26, 4)
    CameraFade(500, 1)
    Wait(501)
    PlayerSetControl(1)
    PedMakeTargetable(gPlayer, true)
    PedSetAsleep(gPeanut, false)
    PedSetAsleep(gRooftopPeds1[2], false)
    PedSetAsleep(gVance, false)
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume)
    local skip = false
    SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
    while not (not SoundSpeechPlaying() or skip) do
        skip = WaitSkippable(1)
    end
    return skip
end
