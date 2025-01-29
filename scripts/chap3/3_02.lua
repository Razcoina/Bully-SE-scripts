local gordTimer = 120
local tblGord, tblPrep1, tblPrep2, tblPrepModel, tblJockWeapon, tblSpawner, tblSpawnedPrep, tblSpawnedBike, tblSpawnQueue, tblJohnnyWH, tblGreaser1WH, tblGreaser2WH, tblGordWH, tblPrep1WH, tblPrep2WH, tblPrepWH, F_StageFunction
local numSimultaneousPrep = 4
local numAmbientPrep = 3
local enterNISSpawnDelay = 5000
local playerSeeGordRange = 15
local missionOver = false
local bPlayerHitGord = false
local bGordInsulted = false
local bOutOfRange = false
local bGarageOpen = false
local gTooFarFromGord = 60
local gPlayersBMX = 0
local spawnerID, findObjID, madObjID, lureObjID, brawlObjID, farObjID, businessBlipID, bikeParkBlipID
local bSkipNIS = false
local tblJump = {}
local bCompletedMission = false
local bSomeoneGotBeatUp = false

function F_TableInitMain()
    tblPlayer = {
        startPosition = POINTLIST._3_02_PLAYER,
        bike = {
            model = 282,
            location = POINTLIST._3_02_PLAYERBIKE
        },
        startOnBike = true
    }
    tblGord = {
        model = 30,
        point = POINTLIST._3_02_GORD,
        bike = {
            model = 283,
            point = POINTLIST._3_02_GORDBIKE
        },
        startOnBike = true,
        tether = {
            trigger = TRIGGER._3_02_BUSINESSAREA
        },
        weapon = { model = 312, ammo = 99 },
        stat = {
            { name = 25, value = 25 },
            { name = 24, value = 25 },
            { name = 37, value = 25 },
            { name = 26, value = 25 },
            { name = 36, value = 25 },
            { name = 30, value = 25 }
        }
    }
    tblPrep1 = {
        model = 34,
        point = POINTLIST._3_02_PREP1,
        bike = {
            model = 283,
            point = POINTLIST._3_02_PREP1BIKE
        },
        startOnBike = true,
        tether = {
            trigger = TRIGGER._3_02_BUSINESSAREA
        },
        weapon = { model = 312, ammo = 99 },
        stat = {
            { name = 25, value = 25 },
            { name = 24, value = 25 },
            { name = 37, value = 25 },
            { name = 26, value = 25 },
            { name = 36, value = 25 },
            { name = 30, value = 25 }
        }
    }
    tblPrepModel = {
        33,
        35,
        32,
        40,
        31
    }
    tblPrepWeapon = {
        312,
        301,
        309
    }
    tblStageState = {}
    tblSpawnedPrep = {}
    tblSpawnedBike = {}
    tblSpawnQueue = {}
    PedSetTypeToTypeAttitude(5, 13, 0)
end

function F_TableInitBMXIntro()
    tblJohnnyWH = {
        model = 23,
        point = POINTLIST._3_02_WHJOHN,
        bike = {
            model = 282,
            point = POINTLIST._3_02_WHJOHNBIKE
        },
        weapon = { model = 301, ammo = 99 },
        stat = {
            { name = 24, value = 80 },
            { name = 30, value = 100 },
            { name = 9,  value = 100 }
        },
        bAttackOnFoot = false,
        startOnBike = true
    }
    tblGreaser1WH = {
        model = 24,
        point = POINTLIST._3_02_WHGR1,
        bike = {
            model = 282,
            point = POINTLIST._3_02_WHGR1BIKE
        },
        weapon = { model = 301, ammo = 99 },
        stat = {
            { name = 24, value = 80 },
            { name = 30, value = 100 },
            { name = 9,  value = 100 }
        },
        bAttackOnFoot = false,
        startOnBike = true
    }
    tblGreaser2WH = {
        model = 27,
        point = POINTLIST._3_02_WHGR2,
        bike = {
            model = 282,
            point = POINTLIST._3_02_WHGR2BIKE
        },
        weapon = { model = 301, ammo = 99 },
        stat = {
            { name = 24, value = 80 },
            { name = 30, value = 100 },
            { name = 9,  value = 100 }
        },
        bAttackOnFoot = false,
        startOnBike = true
    }
    tblGreaseWH = {
        tblJohnnyWH,
        tblGreaser1WH,
        tblGreaser2WH
    }
end

function F_TableInitBMX()
    tblGordWH = {
        model = 30,
        point = POINTLIST._3_02_WHGORD,
        bike = {
            model = 283,
            point = POINTLIST._3_02_WHGORDBIKE
        },
        weapon = { model = 301, ammo = 99 },
        blipStyle = 4,
        radarIcon = 26,
        stat = {
            { name = 24, value = 80 },
            { name = 30, value = 100 },
            { name = 9,  value = 100 }
        },
        startOnBike = true,
        bAttackOnFoot = false
    }
    tblPrep1WH = {
        model = 31,
        point = POINTLIST._3_02_WHPREP1,
        bike = {
            model = 283,
            point = POINTLIST._3_02_WHPREP1BIKE
        },
        weapon = { model = 301, ammo = 99 },
        blipStyle = 4,
        radarIcon = 26,
        stat = {
            { name = 24, value = 80 },
            { name = 30, value = 100 },
            { name = 9,  value = 100 }
        },
        startOnBike = true,
        bAttackOnFoot = false
    }
    tblPrep2WH = {
        model = 34,
        point = POINTLIST._3_02_WHPREP2,
        bike = {
            model = 283,
            point = POINTLIST._3_02_WHPREP2BIKE
        },
        weapon = { model = 301, ammo = 99 },
        blipStyle = 4,
        radarIcon = 26,
        stat = {
            { name = 24, value = 80 },
            { name = 30, value = 100 },
            { name = 9,  value = 100 }
        },
        startOnBike = true,
        bAttackOnFoot = false
    }
    tblPrepWH = {
        tblGordWH,
        tblPrep1WH,
        tblPrep2WH
    }
end

function F_PedDeleteCallback(pedID, pathID, nodeID)
    if nodeID == 1 then
        PedStop(pedID)
        PedDelete(pedID)
    end
end

function F_CreatePed(tbl)
    tbl.id = PedCreatePoint(tbl.model, tbl.point)
    PedSetWeaponNow(tbl.id, tbl.weapon.model, tbl.weapon.ammo, false)
    if tbl.startOnBike then
        tbl.bike.id = VehicleCreatePoint(tbl.bike.model, tbl.bike.point)
        PedPutOnBike(tbl.id, tbl.bike.id)
    end
    if tbl.blipStyle ~= nil then
        AddBlipForChar(tbl.id, 5, tbl.radarIcon, tbl.blipStyle)
    end
    if tbl.tether ~= nil then
        --print("==== Setting Tether ====")
        PedSetTetherToTrigger(tbl.id, tbl.tether.trigger)
    end
    F_OverrideStatsForPed(tbl)
end

function F_OverrideStatsForPed(tbl)
    local tblStats = tbl.stat
    if tblStats ~= nil then
        for s, stat in tblStats do
            PedOverrideStat(tbl.id, stat.name, stat.value)
        end
    end
end

function cbCriticalGord()
    if PedIsValid(tblGord.id) and (PedGetHealth(tblGord.id) == 0 or PedIsDead(tblGord.id)) then
        bPlayerHitGord = true
        if bGarageOpen and AreaGetVisible() == 0 then
            PAnimSetActionNode(TRIGGER._BA_BMXGARAGE, "/Global/Door/DoorFunctions/Closing/BIKEGAR", "Act/Props/Door.act")
            bGarageOpen = false
        end
        SoundPlayMissionEndMusic(false, 8)
        MissionFail(false, true, "3_02_GORDKO")
        bSomeoneGotBeatUp = true
        missionOver = true
    end
end

function F_StageGetGordSetup(tblStageState)
    shared.tblStageState = tblStageState
    F_StageFunction = F_StageGetGord
    local x, y, z = GetAnchorPosition(TRIGGER._3_02_BUSINESSAREA)
    businessBlipID = BlipAddXYZ(x, y, z, 0)
    findObjID = MissionObjectiveAdd("3_02_FINDOBJ")
    TextPrint("3_02_FINDOBJ", 5, 1)
end

function F_StageGetGord(tblStageState)
    if PlayerIsInTrigger(tblGord.tether.trigger) then
        F_StageFunction = F_StageAttackGordSetup
    end
end

function F_StageAttackGordSetup(tblStageState)
    --print("F_StageAttackGordSetup() start")
    BlipRemove(businessBlipID)
    while not VehicleRequestModel(283) do
        Wait(0)
    end
    tblGord.id = PedCreatePoint(tblGord.model, tblGord.point)
    tblGord.bike.id = VehicleCreatePoint(tblGord.bike.model, tblGord.bike.point)
    PedSetFlag(tblGord.id, 117, false)
    PedSetWeaponNow(tblGord.id, tblGord.weapon.model, tblGord.weapon.ammo, false)
    PedPutOnBike(tblGord.id, tblGord.bike.id)
    F_OverrideStatsForPed(tblGord)
    PedSetMissionCritical(tblGord.id, true, cbCriticalGord)
    PlayerRegisterSocialCallbackVsPed(tblGord.id, 28, F_InsultGord, true)
    PedRegisterSocialCallback(tblGord.id, 7, F_InsultGord)
    PedRegisterSocialCallback(tblGord.id, 8, F_InsultGord)
    tblGord.blip = AddBlipForChar(tblGord.id, 5, 0, 4)
    PedWander(tblGord.id, 0)
    F_CreatePed(tblPrep1)
    PedFollowFocus(tblPrep1.id, tblGord.id)
    PedRegisterSocialCallback(tblPrep1.id, 7, F_InsultGord)
    PedRegisterSocialCallback(tblPrep1.id, 8, F_InsultGord)
    PedSetPedToTypeAttitude(tblGord.id, 13, 2)
    PedSetPedToTypeAttitude(tblPrep1.id, 13, 2)
    PedSetTetherToTrigger(tblGord.id, tblGord.tether.trigger)
    F_StageFunction = F_StageAttackGord
    --print("F_StageAttackGordSetup() end")
end

function F_InsultGord()
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_TAUNT", 0, "speech")
    bGordInsulted = true
end

function F_StageAttackGord(tblStageState)
    if PlayerIsInAreaObject(tblGord.id, 2, playerSeeGordRange, 0) and not tblStageState.playerSawPrep then
        tblStageState.playerSawPrep = true
        MissionObjectiveComplete(findObjID)
        madObjID = MissionObjectiveAdd("3_02_MADOBJ")
        TextPrint("3_02_MADOBJ", 5, 1)
    elseif (bGordInsulted or PedGetWhoHitMeLast(tblGord.id) == gPlayer or PedGetWhoHitMeLast(tblPrep1.id) == gPlayer) and not tblStageState.playerAttackedPrep then
        tblStageState.playerAttackedPrep = true
        if madObjID ~= nil then
            MissionObjectiveComplete(madObjID)
        end
        PedSetPedToTypeAttitude(tblGord.id, 13, 0)
        PedSetPedToTypeAttitude(tblPrep1.id, 13, 0)
        PedAttackPlayer(tblGord.id, 3)
        PedAttackPlayer(tblPrep1.id, 3)
        for i, pair in tblGord.stat do
            if pair.name ~= 30 then
                PedOverrideStat(tblGord.id, pair.name, 100)
                PedOverrideStat(tblPrep1.id, pair.name, 100)
            end
        end
        PedClearTether(tblGord.id)
        PedClearTether(tblPrep1.id)
        PedMakeAmbient(tblPrep1.id)
        PedSetTypeToTypeAttitude(5, 13, 0)
        MissionTimerStart(gordTimer)
        F_StageFunction = F_StageLureGordSetup
        SoundPlayStream("MS_BikeChaseMid.rsm", MUSIC_DEFAULT_VOLUME)
    end
    if AreaGetVisible() ~= 0 then
        TextClear()
        SoundPlayMissionEndMusic(false, 8)
        MissionTimerStop()
        MissionFail(false, true, "3_02_OUTOFRANGE")
        missionOver = true
    end
end

function F_StageLureGordSetup(tblStageState)
    --print("F_StageLureGordSetup() start")
    shared.tblStageState = tblStageState
    shared.tblStageState.tblSpawnedPrep = tblSpawnedPrep
    shared.tblStageState.tblSpawnedBike = tblSpawnedBike
    shared.tblStageState.tblSpawnQueue = tblSpawnQueue
    local x, y, z = GetAnchorPosition(TRIGGER._3_02_PARKENTRANCE)
    bikeParkBlipID = BlipAddXYZ(x, y, z, 0, 1, 7)
    BlipRemove(tblGord.blip)
    lureObjID = MissionObjectiveAdd("3_02_LUREOBJ")
    TextPrint("3_02_LUREOBJ", 5, 1)
    spawnerID = AreaAddMissionSpawner(1, 1, TRIGGER._POORAREA, 5)
    local spawnerLoc1ID, spawnerLoc2ID, spawnerLoc3ID, spawnerLoc4ID, spawnerLoc5ID
    tblStageState.spawnerID = spawnerID
    AreaMissionSpawnerSetCallback(spawnerID, F_PrepAddToSpawnQueue)
    spawnerLoc1ID = AreaAddSpawnLocation(spawnerID, POINTLIST._3_02_SPAWNER01, TRIGGER._3_02_SPAWNER01)
    AreaAddPedModelIdToSpawnLocation(spawnerID, spawnerLoc1ID, 40)
    AreaOverridePopulation(3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0)
    VehicleOverrideAmbient(3, 2, 0, 1)
    F_StageFunction = F_StageLureGord
    --print("F_StageLureGordSetup() end")
end

function F_StageLureGord(tblStageState)
    while table.getn(tblSpawnQueue) > 0 do
        F_PrepSetBiking(table.remove(tblSpawnQueue))
    end
    if not F_PedIsDead(tblGord.id) and not bOutOfRange and not PlayerIsInAreaObject(tblGord.id, 2, gTooFarFromGord, 0) then
        bOutOfRange = true
        MissionObjectiveRemove(lureObjID)
        farObjID = MissionObjectiveAdd("3_02_TOOFAR")
        TextPrint("3_02_TOOFAR", 5, 1)
        BlipRemove(bikeParkBlipID)
        tblGord.blip = AddBlipForChar(tblGord.id, 5, 0, 4)
    elseif not F_PedIsDead(tblGord.id) and bOutOfRange and PlayerIsInAreaObject(tblGord.id, 2, gTooFarFromGord, 0) then
        if not MissionTimerHasFinished() then
            MissionTimerStop()
            bOutOfRange = false
            MissionObjectiveRemove(farObjID)
            lureObjID = MissionObjectiveAdd("3_02_LUREOBJ")
            TextPrint("3_02_LUREOBJ", 5, 1)
            BlipRemove(tblGord.blip)
            tblGord.blip = AddBlipForChar(tblGord.id, 5, 0, 2)
            local x, y, z = GetAnchorPosition(TRIGGER._3_02_PARKENTRANCE)
            bikeParkBlipID = BlipAddXYZ(x, y, z, 0, 1, 7)
        else
            TextClear()
            SoundPlayMissionEndMusic(false, 8)
            MissionFail(false, true, "3_02_OUTOFRANGE")
            missionOver = true
        end
    end
    if MissionTimerHasFinished() then
        TextClear()
        SoundPlayMissionEndMusic(false, 8)
        MissionTimerStop()
        MissionFail(false, true, "3_02_OUTOFTIME")
        missionOver = true
    end
    if AreaGetVisible() ~= 0 then
        TextClear()
        if PedIsValid(tblGord.id) then
            PedSetMissionCritical(tblGord.id, false)
            PedDelete(tblGord.id)
        end
        SoundPlayMissionEndMusic(false, 8)
        MissionTimerStop()
        MissionFail(false, true, "3_02_OUTOFRANGE")
        missionOver = true
    end
    if PedIsValid(tblGord.id) and PedIsPlaying(tblGord.id, "/Global/Garbagecan/PedPropsActions/StuffGrap/RCV/InCan/die", true) then
        TextClear()
        SoundPlayMissionEndMusic(false, 8)
        MissionFail(false, true, "3_02_GORDKO")
        bSomeoneGotBeatUp = true
    end
    if bSomeoneGotBeatUp then
        return
    end
    if PlayerIsInTrigger(TRIGGER._3_02_PARKENTRANCE) and not bOutOfRange and not bGarageOpen then
        PAnimSetActionNode(TRIGGER._BA_BMXGARAGE, "/Global/Door/DoorFunctions/Opening/BIKEGAR", "Act/Props/Door.act")
        bGarageOpen = true
    end
    if PlayerIsInTrigger(TRIGGER._DT_BMXGARAGE) and not bOutOfRange and bGarageOpen then
        MissionTimerStop()
        --print("=== TRIGGER._3_02_PARKENTRANCE ====")
        if PlayerIsInAnyVehicle() then
            gPlayersBike = VehicleFromDriver(gPlayer)
        end
        AreaRemoveSpawner(spawnerID)
        PlayerSetControl(0)
        CameraFade(500, 0)
        Wait(500)
        MissionObjectiveComplete(lureObjID)
        BlipRemove(bikeParkBlipID)
        PedSetMissionCritical(tblGord.id, false)
        if PedIsValid(tblGord.id) then
            PedDelete(tblGord.id)
        end
        if VehicleIsValid(tblGord.bike.id) and gPlayersBike ~= tblGord.bike.id then
            PedDelete(tblGord.bike.id)
        end
        if PedIsValid(tblPrep1.id) then
            PedDelete(tblPrep1.id)
        end
        if VehicleIsValid(tblPrep1.bike.id) and gPlayersBike ~= tblPrep1.bike.id then
            PedDelete(tblPrep1.bike.id)
        end
        for i, prep in tblSpawnedPrep do
            if PedIsValid(prep) then
                PedDelete(prep)
            end
        end
        for i, bike in tblSpawnedBike do
            if VehicleIsValid(bike) and gPlayersBike ~= bike then
                VehicleDelete(bike)
            end
        end
        F_StageFunction = F_StageEnterParkNIS
        SoundPlayStream("MS_FightingPreps.rsm", MUSIC_DEFAULT_VOLUME)
        PedSetTypeToTypeAttitude(5, 13, 2)
        PedSetTypeToTypeAttitude(5, 4, 2)
    end
end

function F_StageEnterParkNIS(tblStageState)
    tblStageState = poop
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    AreaTransitionPoint(62, POINTLIST._3_02_WHPLAYER, 1, true)
    PlayerSetControl(0)
    F_SetupBMXIntro()
    SoundDisableSpeech_ActionTree()
    PedIgnoreStimuli(tblGordWH.id, true)
    PedIgnoreStimuli(tblPrep1WH.id, true)
    PedIgnoreStimuli(tblPrep2WH.id, true)
    PedSetTypeToTypeAttitude(4, 5, 4)
    PedSetTypeToTypeAttitude(4, 13, 4)
    PedSetTypeToTypeAttitude(5, 4, 4)
    PedSetTypeToTypeAttitude(5, 13, 4)
    CameraSetFOV(90)
    CameraSetXYZ(-756.3472, 636.40454, 30.011787, -757.19745, 636.9134, 30.146175)
    CameraSetWidescreen(true)
    PedSetActionNode(tblJohnnyWH.id, "/Global/Vehicles/Bikes/ScriptCalls/3_02_Bait/Johnny/Johnny01", "Act/Vehicles.act")
    Wait(500)
    CameraFade(500, 1)
    Wait(50)
    SoundStopInteractiveStream(0)
    SoundSetAudioFocusCamera()
    SoundPlayStream("MS_Confrontation_NIS.rsm", 0.4, 1000, 1000)
    PedMoveToPoint(gPlayer, 2, POINTLIST._3_02_PLAYERPARK, 3)
    PedMoveToPoint(tblGordWH.id, 2, POINTLIST._3_02_PREPPIESINTRO, 1)
    PedMoveToPoint(tblPrep1WH.id, 2, POINTLIST._3_02_PREPPIESINTRO, 2)
    PedMoveToPoint(tblPrep2WH.id, 2, POINTLIST._3_02_PREPPIESINTRO, 3)
    Wait(1000)
    CameraSetFOV(30)
    CameraSetXYZ(-775.92236, 627.81165, 32.217068, -774.97766, 628.1374, 32.18397)
    PedLockTarget(tblJohnnyWH.id, tblGordWH.id, 3)
    PedLockTarget(tblGordWH.id, tblJohnnyWH.id, 3)
    PedMoveToPoint(tblGreaser1WH.id, 1, POINTLIST._3_02_GREASERSINTRO, 3)
    PedMoveToPoint(tblGreaser2WH.id, 1, POINTLIST._3_02_GREASERSINTRO, 2)
    SoundPlayScriptedSpeechEvent(tblJohnnyWH.id, "M_3_02", 10, "supersize")
    Wait(2000)
    CameraSetXYZ(-762.7651, 634.8076, 30.484234, -761.8078, 635.0941, 30.522736)
    F_WaitForSpeech(tblJohnnyWH.id)
    while SoundSpeechPlaying(tblJohnnyWH.id) do
        Wait(0)
    end
    CameraSetFOV(30)
    CameraSetXYZ(-753.387, 636.1529, 30.08654, -754.3299, 636.4834, 30.124773)
    F_PlaySpeechWait(tblGordWH.id, "M_3_02", 11, "jumbo")
    while SoundSpeechPlaying(tblGordWH.id) do
        Wait(0)
    end
    CameraSetFOV(30)
    CameraSetXYZ(-754.8379, 635.2183, 30.780767, -753.9233, 635.555, 31.003124)
    PedSetActionNode(tblGordWH.id, "/Global/Vehicles/Bikes/ScriptCalls/3_02_Bait/Johnny/Johnny01", "Act/Vehicles.act")
    F_PlaySpeechWait(tblJohnnyWH.id, "M_3_02", 12, "jumbo")
    while SoundSpeechPlaying(tblJohnnyWH.id) do
        Wait(0)
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    SoundPlayStream("MS_FightingPreps.rsm", MUSIC_DEFAULT_VOLUME)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    F_MakePlayerSafeForNIS(false)
    SoundSetAudioFocusPlayer()
    PlayerSetControl(1)
    PedDelete(tblJohnnyWH.id)
    PedDelete(tblGreaser1WH.id)
    PedDelete(tblGreaser2WH.id)
    PedDelete(tblGordWH.id)
    PedDelete(tblPrep1WH.id)
    PedDelete(tblPrep2WH.id)
    VehicleDelete(tblJohnnyWH.bike.id)
    VehicleDelete(tblGreaser1WH.bike.id)
    VehicleDelete(tblGreaser2WH.bike.id)
    VehicleDelete(tblGordWH.bike.id)
    VehicleDelete(tblPrep1WH.bike.id)
    VehicleDelete(tblPrep2WH.bike.id)
    Wait(500)
    PedSetTypeToTypeAttitude(5, 13, 0)
    PedSetTypeToTypeAttitude(5, 4, 0)
    F_StageFunction = F_StageBikeBrawlSetup
end

function F_SetupBMXIntro()
    DATLoad("3_02_BMX.DAT", 2)
    LoadAnimationGroup("NIS_3_02")
    LoadActionTree("Act/Conv/3_02.act")
    DATInit()
    if PlayerIsInAnyVehicle() then
        VehicleSetPosPoint(gPlayersBike, POINTLIST._3_02_PLAYERPARK)
    else
        PlayerSetPosPoint(POINTLIST._3_02_PLAYERPARK)
        gPlayersBike = PlayerGetLastBikeId()
        if VehicleIsValid(gPlayersBike) then
            VehicleSetPosPoint(gPlayersBike, POINTLIST._3_02_PLAYERPARK, 2)
        else
            gPlayersBike = VehicleCreatePoint(282, POINTLIST._3_02_PLAYERPARK, 2)
        end
        PedPutOnBike(gPlayer, gPlayersBike)
    end
    F_TableInitBMXIntro()
    F_TableInitBMX()
    tblJohnnyWH.id = PedCreatePoint(23, POINTLIST._3_02_WHJOHN)
    tblGreaser1WH.id = PedCreatePoint(24, POINTLIST._3_02_WHGR1)
    tblGreaser2WH.id = PedCreatePoint(27, POINTLIST._3_02_WHGR2)
    tblGordWH.id = PedCreatePoint(30, POINTLIST._3_02_WHGORD)
    tblPrep1WH.id = PedCreatePoint(31, POINTLIST._3_02_WHPREP1)
    tblPrep2WH.id = PedCreatePoint(34, POINTLIST._3_02_WHPREP2)
    tblJohnnyWH.bike.id = VehicleCreatePoint(tblJohnnyWH.bike.model, tblJohnnyWH.bike.point)
    tblGreaser1WH.bike.id = VehicleCreatePoint(tblGreaser1WH.bike.model, tblGreaser1WH.bike.point)
    tblGreaser2WH.bike.id = VehicleCreatePoint(tblGreaser2WH.bike.model, tblGreaser2WH.bike.point)
    tblGordWH.bike.id = VehicleCreatePoint(tblGordWH.bike.model, tblGordWH.bike.point)
    tblPrep1WH.bike.id = VehicleCreatePoint(tblPrep1WH.bike.model, tblPrep1WH.bike.point)
    tblPrep2WH.bike.id = VehicleCreatePoint(tblPrep2WH.bike.model, tblPrep2WH.bike.point)
    Wait(500)
    PedPutOnBike(tblJohnnyWH.id, tblJohnnyWH.bike.id)
    PedPutOnBike(tblGreaser1WH.id, tblGreaser1WH.bike.id)
    PedPutOnBike(tblGreaser2WH.id, tblGreaser2WH.bike.id)
    PedPutOnBike(tblGordWH.id, tblGordWH.bike.id)
    PedPutOnBike(tblPrep1WH.id, tblPrep1WH.bike.id)
    PedPutOnBike(tblPrep2WH.id, tblPrep2WH.bike.id)
    Wait(1000)
    PedSetStationary(tblJohnnyWH.id, true)
    VehicleSetStatic(tblJohnnyWH.bike.id, true)
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    if not bSkipNIS then
        if bAmbient then
            SoundPlayAmbientSpeechEvent(pedId, strEvent)
            while SoundSpeechPlaying() do
                if WaitSkippable(1) then
                    bSkipNIS = true
                    return true
                end
            end
        else
            SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
            while SoundSpeechPlaying() do
                if WaitSkippable(1) then
                    bSkipNIS = true
                    return true
                end
            end
        end
    end
    return false
end

function F_StageBikeBrawlSetup(tblStageState)
    --print("=== Setting Up Brawl ====")
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    AreaTransitionPoint(62, POINTLIST._3_02_WHPLAYER, 1, true)
    if VehicleIsValid(gPlayersBike) then
        VehicleSetPosPoint(gPlayersBike, POINTLIST._3_02_WHPLAYERBIKE)
    else
        gPlayersBike = VehicleCreatePoint(282, POINTLIST._3_02_WHPLAYERBIKE)
    end
    PedPutOnBike(gPlayer, gPlayersBike)
    shared.tblStageState.tblSpawnedPrep = nil
    shared.tblStageState.tblSpawnedBike = nil
    shared.tblStageState.tblSpawnQueue = nil
    tblStageState.tblSpawnedPrep = nil
    tblStageState.tblSpawnedBike = nil
    tblStageState.tblSpawnQueue = nil
    PedSetTypeToTypeAttitude(4, 5, 0)
    PedSetTypeToTypeAttitude(4, 13, 4)
    PedSetTypeToTypeAttitude(5, 4, 0)
    PedSetTypeToTypeAttitude(5, 13, 0)
    F_CreatePed(tblGordWH)
    F_CreatePed(tblPrep1WH)
    F_CreatePed(tblPrep2WH)
    while not PlayerIsInAnyVehicle() do
        Wait(0)
    end
    F_CreatePed(tblJohnnyWH)
    F_CreatePed(tblGreaser1WH)
    F_CreatePed(tblGreaser2WH)
    Wait(250)
    F_StickThemToTheirBikes(tblPrepWH)
    F_StickThemToTheirBikes(tblGreaseWH)
    Wait(250)
    PedMakeTargetable(tblJohnnyWH.id, false)
    PedMakeTargetable(tblGreaser1WH.id, false)
    PedMakeTargetable(tblGreaser2WH.id, false)
    PedBikeBrawl(tblJohnnyWH.id)
    PedBikeBrawl(tblGreaser1WH.id)
    PedBikeBrawl(tblGreaser2WH.id)
    PedBikeBrawl(tblGordWH.id)
    PedBikeBrawl(tblPrep1WH.id)
    PedBikeBrawl(tblPrep2WH.id)
    CameraReturnToPlayer()
    CameraReset()
    CameraFollowPed(gPlayer)
    Wait(500)
    CameraFade(500, 1)
    Wait(500)
    local ped1 = PedGetHealth(tblJohnnyWH.id)
    local ped2 = PedGetHealth(tblGreaser1WH.id)
    local ped3 = PedGetHealth(tblGreaser2WH.id)
    local ped4 = PedGetHealth(tblGordWH.id)
    local ped5 = PedGetHealth(tblPrep1WH.id)
    local ped6 = PedGetHealth(tblPrep2WH.id)
    PedSetHealth(tblJohnnyWH.id, ped1 * 2)
    PedSetHealth(tblGreaser1WH.id, ped2 * 2)
    PedSetHealth(tblGreaser2WH.id, ped3 * 2)
    PedSetHealth(tblGordWH.id, ped4 * 2)
    PedSetHealth(tblPrep1WH.id, ped5 * 2)
    PedSetHealth(tblPrep2WH.id, ped6 * 2)
    PlayerSetControl(1)
    PedSetMissionCritical(tblJohnnyWH.id, true, cbCriticalJohnny)
    brawlObjID = MissionObjectiveAdd("3_02_BRAWLOBJ")
    TextPrint("3_02_BRAWLOBJ", 5, 1)
    CreateThread("T_DidPlayerHitGord")
    F_StageFunction = F_StageBikeBrawl
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function cbCriticalJohnny()
    if PedIsValid(tblJohnnyWH.id) and (PedGetHealth(tblJohnnyWH.id) <= 0 or PedIsDead(tblJohnnyWH.id)) then
        SoundPlayMissionEndMusic(false, 8)
        MissionFail(false, true, "3_02_JOHNNYKO")
        missionOver = true
    end
end

function F_StickThemToTheirBikes(tbl)
    for i, ped in tbl do
        if not PedIsInAnyVehicle(ped.id) then
            PedPutOnBike(ped.id, ped.bike.id)
        end
    end
end

function F_StageBikeBrawl(tblStageState)
    local prepAlive = false
    if bSomeoneGotBeatUp then
        return
    end
    for g, ped in tblGreaseWH do
        if PedIsValid(ped.id) then
            if PedIsInAnyVehicle(ped.id) and not PedIsDoingTask(ped.id, "/Global/AI/OnBike/BikeGeneralObjectives/BBrawl", false) then
                PedClearObjectives(ped.id)
                PedBikeBrawl(ped.id)
            elseif not ped.bAttackOnFoot then
                PedClearObjectives(ped.id)
                local target = RandomTableElement(tblPrepWH)
                if PedIsValid(target.id) and not PedIsDead(target.id) then
                    PedAttack(ped.id, target.id, 1)
                    ped.bAttackOnFoot = true
                end
            end
            if PedGetAmmoCount(ped.id, 301) == 0 then
                PedSetWeaponNow(ped.id, 301, 10, false)
            end
        end
    end
    for p, ped in tblPrepWH do
        if prepAlive == false and not PedIsDead(ped.id) then
            prepAlive = true
        end
        if PedIsValid(ped.id) then
            if PedIsInAnyVehicle(ped.id) and not PedIsDoingTask(ped.id, "/Global/AI/OnBike/BikeGeneralObjectives/BBrawl", false) then
                PedClearObjectives(ped.id)
                PedBikeBrawl(ped.id)
            elseif not ped.bAttackOnFoot then
                PedClearObjectives(ped.id)
                local target = RandomTableElement(tblPrepWH)
                if PedIsValid(target.id) and not PedIsDead(target.id) then
                    PedAttack(ped.id, target.id, 1)
                    ped.bAttackOnFoot = true
                end
            end
            if PedGetAmmoCount(ped.id, 301) == 0 then
                PedSetWeaponNow(ped.id, 301, 10, false)
            end
        end
    end
    if not prepAlive then
        F_EndCut()
    end
end

function F_StageBikeBrawlComplete(tblStageState)
end

function F_PrepAddToSpawnQueue(pedID)
    --print("F_PrepAddToSpawnQueue() start")
    table.insert(shared.tblStageState.tblSpawnQueue, pedID)
    --print("F_PrepAddToSpawnQueue() end")
end

function F_PrepSetBiking(pedID)
    --print("F_PrepSetBiking() start")
    local tblSpawnedPrep = shared.tblStageState.tblSpawnedPrep
    local tblSpawnedBike = shared.tblStageState.tblSpawnedBike
    if table.getn(tblSpawnedPrep) == numAmbientPrep then
        local ambPedID = table.remove(tblSpawnedPrep, 1)
        local ambBikeID = table.remove(tblSpawnedBike, 1)
        if PedIsValid(ambPedID) then
            PedMakeAmbient(ambPedID)
        end
        if VehicleIsValid(ambBikeID) then
            VehicleMakeAmbient(ambBikeID)
        end
    end
    PedSetFlag(pedID, 31, false)
    PedOverrideStat(pedID, 24, 100)
    PedOverrideStat(pedID, 30, 80)
    PedOverrideStat(pedID, 9, 100)
    local x, y, z = PedGetPosXYZ(pedID)
    local bikeID = VehicleCreateXYZ(283, x, y, z)
    PedPutOnBike(pedID, bikeID)
    PedSetWeapon(pedID, RandomTableElement(tblPrepWeapon), 99)
    PedAttackPlayer(pedID, 3)
    table.insert(tblSpawnedPrep, pedID)
    table.insert(tblSpawnedBike, bikeID)
end

function F_JumpNodes()
    tblJump = {
        3,
        8,
        18,
        23,
        29,
        37
    }
    tblJump01 = { 3 }
    tblJump02 = { 3 }
    tblJump03 = {
        6,
        11,
        16
    }
    tblJump04 = { 2 }
end

function F_EndCut()
    bSkipNIS = false
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    Wait(10)
    CameraFade(1000, 0)
    Wait(1000)
    PedSetMissionCritical(tblJohnnyWH.id, false)
    F_PlayerDismountBike()
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(true)
    if PlayerIsInAnyVehicle() then
        PlayerDetachFromVehicle()
        Wait(100)
        while PlayerIsInAnyVehicle() do
            Wait(0)
        end
    end
    if PedIsValid(tblGordWH.id) then
        PedDelete(tblGordWH.id)
    end
    if PedIsValid(tblPrep1WH.id) then
        PedDelete(tblPrep1WH.id)
    end
    if PedIsValid(tblPrep2WH.id) then
        PedDelete(tblPrep2WH.id)
    end
    PedSetPosPoint(gPlayer, POINTLIST._3_02_PLAYERENDCUT)
    PedSetMissionCritical(tblJohnnyWH.id, false)
    PedDelete(tblJohnnyWH.id)
    tblJohnnyWH.id = PedCreatePoint(23, POINTLIST._3_02_JOHNNYENDCUT)
    PedFaceObjectNow(tblJohnnyWH.id, gPlayer, 3)
    if VehicleIsValid(tblJohnnyWH.bike.id) then
        VehicleDelete(tblJohnnyWH.bike.id)
    end
    if not PedIsDead(tblGreaser1WH.id) then
        PedDelete(tblGreaser1WH.id)
        tblGreaser1WH.id = PedCreatePoint(24, POINTLIST._3_02_GREASERSCUT, 1)
        if VehicleIsValid(tblGreaser1WH.bike.id) then
            VehicleDelete(tblGreaser1WH.bike.id)
        end
    end
    if not PedIsDead(tblGreaser2WH.id) then
        PedDelete(tblGreaser2WH.id)
        tblGreaser2WH.id = PedCreatePoint(27, POINTLIST._3_02_GREASERSCUT, 2)
        if VehicleIsValid(tblGreaser2WH.bike.id) then
            VehicleDelete(tblGreaser2WH.bike.id)
        end
    end
    PedFaceObjectNow(tblJohnnyWH.id, gPlayer, 3)
    Wait(100)
    if not PedIsDead(tblGreaser1WH.id) then
        PedFaceObjectNow(tblGreaser1WH.id, gPlayer, 3)
    end
    if not PedIsDead(tblGreaser2WH.id) then
        PedFaceObjectNow(tblGreaser2WH.id, gPlayer, 3)
    end
    PedFaceObjectNow(gPlayer, tblJohnnyWH.id, 2)
    Wait(250)
    PedFaceObjectNow(tblJohnnyWH.id, gPlayer, 3)
    if not PedIsDead(tblGreaser1WH.id) then
        PedFaceObjectNow(tblGreaser1WH.id, gPlayer, 3)
    end
    if not PedIsDead(tblGreaser2WH.id) then
        PedFaceObjectNow(tblGreaser2WH.id, gPlayer, 3)
    end
    PedFaceObjectNow(gPlayer, tblJohnnyWH.id, 2)
    Wait(2000)
    CameraSetFOV(30)
    CameraSetXYZ(-761.0721, 635.9963, 30.517975, -760.0867, 635.83264, 30.472534)
    CameraFade(1000, 1)
    Wait(500)
    F_EndText(bPlayerHitGord)
    F_RunOff()
    bCompletedMission = true
    MinigameSetCompletion("M_PASS", true, 2000, "3_02_UNLOCK")
    MinigameAddCompletionMsg("MRESPECT_GP5", 2)
    MinigameAddCompletionMsg("MRESPECT_PM5", 1)
    SoundPlayMissionEndMusic(true, 8)
    Wait(2000)
    if PedIsValid(tblJohnnyWH.id) then
        PedDelete(tblJohnnyWH.id)
    end
    if PedIsValid(tblGreaser1WH.id) then
        PedDelete(tblGreaser1WH.id)
    end
    if PedIsValid(tblGreaser2WH.id) then
        PedDelete(tblGreaser2WH.id)
    end
    Wait(2000)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(501)
    CameraReset()
    CameraReturnToPlayer()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SetFactionRespect(5, GetFactionRespect(5) - 5)
    SetFactionRespect(4, GetFactionRespect(4) + 5)
    MissionSucceed(false, false, false)
    missionOver = true
    Wait(500)
    CameraFade(500, 1)
    Wait(101)
    PlayerSetControl(1)
end

function F_RunOff()
    PedMoveToPoint(tblJohnnyWH.id, 1, POINTLIST._3_02_PLAYERPARK, 4)
    if not PedIsDead(tblGreaser1WH.id) then
        PedMoveToPoint(tblGreaser1WH.id, 1, POINTLIST._3_02_PLAYERPARK, 4)
    end
    if not PedIsDead(tblGreaser2WH.id) then
        PedMoveToPoint(tblGreaser2WH.id, 1, POINTLIST._3_02_PLAYERPARK, 4)
    end
end

function F_EndText(bPlayerHitGord)
    if not bPlayerHitGord then
        CameraSetFOV(30)
        CameraSetXYZ(-761.0721, 635.9963, 30.517975, -760.0867, 635.83264, 30.472534)
        PedSetActionNode(tblJohnnyWH.id, "/Global/3_02/NIS/Outro/Johnny/Johnny_01", "Act/Conv/3_02.act")
        F_PlaySpeechWait(tblJohnnyWH.id, "M_3_02", 16, "jumbo")
        while SoundSpeechPlaying(tblJohnnyWH.id) do
            Wait(0)
        end
        PlayerAddMoney(1000)
        CameraSetFOV(30)
        CameraSetXYZ(-755.16815, 632.4347, 30.815426, -755.8021, 633.20026, 30.706554)
        F_PlaySpeechWait(gPlayer, "M_3_02", 17, "jumbo")
        while SoundSpeechPlaying(gPlayer) do
            Wait(0)
        end
    elseif bPlayerHitGord then
        CameraSetFOV(30)
        CameraSetXYZ(-761.0721, 635.9963, 30.517975, -760.0867, 635.83264, 30.472534)
        PedSetActionNode(tblJohnnyWH.id, "/Global/3_02/NIS/Outro/Johnny/Johnny_02", "Act/Conv/3_02.act")
        F_PlaySpeechWait(tblJohnnyWH.id, "M_3_02", 14, "jumbo")
        while SoundSpeechPlaying(tblJohnnyWH.id) do
            Wait(0)
        end
        CameraSetFOV(30)
        CameraSetXYZ(-755.16815, 632.4347, 30.815426, -755.8021, 633.20026, 30.706554)
        F_PlaySpeechWait(gPlayer, "M_3_02", 15, "jumbo")
        while SoundSpeechPlaying(gPlayer) do
            Wait(0)
            CameraDefaultFOV()
            CameraReturnToPlayer(true)
        end
    end
end

function T_DidPlayerHitGord()
    while MissionActive() and bPlayerHitGord == false do
        if PedGetWhoHitMeLast(tblGordWH.id) == gPlayer then
            bPlayerHitGord = true
        end
        Wait(0)
    end
end

function MissionSetup()
    PlayCutsceneWithLoad("3-02", true)
    MissionDontFadeIn()
    DATLoad("3_02.DAT", 2)
    DATInit()
end

function MissionCleanup()
    SoundStopInteractiveStream()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(false)
    EnablePOI()
    shared.tblStageState.tblSpawnedPrep = nil
    shared.tblStageState.tblSpawnedBike = nil
    shared.tblStageState.tblSpawnQueue = nil
    shared.tblStageState = nil
    tblStageState.tblSpawnedPrep = nil
    tblStageState.tblSpawnedBike = nil
    tblStageState.tblSpawnQueue = nil
    tblStageState = nil
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    MissionTimerStop()
    if bGarageOpen and AreaGetVisible() == 0 then
        PAnimSetActionNode(TRIGGER._BA_BMXGARAGE, "/Global/Door/DoorFunctions/Closing/BIKEGAR", "Act/Props/Door.act")
    end
    if PlayerIsInTrigger(TRIGGER._DT_BMXGARAGE) then
        local x, y, z = GetPointList(POINTLIST._3_02_PARKSPAWN)
        PlayerSetPosSimple(x, y, z)
    end
    if AreaGetVisible() == 0 then
        if PedIsValid(tblPrep1.id) then
            PedMakeAmbient(tblPrep1.id)
        end
        if VehicleIsValid(tblGord.bike.id) then
            VehicleMakeAmbient(tblGord.bike.id)
        end
        if VehicleIsValid(tblPrep1.bike.id) and gPlayersBike ~= tblPrep1.bike.id then
            VehicleMakeAmbient(tblPrep1.bike.id)
        end
        for i, prep in tblSpawnedPrep do
            if PedIsValid(prep) then
                PedMakeAmbient(prep)
            end
        end
        for i, bike in tblSpawnedBike do
            if VehicleIsValid(bike) then
                VehicleMakeAmbient(bike)
            end
        end
    end
    if bCompletedMission then
        shared.bBMXWarehouseInit = false
        if AreaGetVisible() == 62 then
            if VehicleIsValid(tblJohnnyWH.bike.id) then
                VehicleMakeAmbient(tblJohnnyWH.bike.id)
            end
            if VehicleIsValid(tblGreaser1WH.bike.id) then
                VehicleMakeAmbient(tblGreaser1WH.bike.id)
            end
            if VehicleIsValid(tblGreaser2WH.bike.id) then
                VehicleMakeAmbient(tblGreaser2WH.bike.id)
            end
            if VehicleIsValid(tblGordWH.bike.id) then
                VehicleMakeAmbient(tblGordWH.bike.id)
            end
            if VehicleIsValid(tblPrep1WH.bike.id) then
                VehicleMakeAmbient(tblPrep1WH.bike.id)
            end
            if VehicleIsValid(tblPrep2WH.bike.id) then
                VehicleMakeAmbient(tblPrep2WH.bike.id)
            end
        end
    elseif AreaGetVisible() == 62 and not F_PedIsDead(gPlayer) then
        AreaTransitionPoint(0, POINTLIST._3_02_PARKSPAWN, 1, false)
    end
    DATUnload(2)
    UnLoadAnimationGroup("NIS_3_02")
end

function main()
    AreaTransitionPoint(0, POINTLIST._3_02_JOHNNY, 1, true)
    DisablePOI()
    F_TableInitMain()
    AreaSetDoorLocked(TRIGGER._DT_TPOOR_BMX, true)
    LoadPedModels({
        30,
        34,
        23,
        27,
        24
    })
    while not VehicleRequestModel(283) do
        Wait(0)
    end
    --print("=== Loaded AquaBike ===")
    while not VehicleRequestModel(283) do
        Wait(0)
    end
    LoadPedModels(tblPrepModel)
    LoadWeaponModels(tblPrepWeapon)
    PlayerSetPosPoint(POINTLIST._3_02_PLAYER)
    VehicleCreatePoint(282, POINTLIST._3_02_PLAYERBIKE)
    CameraFade(1000, 1)
    Wait(1000)
    shared.test3_02active = true
    F_StageGetGordSetup(tblStageState)
    while not (not MissionActive() or missionOver) do
        F_StageFunction(tblStageState)
        if bSomeoneGotBeatUp then
            break
        end
        Wait(0)
    end
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
