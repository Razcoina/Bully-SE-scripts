ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibTrigger.lua")
ImportScript("Library/LibPropNew.lua")
local mission_started = false
local idZoe, oldAttitude
local part1Switches = {}
local gObjs = {}
local idPrevModel1, idPrevModel2
local gPedsSpawned = 0
local gFireEffects = {
    false,
    false,
    false,
    false
}
local gLastGroupAttacked = false
local tblDropOutModels = {
    44,
    42,
    41,
    43,
    45,
    46
}

function F_GetDropOutModel()
    local idModel
    idModel = RandomTableElement(tblDropOutModels)
    while idModel == idPrevModel1 or idModel == idPrevModel2 do
        idModel = RandomTableElement(tblDropOutModels)
    end
    idPrevModel2 = idPrevModel1
    idPrevModel1 = idModel
    return idModel
end

function F_CreateDropout(pointList, noOfElements, idPOI, limit)
    local dId = {}
    noOfElements = noOfElements or 1
    for i = 1, noOfElements do
        dId[i] = PedCreatePoint(F_GetDropOutModel(), pointList, i)
        PedSetPedToTypeAttitude(dId[i], 13, 0)
        Wait(0)
        if idPOI then
            if limit then
                if limit >= i then
                    PedSetPOI(dId[i], idPOI, false)
                end
            else
                PedSetPOI(dId[i], idPOI, false)
            end
        end
        gPedsSpawned = gPedsSpawned + 1
        if 2 <= gPedsSpawned then
            PedOverrideStat(dId[i], 0, 362)
            PedOverrideStat(dId[i], 1, 100)
            gPedsSpawned = 0
        end
        PedOverrideStat(dId[i], 3, 20)
    end
    return dId
end

function DEBUG()
    if IsButtonPressed(0, 0) then
        F_CompleteMission()
    end
end

function F_PowerSwitchOff(idTrigger)
    intNumSwitchesOn = intNumSwitchesOn - 1
    if intNumSwitchesOn < 0 then
        intNumSwitchesOn = 0
    end
end

function F_CompleteMission()
    mission_started = false
    MissionDontFadeInAfterCompetion()
    gMissionSucceeded = true
    MissionSucceed(true, false, false)
end

function F_Intro()
    PlayerSetControl(0)
    AreaClearAllVehicles()
    VehicleOverrideAmbient(0, 0, 0, 0)
    SoundDisableSpeech_ActionTree()
    CameraSetWidescreen(true)
    pBikeId = PlayerGetBikeId()
    if pBikeId > -1 then
        F_PlayerExitBike(true)
        VehicleSetPosPoint(pBikeId, POINTLIST._5_07_PSTART, 2)
    end
    F_MakePlayerSafeForNIS(true)
    idRussell = PedCreatePoint(176, POINTLIST._5_07_RUSSELLBURNT, 1)
    gEffects = {}
    local x, y, z = GetPointFromPointList(POINTLIST._5_07_BikeFire, 1)
    gEffects[1] = EffectCreate("BarrelFire", x, y, z)
    local x, y, z = GetPointFromPointList(POINTLIST._5_07_BikeFire, 2)
    gEffects[2] = EffectCreate("boilerfire2", x, y, z)
    local x, y, z = GetPointFromPointList(POINTLIST._5_07_Smoke, 1)
    gEffects[3] = EffectCreate("SmokeStackBLK", x, y, z)
    local x, y, z = GetPointFromPointList(POINTLIST._5_07_Smoke, 2)
    gEffects[4] = EffectCreate("SmokeStackBLK", x, y, z)
    local x, y, z = GetPointFromPointList(POINTLIST._5_07_Smoke, 3)
    gEffects[5] = EffectCreate("BarrelFire", x, y, z)
    local x, y, z = GetPointFromPointList(POINTLIST._5_07_Smoke, 4)
    gEffects[6] = EffectCreate("boilerfire2", x, y, z)
    local x, y, z = GetPointFromPointList(POINTLIST._5_07_Smoke, 5)
    gEffects[7] = EffectCreate("SmokeStackLRG", x, y, z)
    PedSetActionNode(idRussell, "/Global/5_07a/NIS/Russell/Russell01", "Act/Conv/5_07a.act")
    AreaClearAllVehicles()
    CopCar = VehicleCreatePoint(295, POINTLIST._5_07_NIS_COPCAR, 1)
    cop = PedCreatePoint(97, POINTLIST._5_07_NIS_COPCAR, 3)
    PedWarpIntoCar(cop, CopCar)
    LoadAnimationGroup("NIS_5_07")
    CameraFade(500, 1)
    local nisRunning = true
    while nisRunning do
        nisRunning = false
        CameraSetFOV(80)
        CameraSetXYZ(140.95631, -486.0027, 2.837482, 141.90042, -485.81522, 3.108214)
        SoundPlayScriptedSpeechEvent(gPlayer, "M_5_07A", 97, "large")
        PedMoveToPoint(gPlayer, 1, POINTLIST._5_07_PSTART, 3)
        WaitSkippable(2000)
        if IsButtonPressed(7, 0) then
            break
        end
        PedFaceObject(gPlayer, idRussell, 2, 1)
        AreaClearAllVehicles()
        PedLockTarget(gPlayer, idRussell, 3)
        PedLockTarget(idRussell, gPlayer, 3)
        CameraSetFOV(40)
        CameraSetXYZ(140.74724, -481.16742, 3.697289, 141.36084, -481.95502, 3.64295)
        SoundPlayScriptedSpeechEvent(idRussell, "M_5_07A", 96, "large")
        PedSetActionNode(idRussell, "/Global/5_07a/NIS/Russell/Russell02", "Act/Conv/5_07a.act")
        while PedIsPlaying(idRussell, "/Global/5_07a/NIS/Russell/Russell02", true) do
            if IsButtonPressed(7, 0) then
                break
            end
            Wait(0)
        end
        PedLockTarget(idRussell, gPlayer)
        VehicleSetAccelerationMult(CopCar, 0.3)
        VehicleFollowPath(CopCar, PATH._5_07_COPSCHASERUSSELL, 10)
        WaitSkippable(1000)
        VehicleEnableSiren(CopCar, true)
        CameraSetFOV(40)
        CameraSetXYZ(140.32545, -480.91217, 9.82513, 141.23207, -480.5761, 9.570581)
        SoundPlayScriptedSpeechEvent(idRussell, "M_5_07A", 15, "large", true)
        if IsButtonPressed(7, 0) then
            break
        end
        WaitSkippable(2800)
        if IsButtonPressed(7, 0) then
            break
        end
        PedIgnoreStimuli(cop, true)
        CameraSetFOV(40)
        CameraSetXYZ(144.53893, -482.29083, 3.760373, 144.33101, -483.26828, 3.725718)
        PedIgnoreStimuli(idRussell, true)
        PedFollowPath(idRussell, PATH._5_07_RUSSELLRUNCOPS, 0, 2)
        WaitSkippable(1000)
        if IsButtonPressed(7, 0) then
            break
        end
        CameraSetFOV(90)
        CameraSetXYZ(149.1169, -484.5159, 6.325603, 149.53304, -483.67908, 5.969962)
        WaitSkippable(1500)
        VehicleSetAccelerationMult(CopCar, 2)
        WaitSkippable(800)
        PedMoveToPoint(idZoe, 2, POINTLIST._5_07_ZSTART, 2)
        WaitSkippable(1500)
        if IsButtonPressed(7, 0) then
            break
        end
        PedFaceObject(gPlayer, idZoe, 2, 1)
        PedFaceObject(idZoe, gPlayer, 2, 0)
        PedLockTarget(gPlayer, idZoe, 3)
        CameraSetFOV(40)
        CameraSetXYZ(144.53893, -482.29083, 3.760373, 144.33101, -483.26828, 3.725718)
        local x, y, z = GetPointFromPointList(POINTLIST._5_07_ZSTART, 2)
        while not PedIsInAreaXYZ(idZoe, x, y, z, 0.5, 0) do
            Wait(0)
        end
        PedFaceObject(gPlayer, idZoe, 2, 1)
        PedFaceObject(idZoe, gPlayer, 2, 0)
        PedLockTarget(idZoe, gPlayer)
        PedSetActionNode(idZoe, "/Global/5_07a/NIS/Zoe/Zoe01", "Act/Conv/5_07a.act")
        PedLockTarget(gPlayer, idZoe)
        if F_PlaySpeechAndWait(idZoe, "M_5_07A", 1, "large", false, true) then
            break
        end
        CameraSetXYZ(141.5715, -486.1115, 3.936998, 142.46953, -485.6812, 3.846547)
        PedSetActionNode(gPlayer, "/Global/5_07a/NIS/Player/Player01", "Act/Conv/5_07a.act")
        if F_PlaySpeechAndWait(gPlayer, "M_5_07A", 2, "large", false, true) then
            break
        end
        PedSetActionNode(idZoe, "/Global/5_07a/NIS/Zoe/Zoe02", "Act/Conv/5_07a.act")
        if F_PlaySpeechAndWait(idZoe, "M_5_07A", 3, "large", false, true) then
            break
        end
        CameraSetXYZ(145.07, -482.23526, 3.708673, 144.68994, -483.15945, 3.744788)
        PedSetActionNode(gPlayer, "/Global/5_07a/NIS/Player/Player02", "Act/Conv/5_07a.act")
        if F_PlaySpeechAndWait(gPlayer, "M_5_07A", 5, "large", false, true) then
            break
        end
        CameraSetXYZ(145.07, -482.23526, 3.708673, 144.68994, -483.15945, 3.744788)
        PedSetActionNode(idZoe, "/Global/5_07a/NIS/Zoe/Zoe03", "Act/Conv/5_07a.act")
        if F_PlaySpeechAndWait(idZoe, "M_5_07A", 6, "large", false, true) then
            break
        end
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    if PedIsValid(idRussell) then
        SoundStopCurrentSpeechEvent(idRussell)
    end
    if PedIsValid(idZoe) then
        SoundStopCurrentSpeechEvent(idZoe)
    end
    if PedIsValid(gPlayer) then
        SoundStopCurrentSpeechEvent(gPlayer)
    end
    CameraSetFOV(80)
    CameraSetXYZ(130.26767, -508.5833, 4.385609, 130.9741, -509.24243, 4.643035)
    CameraFade(500, 1)
    local x, y, z = GetPointList(POINTLIST._5_07_DROPOUT_01)
    TextPrint("5_07A_32", 4, 1)
    Wait(4000)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    SoundEnableSpeech_ActionTree()
    PedLockTarget(idZoe, -1)
    PedLockTarget(gPlayer, -1)
    UnLoadAnimationGroup("NIS_5_07")
    F_MakePlayerSafeForNIS(false)
    if PedIsValid(idRussell) then
        PedDelete(idRussell)
    end
    if VehicleIsValid(CopCar) then
        VehicleDelete(CopCar)
    end
    idRussell = nil
    CameraDefaultFOV()
    VehicleRevertToDefaultAmbient()
    PlayerSetControl(1)
    if gEffects[1] then
        EffectKill(gEffects[1])
        gEffects[1] = false
    end
    if gEffects[2] then
        EffectKill(gEffects[2])
        gEffects[2] = false
    end
    if gEffects[3] then
        EffectKill(gEffects[3])
        gEffects[3] = false
    end
    if gEffects[4] then
        EffectKill(gEffects[4])
        gEffects[4] = false
    end
    if gEffects[5] then
        EffectKill(gEffects[5])
        gEffects[5] = false
    end
    if gEffects[6] then
        EffectKill(gEffects[6])
        gEffects[6] = false
    end
    gFireEffects[1] = F_CreateFire(TRIGGER._BIKEFIRE01, "BarrelFire")
    gFireEffects[2] = F_CreateFire(TRIGGER._BIKEFIRE02, "boilerfire2")
    gFireEffects[3] = F_CreateFire(TRIGGER._BIKEFIRE03, "BarrelFire")
    gFireEffects[4] = F_CreateFire(TRIGGER._BIKEFIRE04, "boilerfire2")
    gFireEffects[5] = F_CreateFire(TRIGGER._BIKEFIRE05, "SmokeStackBLK")
    gFireEffects[6] = F_CreateFire(TRIGGER._BIKEFIRE06, "SmokeStackBLK")
end

function F_SetupPickups()
    tblPickups = {
        {
            idPickup = nil,
            model = 502,
            point = POINTLIST._5_07A_ZOE_TRIGGER
        },
        {
            idPickup = nil,
            model = 502,
            point = POINTLIST._5_07A_HEALTH_PICKUP_01
        },
        {
            idPickup = nil,
            model = 502,
            point = POINTLIST._5_07A_HEALTH_PICKUP_02
        },
        {
            idPickup = nil,
            model = 502,
            point = POINTLIST._5_07A_HEALTH_PICKUP_03
        },
        {
            idPickup = nil,
            model = 502,
            point = POINTLIST._5_07A_HEALTH_PICKUP_04
        },
        {
            idPickup = nil,
            model = 502,
            point = POINTLIST._5_07A_HEALTH_PICKUP_05
        },
        {
            idPickup = nil,
            model = 301,
            point = POINTLIST._5_07A_AMMO_PICKUP_01
        },
        {
            idPickup = nil,
            model = 312,
            point = POINTLIST._5_07A_AMMO_PICKUP_02
        },
        {
            idPickup = nil,
            model = 316,
            point = POINTLIST._5_07A_AMMO_PICKUP_03
        },
        {
            idPickup = nil,
            model = 316,
            point = POINTLIST._5_07A_AMMO_PICKUP_04
        },
        {
            idPickup = nil,
            model = 300,
            point = POINTLIST._5_07A_WEAPON_PICKUP_01
        },
        {
            idPickup = nil,
            model = 300,
            point = POINTLIST._5_07A_WEAPON_PICKUP_02
        },
        {
            idPickup = nil,
            model = 300,
            point = POINTLIST._5_07A_WEAPON_PICKUP_03
        }
    }
    local i, tblEntry
    for i, tblEntry in tblPickups do
        tblEntry.idPickup = PickupCreatePoint(tblEntry.model, tblEntry.point, 0, 5)
    end
end

function MissionSetup()
    shared.enclaveGateRespawn = 2
    shared.resetEnclave = true
    MissionDontFadeIn()
    SoundEnableInteractiveMusic(false)
    SoundPlayStream("MS_BikeFun_NIS.rsm", 0.5, 0, 2000)
    DATLoad("5_07.DAT", 2)
    DATInit()
    WeaponRequestModel(301)
    WeaponRequestModel(312)
    WeaponRequestModel(316)
    WeaponRequestModel(300)
    LoadAnimationGroup("F_Adult")
    DisablePOI(true, true)
    oldAttitude = PedGetTypeToTypeAttitude(3, 13)
    PedSetTypeToTypeAttitude(3, 13, 0)
end

function MissionCleanup()
    mission_started = false
    SoundStopInteractiveStream()
    DATUnload(2)
    UnLoadAnimationGroup("F_Adult")
    UnLoadAnimationGroup("ChLead_Idle")
    for i, effect in gEffects do
        if effect then
            EffectKill(effect)
            effect = nil
        end
    end
    for i, fireEffect in gFireEffects do
        if fireEffect ~= nil then
            FireDestroy(fireEffect)
        end
    end
    if ItemGetCurrentNum(480) > 0 then
        ItemSetCurrentNum(480, 0)
    end
    gEffects = nil
    if gBikeIndex then
        DeletePersistentEntity(gBikeIndex, gBikeObject)
    end
    EnablePOI(true, true)
    F_MakePlayerSafeForNIS(false)
    if not gMissionSucceeded then
        shared.enclaveGateRespawn = 1
        shared.resetEnclave = true
        CounterMakeHUDVisible(false, false)
        if gZoeDied then
            PlayerSetPosPoint(POINTLIST._5_07_A_CORONA)
        end
    end
    CameraSetWidescreen(false)
end

function main()
    local waitingTime = GetTimer()
    while shared.enclaveGateRespawn do
        if GetTimer() - waitingTime > 4000 then
            waitingTime = nil
            break
        end
        Wait(0)
    end
    LoadModels({
        44,
        42,
        41,
        43,
        45,
        46,
        48,
        176
    })
    WeaponRequestModel(362)
    AreaTransitionPoint(0, POINTLIST._5_07_PSTART, nil, true)
    POISetDisablePedProduction(POI._5_07_POI_01, true)
    POISetDisablePedProduction(POI._5_07_POI_02, true)
    POISetDisablePedProduction(POI._5_07_POI_06, true)
    idZoe = PedCreatePoint(48, POINTLIST._5_07_ZSTART)
    gBikeIndex, gBikeObject = CreatePersistentEntity("DPE_RussBike", 146.556, -488.208, 2.421, 0, 0)
    PedStop(idZoe)
    PedSetFlag(idZoe, 111, false)
    AddBlipForChar(idZoe, 1, 27, 1)
    PedMakeTargetable(idZoe, false)
    PedSetFaction(idZoe, 4)
    PedSetInfiniteSprint(idZoe, true)
    PedSetPedToTypeAttitude(idZoe, 13, 3)
    PedSetMissionCritical(idZoe, true, F_CriticalPedDied, true)
    PAnimSetActionNode(TRIGGER._TINDUST_GATE_SWITCH, "/Global/BRSwitch/NotUseable", "Act/Props/BRSwitch.act")
    PAnimSetActionNode(TRIGGER._TINDUST_ELECTRIC_SHUTOFF, "/Global/AsySwtch/NotUseable", "Act/Props/AsySwtch.act")
    part1Switches = {
        false,
        false,
        false,
        false
    }
    mission_started = true
    --print("-------[RAUL]Mission Starting ")
    if mission_started then
        StageFunction = F_StageOneSetup
        local playerInTrigger = false
        while mission_started do
            StageFunction()
            if playerInTrigger then
                if not PlayerIsInTrigger(TRIGGER._5_07_BARRICADENIS) then
                    playerInTrigger = false
                    if PlayerIsInTrigger(TRIGGER._5_07_MISSIONINIT) then
                        gMissionFail = true
                        gZoeDied = true
                    end
                end
            elseif PlayerIsInTrigger(TRIGGER._5_07_BARRICADENIS) then
                playerInTrigger = true
            end
            if gMissionFail then
                mission_started = false
                --print("FAILING NOW ***********************************")
                SoundPlayMissionEndMusic(false, 10)
                if gMissionFailMessage then
                    MissionFail(true, true, gMissionFailMessage)
                else
                    MissionFail()
                end
            end
            Wait(0)
        end
    end
end

function F_StageOneSetup()
    gDo01 = F_CreateDropout(POINTLIST._5_07_DROPOUT_01, 2, POI._5_07_POI_01)
    gDo02 = F_CreateDropout(POINTLIST._5_07_DROPOUT_02, 2, POI._5_07_POI_02, 2)
    gDo03 = F_CreateDropout(POINTLIST._5_07_DROPOUT_03, 4)
    F_Intro()
    SoundPlayInteractiveStream("MS_BikeFunLow.rsm", 0.6, 0, 1000)
    SoundSetMidIntensityStream("MS_BikeFunMid.rsm", 0.55, 0, 2000)
    SoundSetHighIntensityStream("MS_BikeFunHigh.rsm", 0.55, 0, 2000)
    PedShowHealthBar(idZoe, true, "5_07A_36", false)
    AreaSetDoorLocked("TINDUST_REDSTAR_SECURITY_DOOR", true)
    TextPrint("5_07A_33", 4, 1)
    local x, y, z = GetAnchorPosition(TRIGGER._TINDUST_POWER_SWITCH_01)
    idPowerBlip01 = BlipAddXYZ(x, y, z, 0, 1)
    x, y, z = GetAnchorPosition(TRIGGER._TINDUST_POWER_SWITCH_02)
    idPowerBlip02 = BlipAddXYZ(x, y, z, 0, 1)
    gObjs[1] = MissionObjectiveAdd("5_07A_OBJ1")
    PedClearObjectives(idZoe)
    CounterMakeHUDVisible(true, true)
    CounterSetCurrent(0)
    CounterSetMax(2)
    CounterSetIcon("Switch", "Switch_x")
    PedFollowPath(idZoe, PATH._5_07_ZOEPATH1, 0, 2)
    --print("FINISHED STAGE ONE SETUP")
    StageFunction = F_StageOne
end

function F_StageOne()
    if not gSlaughterhouse and PlayerIsInTrigger(TRIGGER._5_07_SLAUGHTERHOUSE) then
        --print("<<<<<<<<<<< RAUL >>>>>>> Let them follow ")
        SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 7, "large")
        PedFollowPath(gDo03[4], PATH._5_07_STEALTHPATH01, 2, 0)
        PedFollowPath(gDo03[3], PATH._5_07_STEALTHPATH02, 2, 0)
        gSlaughterhouse = true
    end
    if not part1Switches[1] and PAnimIsPlaying(TRIGGER._TINDUST_POWER_SWITCH_01, "/Global/BRSwitch/Active", false) then
        --print("[RAUL] power switch 01 is playing it")
        F_PowerSwitchOn(TRIGGER._TINDUST_POWER_SWITCH_01)
        CounterSetCurrent(1)
    end
    if not part1Switches[2] and PAnimIsPlaying(TRIGGER._TINDUST_POWER_SWITCH_02, "/Global/BRSwitch/Active", false) then
        --print("[RAUL] power switch 02 is playing it")
        F_PowerSwitchOn(TRIGGER._TINDUST_POWER_SWITCH_02)
        CounterSetCurrent(1)
    end
    if part1Switches[2] and part1Switches[1] and not part1Switches[4] and PAnimIsPlaying(TRIGGER._TINDUST_GATE_SWITCH, "/Global/BRSwitch/NotUseable", false) then
        F_PowerSwitchOn(TRIGGER._TINDUST_GATE_SWITCH)
    end
    if not firstZoe and part1Switches[1] and part1Switches[2] and PlayerIsInTrigger(TRIGGER._5_07_FIRSTZOE) then
        PedFollowPath(idZoe, PATH._5_07_ZOEPATH2, 0, 2)
        F_PlaySpeechAndWait(idZoe, "M_5_07A", 19, "large")
        SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 23, "large")
        firstZoe = true
    end
    if part1Switches[1] and part1Switches[2] and not gElectricDoor and PlayerIsInTrigger(TRIGGER._5_07_ELECTRICDOOR) then
        gElectricDoor = true
    end
end

function F_StageTwoSetup()
    while not PlayerIsInTrigger(TRIGGER._5_07_OUTSIDETHEOFFICE) do
        Wait(0)
    end
    PedFollowPath(idZoe, PATH._5_07_ZOEPATH3, 0, 2)
    F_WrapperMakeAmbient(gDo01)
    F_WrapperMakeAmbient(gDo02)
    F_WrapperMakeAmbient(gDo03)
    F_PlaySpeechAndWait(idZoe, "M_5_07A", 14, "large")
    F_PlaySpeechAndWait(idZoe, "M_5_07A", 15, "large")
    SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 17, "large")
    --print("FINISHED STAGE TWO SETUP")
    StageFunction = F_StageTwo
end

function F_StageTwo()
    if not gPedAttack02 and PlayerIsInTrigger(TRIGGER._5_07_PEDATTACK02) then
        AreaSetDoorLocked(TRIGGER._TINDUST_SHDOOR_03, true)
        AreaSetDoorLocked(TRIGGER._TINDUST_SHDOOR_04, true)
        AreaSetDoorLockedToPeds(TRIGGER._TINDUST_SHDOOR_03, false)
        AreaSetDoorLockedToPeds(TRIGGER._TINDUST_SHDOOR_04, false)
        gSpawnLocations = {
            {
                pointlist = POINTLIST._5_07_SPAWNER01,
                trigger = TRIGGER._5_07_SPAWNER01
            },
            {
                pointlist = POINTLIST._5_07_SPAWNER02,
                trigger = TRIGGER._5_07_SPAWNER02
            }
        }
        F_SetupSpawner(gSpawnLocations, 1, 1, 1500)
        gPedAttack02 = true
    end
    if not gPedAttack03 and PlayerIsInTrigger(TRIGGER._5_07_PEDATTACK03) then
        gPedAttack03 = true
    end
    if PlayerIsInTrigger(TRIGGER._5_07_PARTTHREE) then
        --print("FINISHED STAGE TWO")
        StageFunction = F_StageThreeSetup
    end
    if not gDoor01 and PlayerIsInTrigger(TRIGGER._5_07_DOORLOCKED01) then
        SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 31, "large")
        PedFaceObject(idZoe, gPlayer, 3, 1)
        gDoor01 = true
        BlipRemove(gObjBlip)
        gObjTrain = MissionObjectiveAdd("5_07A_OBJ8")
        TextPrint("5_07A_OBJ8", 4, 1)
        x, y, z = GetAnchorPosition(TRIGGER._TINDUST_TRAIN_SWITCH_01)
        gObjBlip = BlipAddXYZ(x, y, z, 0, 1)
        gTrainCheck = true
    end
    if gTrainCheck and shared.trainButton and PlayerIsInTrigger(TRIGGER._5_07_TRAINSWITCH) then
        --print("REMOVING THE FIRST BLIP FOR TRAIN")
        BlipRemove(gObjBlip)
        x, y, z = GetAnchorPosition(TRIGGER._TINDUST_TRAIN_SWITCH_02)
        gObjBlip = BlipAddXYZ(x, y, z, 0, 1)
        gTrainCheck = nil
        gTrainCheck2 = true
        shared.trainButton = nil
    end
    if gTrainCheck2 and shared.trainButton and PlayerIsInTrigger(TRIGGER._5_07_TRAINSWITCH02) then
        --print("REMOVING THE SECOND BLIP FOR TRAIN")
        BlipRemove(gObjBlip)
        MissionObjectiveComplete(gObjTrain)
        gObjBlip = AddBlipForChar(idZoe, 3, 0, 1)
        gTrainCheck2 = nil
        shared.trainButton = nil
    end
end

function F_StageThreeSetup()
    F_WrapperMakeAmbient(gDo05)
    gDo07 = F_CreateDropout(POINTLIST._5_07_DROPOUT_07, 2)
    gDo08 = F_CreateDropout(POINTLIST._5_07_DROPOUT_08, 2)
    BlipRemove(gObjBlip)
    gObjBlip = AddBlipForChar(idZoe, 3, 0, 1)
    --print("FINISHED STAGE THREE SETUP")
    StageFunction = F_StageThree
end

function F_StageThree()
    if not gRanged01 and PlayerIsInTrigger(TRIGGER._5_07_RANGED01) then
        PedClearAllWeapons(gDo07[1])
        PedClearAllWeapons(gDo07[2])
        PedSetWeapon(gDo07[1], 311, 100)
        PedSetWeapon(gDo07[2], 311, 100)
        PedCoverSet(gDo07[1], gPlayer, POINTLIST._5_07_COVER07_02, 100, 100, 2, 1, 2, 0.5, 1, 1, 2, 0, 0, false)
        gRanged01 = true
    end
    if not gDumbass and PlayerIsInTrigger(TRIGGER._5_07_SECONDZOE) then
        SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 12, "large")
        BlipRemove(gObjBlip)
        x, y, z = GetAnchorPosition(TRIGGER._TINDUST_BAR_DOOR_SWITCH_02)
        gObjBlip = BlipAddXYZ(x, y, z, 0, 1)
        gObjDumbass = MissionObjectiveAdd("5_07A_OBJ10")
        TextPrint("5_07A_OBJ10", 4, 1)
        gDumbass = true
    end
    if not gRanged02 and PlayerIsInTrigger(TRIGGER._5_07_RANGED02) then
        PedClearAllWeapons(gDo08[1])
        PedClearAllWeapons(gDo08[2])
        PedSetWeapon(gDo08[1], 311, 100)
        PedSetWeapon(gDo08[2], 311, 100)
        PedCoverSet(gDo08[1], gPlayer, POINTLIST._5_07_COVER08_01, 100, 100, 2, 1, 2, 0.5, 1, 1, 2, 0, 0, false)
        PedCoverSet(gDo08[2], gPlayer, POINTLIST._5_07_COVER08_03, 100, 100, 2, 1, 2, 0.5, 1, 1, 2, 0, 0, false)
        gRanged02 = true
    end
    if gDoor02 or PlayerIsInTrigger(TRIGGER._5_07_DOORLOCKED02) then
    end
    if not gZoeLastPath and AreaIsDoorOpen(TRIGGER._TINDUST_BAR_DOOR_01) then
        gZoeLastPath = true
        --print("------------[RAUL]  ZOE FOLLOWING THE LAST PATH ")
        BlipRemove(gObjBlip)
        gObjBlip = AddBlipForChar(idZoe, 3, 0, 1)
        MissionObjectiveComplete(gObjDumbass)
        PedFollowPath(idZoe, PATH._5_07_ZOEPATH4, 0, 2)
        TextPrint("5_07A_OBJ5", 4, 1)
        F_WrapperMakeAmbient(gDo07)
        F_WrapperMakeAmbient(gDo08)
        gDo10 = F_CreateDropout(POINTLIST._5_07_OMARCS, 5)
    end
    if not zoeAfterButton and gZoeLastPath and PlayerIsInAreaObject(idZoe, 2, 4, 0) then
        SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 13, "large")
        zoeAfterButton = true
    end
    if PlayerIsInTrigger(TRIGGER._5_07_CHEMENTRANCE) then
        BlipRemove(gObjBlip)
        --print("FINISHED STAGE THREE")
        StageFunction = F_StageFourSetup
    end
end

function F_StageFourSetup()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    PlayerSetControl(0)
    Wait(600)
    LoadAnimationGroup("ChLead_Idle")
    PedStop(idZoe)
    PedClearObjectives(idZoe)
    PedSetPosPoint(gPlayer, POINTLIST._5_07_PLAYERDISTRACT, 1)
    PedSetPosPoint(idZoe, POINTLIST._5_07_PLAYERDISTRACT, 2)
    Wait(500)
    CameraLookAtXYZ(72.62771, -544.7004, 4.3949227, true)
    CameraSetXYZ(77.49009, -541.1016, 4.8550286, 72.62771, -544.7004, 4.3949227)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    CameraFade(500, 1)
    SoundDisableSpeech_ActionTree()
    F_PlaySpeechAndWait(gPlayer, "M_5_07A", 116, "large")
    SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 4, "large")
    Wait(1500)
    SoundStopCurrentSpeechEvent()
    SoundPlayScriptedSpeechEvent(idZoe, "M_5_07A", 5, "large")
    PedMoveToXYZ(idZoe, 1, 65.1421, -549.671)
    Wait(3000)
    F_PlaySpeechAndWait(idZoe, "GREET", 0, "large")
    SoundPlayScriptedSpeechEvent(gDo10[2], "GREET_HOT_GIRL", 0, "large")
    Wait(500)
    SoundPlayScriptedSpeechEvent(gDo10[4], "GREET_HOT_GIRL", 0, "large")
    Wait(1000)
    CameraFade(1000, 0)
    Wait(1000)
    LoadModels({ 47 })
    WeaponRequestModel(480)
    SoundEnableSpeech_ActionTree()
    CameraReset()
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    CameraReturnToPlayer()
    PedStop(idZoe)
    PedClearObjectives(idZoe)
    PedSetPosPoint(idZoe, POINTLIST._5_07_ZOEDISTRACT, 6)
    PedHideHealthBar()
    for i, tDO in gDo10 do
        PedStop(tDO)
        PedSetPosPoint(tDO, POINTLIST._5_07_ZOEDISTRACT, i)
    end
    for i, tDO in gDo10 do
        PedFaceObject(tDO, idZoe, 2, 0, true)
    end
    PedSetActionNode(idZoe, "/Global/5_07a/ZoeDistract/ZoeDistractWait", "Act/Conv/5_07a.act")
    PedSetTetherToTrigger(idZoe, TRIGGER._5_07_CHEMENTRANCE)
    CameraFade(500, 1)
    PlayerSetControl(1)
    x, y, z = GetAnchorPosition(TRIGGER._5_07_OMARFIGHT)
    gObjBlip = BlipAddXYZ(x, y, z, 0, 1)
    MissionObjectiveComplete(gObjs[4])
    gObjs[5] = MissionObjectiveAdd("5_07A_OBJ6")
    TextPrint("5_07A_OBJ6", 4, 1)
    --print("FINISHED STAGE FOUR SETUP")
    StageFunction = F_StageFour
    Wait(500)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_StageFour()
    if not gZoeIsAmbient and F_WrapperCheckAttacked(gDo10) and idZoe ~= nil then
        PedSetActionNode(idZoe, "/Global/5_07a/Blank", "Act/Conv/5_07a.act")
        PedStop(idZoe)
        PedClearObjectives(idZoe)
        PedWander(idZoe, 0)
        PedMakeTargetable(idZoe, true)
        SoundPlayScriptedSpeechEvent(idZoe, "SEE_SOMETHING_COOL", 0, "large")
        gZoeIsAmbient = true
    end
    if not gSiloAttack01 and PlayerIsInTrigger(TRIGGER._5_07_SILOATTACK01) then
        for i, tdo in gDo10 do
            if tdo and not PedIsDead(tdo) then
                PedMakeAmbient(tdo)
            end
        end
        if idZoe and not PedIsDead(idZoe) then
            PedSetMissionCritical(idZoe, false)
            PedMakeTargetable(idZoe, true)
            PedDelete(idZoe)
            idZoe = nil
        end
        idOmar = PedCreatePoint(47, POINTLIST._5_07_DROPOUT_10, 3)
        gDo11 = F_CreateDropout(POINTLIST._5_07_DROPOUT_10, 2)
        PedSetHealth(idOmar, 300)
        PedSetPedToTypeAttitude(idOmar, 13, 4)
        gSiloAttack01 = true
    end
    if gSiloAttack01 and not gOmarFight and PlayerIsInTrigger(TRIGGER._5_07_OMARFIGHT) then
        PedSetTetherToTrigger(idOmar, TRIGGER._5_07_OMARFIGHT)
        PedSetTetherToTrigger(gDo11[1], TRIGGER._5_07_OMARFIGHT)
        PedSetTetherToTrigger(gDo11[2], TRIGGER._5_07_OMARFIGHT)
        PedSetPedToTypeAttitude(gDo11[1], 13, 1)
        PedSetPedToTypeAttitude(gDo11[2], 13, 1)
        PlayerSetControl(0)
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        CameraLookAtXYZ(45.29586, -567.0649, 33.356407, true)
        CameraSetPath(PATH._5_07_END_CAM, true)
        CameraSetSpeed(1, 1, 1)
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        PedMoveToPoint(gPlayer, 2, POINTLIST._5_07_PLAYERMOVETOEND)
        Wait(3000)
        PedFaceObject(idOmar, gPlayer, 3, 1)
        SoundPlayScriptedSpeechEvent(idOmar, "M_5_07A", 38, "large")
        Wait(1000)
        PedSetPedToTypeAttitude(idOmar, 13, 0)
        PedStop(idOmar)
        PedClearObjectives(idOmar)
        PedAttackPlayer(idOmar)
        BlipRemove(gObjBlip)
        idBlip = AddBlipForChar(idOmar, 3, 0, 4)
        gOmarFight = true
        gPlayerInOmarTrigger = true
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        PlayerSetControl(1)
        CameraReturnToPlayer()
        CameraReset()
        F_MakePlayerSafeForNIS(false)
        CameraSetWidescreen(false)
        StageFunction = F_StageFive
    end
    if gSiloAttack01 and not gPlayerHasKey and PedIsDead(idOmar) then
        gPlayerHasKey = true
        --print("FINISHED STAGE FOUR")
        StageFunction = F_StageSixSetup
    end
end

local gOmarHealth

function F_StageFive()
    if not gReinforcements then
        gOmarHealth = PedGetHealth(idOmar)
        if gOmarHealth < 200 then
            SoundPlayScriptedSpeechEvent(idOmar, "M_5_07A", 40, "large")
            F_WrapperAttack(gDo11[1])
            F_WrapperAttack(gDo11[2])
            gReinforcements = true
        end
    end
    if gPlayerInOmarTrigger and not PlayerIsInTrigger(TRIGGER._5_07_OMARFIGHT) then
        PedStop(idOmar)
        PedClearObjectives(idOmar)
        PedMoveToPoint(idOmar, 2, POINTLIST._5_07_DROPOUT_10, 5)
    elseif not gPlayerInOmarTrigger and PlayerIsInTrigger(TRIGGER._5_07_OMARFIGHT) then
        PedAttackPlayer(idOmar)
    end
    if not gPlayerHasKey and PedIsDead(idOmar) then
        gPlayerHasKey = true
        --print("FINISHED STAGE FIVE")
        StageFunction = F_StageSixSetup
    end
end

function F_StageSixSetup()
    tx, ty, tz = PedGetPosXYZ(idOmar)
    gate_key = PickupCreateXYZ(480, tx, ty, tz, "PermanentButes")
    gate_key_blip = BlipAddXYZ(tx, ty, tz, 0, 4)
    MissionObjectiveComplete(gObjs[5])
    gObjs[6] = MissionObjectiveAdd("5_07A_OBJ9")
    TextPrint("5_07A_OBJ9", 4, 1)
    StageFunction = F_StageSix
end

function F_StageSix()
    if PickupIsPickedUp(gate_key) then
        if gate_key_blip then
            BlipRemove(gate_key_blip)
        end
        StageFunction = F_StageSevenSetup
    end
end

function F_StageSevenSetup()
    gObjBlip = BlipAddXYZ(49.926, -564.06, 32.6076, 0, 1, 7)
    MissionObjectiveComplete(gObjs[6])
    gObjs[7] = MissionObjectiveAdd("5_07A_OBJ7")
    TextPrint("5_07A_OBJ7", 4, 1)
    Wait(2000)
    StageFunction = F_StageSeven
end

function F_StageSeven()
    if PlayerIsInAreaXYZ(49.926, -564.06, 32.6076, 1, 0) then
        MissionObjectiveComplete(gObjs[7])
        BlipRemove(gObjBlip)
        F_CompleteMission()
    end
end

function PedExists(ped)
    return ped and PedIsValid(ped) and not (PedGetHealth(ped) <= 0)
end

function F_WrapperAttack(pedId)
    if PedExists(pedId) then
        PedSetPedToTypeAttitude(pedId, 13, 0)
        PedAttackPlayer(pedId)
    end
end

function F_WrapperMakeAmbient(pedTable)
    if pedTable then
        for i, tdo in pedTable do
            if PedExists(tdo) then
                PedMakeAmbient(tdo)
            end
        end
    end
end

function F_WrapperCheckAttacked(pedTable)
    local attacked = false
    local aggression = false
    if pedTable then
        for i, tdo in pedTable do
            if PedExists(tdo) then
                if not gLastGroupAttacked and PedIsHit(tdo, 2, 1000) and PedGetWhoHitMeLast(tdo) == gPlayer then
                    aggression = true
                end
                attacked = false
            else
                attacked = true
            end
        end
    end
    if not gLastGroupAttacked and aggression then
        F_GroupAttack(pedTable)
        gLastGroupAttacked = true
        attacked = true
    end
    return attacked
end

function F_GroupAttack(pedTable)
    if pedTable then
        for i, tdo in pedTable do
            if PedExists(tdo) then
                PedStop(tdo)
                PedClearObjectives(tdo)
                PedAttackPlayer(tdo)
            end
        end
    end
end

function F_PowerSwitchOn(trigger)
    if trigger == TRIGGER._TINDUST_POWER_SWITCH_01 then
        --print("<+)-)-)< Switch One Triggered ")
        part1Switches[1] = true
        if idPowerBlip01 then
            BlipRemove(idPowerBlip01)
            PAnimSetActionNode(trigger, "/Global/BRSwitch/NotUseable", "Act/Props/BRSwitch.act")
            idPowerBlip01 = nil
        end
    elseif trigger == TRIGGER._TINDUST_POWER_SWITCH_02 then
        --print("<+)-)-)< Switch Two Triggered ")
        part1Switches[2] = true
        if idPowerBlip02 then
            PAnimSetActionNode(trigger, "/Global/BRSwitch/NotUseable", "Act/Props/BRSwitch.act")
            BlipRemove(idPowerBlip02)
            idPowerBlip02 = nil
        end
    elseif trigger == TRIGGER._TINDUST_ELECTRIC_SHUTOFF then
        --print("<+)-)-)< Switch Three Triggered ")
        part1Switches[3] = true
        if idPowerBlip03 then
            BlipRemove(idPowerBlip03)
            MissionObjectiveComplete(gObjs[2])
            gObjs[3] = MissionObjectiveAdd("5_07A_OBJ4")
            TextPrint("5_07A_OBJ4", 4, 1)
            TextPrintString(" Now we can open the main door", 3, 2)
            PAnimSetActionNode(TRIGGER._TINDUST_GATE_SWITCH, "/Global/BRSwitch/Inactive", "Act/Props/BRSwitch.act")
            x, y, z = GetAnchorPosition(TRIGGER._TINDUST_GATE_SWITCH)
            gObjBlip = BlipAddXYZ(x, y, z, 0, 1)
            AreaSetDoorLocked(TRIGGER._TINDUST_REDSTAR_SECURITY_DOOR, false)
            idPowerBlip03 = nil
        end
    elseif trigger == TRIGGER._TINDUST_GATE_SWITCH then
        part1Switches[4] = true
        BlipRemove(gObjBlip)
        MissionObjectiveComplete(gObjs[3])
        gObjs[4] = MissionObjectiveAdd("5_07A_OBJ5")
        TextPrint("5_07A_OBJ5", 4, 1)
        x, y, z = GetAnchorPosition(TRIGGER._TINDUST_BAR_DOOR_01)
        gObjBlip = BlipAddXYZ(x, y, z, 0, 1)
        StageFunction = F_StageTwoSetup
    end
    if part1Switches[1] and part1Switches[2] and not part1Switches[4] then
        MissionObjectiveComplete(gObjs[1])
        gObjs[3] = MissionObjectiveAdd("5_07A_OBJ4")
        TextPrint("5_07A_OBJ4", 4, 1)
        CounterMakeHUDVisible(false)
        PAnimSetActionNode(TRIGGER._TINDUST_GATE_SWITCH, "/Global/BRSwitch/Inactive", "Act/Props/BRSwitch.act")
        x, y, z = GetAnchorPosition(TRIGGER._TINDUST_GATE_SWITCH)
        gObjBlip = BlipAddXYZ(x, y, z, 0, 1)
        AreaSetDoorLocked(TRIGGER._TINDUST_REDSTAR_SECURITY_DOOR, false)
    end
end

local gPedsSpawned = 0

function F_SpawnerCallback(idPed, idSpawner)
    PedAttackPlayer(idPed)
    gPedsSpawned = gPedsSpawned + 1
    if 2 <= gPedsSpawned then
        PedOverrideStat(idPed, 0, 362)
        PedOverrideStat(idPed, 1, 100)
        gPedsSpawned = 0
    end
end

function F_SetupSpawner(spawnTable, noToSpawn, simultEnemies, timeForSpawns)
    gSpawningTimer = GetTimer()
    idSpawner = AreaAddMissionSpawner(noToSpawn, simultEnemies, -1, 2, 0, timeForSpawns)
    AreaMissionSpawnerSetCallback(idSpawner, F_SpawnerCallback)
    AreaMissionSpawnerSetAttackTarget(idSpawner, gPlayer, true)
    local gSpawnIds = {}
    for i, spawnLoc in spawnTable do
        gSpawnIds[i] = AreaAddSpawnLocation(idSpawner, spawnLoc.pointlist, spawnLoc.trigger)
    end
    local spawnerUsed = 1
    for _, idModel in tblDropOutModels do
        AreaAddPedModelIdToSpawnLocation(idSpawner, gSpawnIds[spawnerUsed], idModel)
        spawnerUsed = spawnerUsed + 1
        if spawnerUsed > table.getn(gSpawnIds) then
            spawnerUsed = 1
        end
    end
    AreaMissionSpawnerSetActivated(idSpawner, true)
end

function F_CreateFire(trigger, effectName)
    local fireId = FireCreate(trigger, 1000, 20, 100, 115, effectName)
    FireSetScale(fireId, 1)
    FireSetDamageRadius(fireId, 1)
    PAnimHideHealthBar(fireId)
    return fireId
end

function F_CriticalPedDied()
    --print("CRITICAL PED DIED")
    gZoeDied = true
    gMissionFail = true
    gMissionFailMessage = "5_07A_35"
end
