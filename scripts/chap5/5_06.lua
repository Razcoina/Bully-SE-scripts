local gDebug = false
local Russell, idBike

function MissionSetup()
    MissionDontFadeIn()
    PlayCutsceneWithLoad("5-06", true)
    DATLoad("5_06.DAT", 2)
    DATInit()
    LoadActionTree("Act/Conv/5_07a.act")
    AreaTransitionPoint(0, POINTLIST._5_06_PLAYERSTART, nil, true)
    VehicleRequestModel(273)
    PedRequestModel(75)
    SoundPlayInteractiveStream("MS_RunningLow02.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_RunningMid.rsm", 0.6)
end

function MissionCleanup()
    --print("INIT MISSION CLEANUP FOR 5_06")
    GeometryInstance("RI_GarDoorClose", false, 480.175, 351.333, 19.6935, true)
    if geoIndex then
        DeletePersistentEntity(geoIndex, geoEntityType)
    end
    if iDoor then
        DeletePersistentEntity(iDoor, oDoor)
    end
    if PlayerIsInTrigger(TRIGGER._5_06_RUSSELLGARAGE) then
        if PedIsInAnyVehicle(gPlayer) then
            PlayerDetachFromVehicle()
        end
        PlayerSetPosPoint(POINTLIST._5_06_RUSSELLWALKTO, 1)
    end
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundStopInteractiveStream()
    DATUnload(2)
    --print("END MISSION CLEANUP FOR 5_06")
end

function main()
    gMissionRunning = true
    if gDebug then
        StageFunction = F_StageThreeSetup()
    else
        StageFunction = F_StageOneSetup
    end
    local rsx, rsy, rsz = -1, -1, -1
    local plx, ply, plz = -1, -1, -1
    local distance = -1
    LoadModels({
        75,
        134,
        273
    })
    while gMissionRunning do
        StageFunction()
        if gPlayerFollowingRussell then
            --print("Player Following Russell")
            if AreaGetVisible() ~= 0 then
                gGotAway = true
            end
            plx, ply, plz = PedGetPosXYZ(gPlayer)
            rsx, rsy, rsz = PedGetPosXYZ(idRussell)
            distance = DistanceBetweenCoords2d(plx, ply, rsx, rsy)
            if 75 < distance then
                gGotAway = true
            elseif 50 < distance then
                TextPrint("5_06_08", 2, 1)
            end
        end
        if gGotAway then
            SoundPlayMissionEndMusic(false, 10)
            if PedIsValid(idRussell) then
                PedDelete(idRussell)
            end
            if idBike and VehicleIsValid(idBike) then
                VehicleDelete(idBike)
            end
            MissionFail(false, true, "5_06_09")
            gMissionRunning = false
        end
        Wait(0)
    end
    PlayerSetControl(1)
end

function CbRussellCrashing(pedId, pathId, pathNode)
    if pathNode == 3 then
        gRussellCrashed = true
    end
end

function CbRussellOnBike(pedId, pathId, pathNode)
    if pathNode == 67 then
        gRussellFinished = true
    end
end

function CbCopBike(pedId, pathId, pathNode)
    if pathNode == 6 then
        gCopArrived = true
    end
end

function F_StageOneSetup()
    idPete = PedCreatePoint(134, POINTLIST._5_06_PLAYERSTART, 2)
    PedSetPedToTypeAttitude(idPete, 13, 4)
    while not VehicleRequestModel(273) do
        Wait(0)
    end
    CameraReturnToPlayer(true)
    CameraFade(500, 1)
    Wait(600)
    PedMakeAmbient(idPete)
    PedWander(idPete, 0)
    gObjBlip = BlipAddPoint(POINTLIST._5_06_RUSSELL, 0)
    TextPrint("5_06_01", 5, 1)
    gOBjectiveTable = {}
    gOBjectiveTable[1] = MissionObjectiveAdd("5_06_01")
    StageFunction = F_StageOne
    gX, gY, gZ = GetPointFromPointList(POINTLIST._5_06_NISRECRUITRUSSELL, 1)
end

function F_StageOne()
    if PlayerIsInAreaXYZ(gX, gY, gZ, 2, 7) then
        BlipRemove(gObjBlip)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        SoundPreloadStreamNoLoop("5-06_Garage_NIS.rsm", 1)
        PlayerSetControl(0)
        SoundLoadBank("OBJECTS_3\\HrlyLeev.bnk")
        Wait(600)
        MissionObjectiveComplete(gOBjectiveTable[1])
        LoadModels({ 275, 276 })
        CameraSetWidescreen(true)
        if PlayerIsInAnyVehicle() then
            PlayerDetachFromVehicle()
        end
        F_MakePlayerSafeForNIS(true)
        F_DeleteUnusedVehicles(gX, gY, gZ, 4)
        idRussell = PedCreatePoint(75, POINTLIST._5_06_NISRECRUITRUSSELL, 2)
        PedSetPedToTypeAttitude(idRussell, 13, 4)
        GeometryInstance("RI_GarDoorClose", true, 480.175, 351.333, 19.6935, false)
        PAnimCreate(TRIGGER._5_06_RUSSELLGATE)
        PlayerSetPosPoint(POINTLIST._5_06_NISRECRUITRUSSELL, 1)
        PedSetInvulnerable(idRussell, true)
        PedIgnoreStimuli(idRussell, true)
        Wait(50)
        idPlayerBike = VehicleCreatePoint(276, POINTLIST._5_06_PLAYERBIKE)
        idBike = VehicleCreatePoint(275, POINTLIST._5_06_RUSELLBIKESTART, 1)
        CameraSetFOV(80)
        CameraSetXYZ(487.0662, 345.84702, 19.144901, 486.40204, 346.59164, 19.209312)
        Wait(500)
        CameraFade(1000, 1)
        Wait(500)
        SoundPlayPreloadedStream()
        PedSetActionNode(gPlayer, "/Global/5_07a/NIS/RecruitRussell/Jimmy/JimmyKnock", "Act/Conv/5_07A.act")
        F_PlaySpeechAndWait(gPlayer, "M_5_06", 16, "jumbo")
        Wait(2000)
        PedPutOnBike(idRussell, idBike)
        PedStop(idRussell)
        PedClearObjectives(idRussell)
        PedSetFocus(idRussell, gPlayer)
        PedLockTarget(idRussell, gPlayer)
        PAnimSetActionNode(TRIGGER._5_06_RUSSELLGATE, "/Global/RSGrDoor/GarageOpens", "Act/Props/RSGrDoor.act")
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        PedFaceObject(gPlayer, idRussell, 2, 1)
        Wait(500)
        PedStop(idRussell)
        PedClearObjectives(idRussell)
        CameraSetFOV(30)
        CameraSetXYZ(483.9019, 348.02325, 19.313461, 483.08096, 348.59363, 19.29178)
        Wait(3000)
        CameraSetFOV(80)
        CameraSetXYZ(479.0536, 351.00787, 19.511131, 478.19217, 351.5156, 19.51383)
        F_PlaySpeechAndWait(idRussell, "M_5_06", 127, "jumbo")
        SoundFadeWithCamera(true)
        MusicFadeWithCamera(true)
        local xv, yv, zv = GetPointList(POINTLIST._5_06_PLAYERBIKE)
        idBikeBlip = BlipAddXYZ(xv, yv, zv + 0.5, 0, 2)
        StageFunction = F_StageTwoSetup
    end
end

function F_StageTwoSetup()
    Wait(2000)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(600)
    Wait(100)
    PedFaceObject(gPlayer, idRussell, 2, 0)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraDefaultFOV()
    CameraReset()
    CameraFade(500, 1)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    gOBjectiveTable[2] = MissionObjectiveAdd("5_06_04")
    TextPrint("5_06_04", 5, 1)
    local gRussellTimer = GetTimer()
    local gWaitingForPlayer = true
    while gWaitingForPlayer do
        if PlayerIsInAnyVehicle() or GetTimer() - gRussellTimer > 10000 then
            gWaitingForPlayer = false
        end
        Wait(0)
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    if not PedIsInVehicle(idRussell, idBike) then
        local timeout = GetTimer()
        while not PedIsInVehicle(idRussell, idBike) do
            PedEnterVehicle(idRussell, idBike)
            Wait(0)
            if GetTimer() - timeout > 4000 then
                PedPutOnBike(idRussell, idBike)
            end
        end
    end
    BlipRemove(idBikeBlip)
    gPlayerFollowingRussell = true
    PedSetFocus(idRussell, gPlayer)
    PedLockTarget(idRussell, gPlayer, 3)
    PedPathNodeReachedDistance(idRussell, 2.5)
    PedFleeOnPathOnBike(idRussell, PATH._5_06_MAINBIKEPATH, 0)
    SoundPlay2D("HarleyLeaves")
    PedLockTarget(idRussell, gPlayer)
    PedOverrideStat(idRussell, 9, 75)
    PedOverrideStat(idRussell, 24, 75)
    PedOverrideStat(idRussell, 25, 125)
    PedOverrideStat(idRussell, 26, 10)
    PedOverrideStat(idRussell, 27, 10)
    PedOverrideStat(idRussell, 29, 60)
    TextPrint("5_06_05", 5, 1)
    MissionObjectiveComplete(gOBjectiveTable[2])
    gOBjectiveTable[3] = MissionObjectiveAdd("5_06_05")
    AddBlipForChar(idRussell, 11, 0, 4)
    SoundPlayInteractiveStreamLocked("MS_BikeFastHigh.rsm", 0.8)
    StageFunction = F_StageTwo
end

function F_StageTwo()
    if PedIsValid(idRussell) and (not PedIsInVehicle(idRussell, idBike) or PedIsDead(idRussell)) or not PedIsValid(idRussell) then
        gGotAway = true
    end
    if not gBarricadeCreated and PlayerIsInTrigger(TRIGGER._5_06_BRIDGE) then
        BrokenGateId, BrokenGateObject = CreatePersistentEntity("BarrGate", 150.232, -483.16, 2.05389, 125, 0)
        GeometryInstance("BarrGate", false, 150.232, -483.16, 2.05389, 125, true)
        PAnimSetActionNode("BarrGate", 150.232, -483.16, 2.05389, 125, "/Global/5_07a/NIS/Gate/GateStanding", "Act/Conv/5_07a.act")
        gBarricadeCreated = true
    end
    if PedIsInTrigger(idRussell, TRIGGER._5_06_BIKETRIGGER) then
        if not gRussellObjs then
            PedStop(idRussell)
            PedClearObjectives(idRussell)
            gRussellObjs = true
            gRussellTimer = GetTimer()
        end
        if PlayerIsInTrigger(TRIGGER._5_06_BIKETRIGGER) or gRussellObjs and GetTimer() - gRussellTimer > 3000 then
            PlayerSetControl(0)
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
            CameraSetWidescreen(true)
            PedStop(idRussell)
            PedClearObjectives(idRussell)
            SoundUnLoadBank("OBJECTS_3\\HrlyLeev.bnk")
            local x, y, z = PedGetPosXYZ(idRussell)
            if not PlayerIsInAreaXYZ(x, y, z, 10, 0) then
                PlayerSetPosPoint(POINTLIST._5_06_RUSSELLNIS, 2)
            end
            StageFunction = F_StageThreeSetup
        end
    end
end

function F_StageThreeSetup()
    if gDebug then
        AreaTransitionPoint(0, POINTLIST._5_06_RUSSELLNIS, 2, true)
        idRussell = PedCreatePoint(75, POINTLIST._5_06_RUSSELLNIS, 3)
        idBike = VehicleCreatePoint(275, POINTLIST._5_06_RUSSELLNIS, 1)
        PedPutOnBike(idRussell, idBike)
    end
    SoundPreloadStreamNoLoop("5-06_HarleyLeavesExplode_NIS.rsm", 1)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaClearAllVehicles()
    shared.enclaveGateRespawn = 3
    CameraSetFOV(90)
    CameraSetXYZ(155.06241, -475.2318, 3.450526, 154.53073, -476.02295, 3.75262)
    Wait(500)
    GeometryInstance("BarrGate", false, 150.232, -483.16, 2.05389, 125, true)
    PAnimSetActionNode("BarrGate", 150.232, -483.16, 2.05389, 125, "/Global/5_07a/NIS/Gate/GateStanding", "Act/Conv/5_07a.act")
    local timeout = GetTimer() + 5000
    while shared.enclaveGateRespawn do
        if timeout < GetTimer() then
            --print("[RAUL] BROKE OUT WITH TIMEOUT")
            break
        end
        Wait(0)
    end
    AreaClearAllVehicles()
    CameraFade(-1, 1)
    Wait(50)
    SoundPlayScriptedSpeechEvent(gPlayer, "M_5_06", 18, "jumbo", true)
    Wait(2500)
    CameraSetFOV(80)
    CameraSetXYZ(184.81725, -456.4249, 3.527322, 185.7978, -456.2375, 3.584658)
    Wait(500)
    PedFollowPath(idRussell, PATH._5_06_RUSSELLBIKE, 0, 2, CbRussellCrashing)
    SoundPlayPreloadedStream()
    SoundPlayScriptedSpeechEvent(idRussell, "M_5_06", 12, "jumbo", true)
    Wait(500)
    CameraSetFOV(80)
    CameraSetXYZ(154.55426, -473.3268, 3.962846, 154.18558, -474.2389, 4.14174)
    CameraLookAtObject(idRussell, 2, true)
    Wait(1000)
    CameraSetXYZ(157.34682, -474.98764, 3.13711, 156.72914, -475.728, 3.402073)
    Wait(500)
    local timeout = GetTimer() + 8000
    while not gRussellCrashed do
        if PedIsInTrigger(idRussell, TRIGGER._5_06_BARRICADECRASH) then
            break
        end
        if timeout < GetTimer() then
            break
        end
        Wait(0)
    end
    local x, y, z = GetPointFromPointList(POINTLIST._5_06_EXPLOSIONS, 1)
    gExplosionEffect = EffectCreate("BigExplosion", x, y, z)
    x, y, z = GetPointFromPointList(POINTLIST._5_06_EXPLOSIONS, 2)
    gExplosionEffect2 = EffectCreate("BigExplosion", x, y, z)
    x, y, z = GetPointFromPointList(POINTLIST._5_06_EXPLOSIONS, 3)
    gExplosionEffect3 = EffectCreate("BigExplosion", x, y, z)
    x, y, z = GetPointFromPointList(POINTLIST._5_06_EXPLOSIONS, 4)
    gExplosionEffect4 = EffectCreate("BigExplosion", x, y, z)
    x, y, z = GetPointFromPointList(POINTLIST._5_06_EXPLOSIONS, 5)
    gExplosionEffect5 = EffectCreate("BigExplosion", x, y, z)
    x, y, z = GetPointFromPointList(POINTLIST._5_06_EXPLOSIONS, 6)
    gExplosionEffect6 = EffectCreate("CarDestroyed", x, y, z)
    --print("[RAUL] AFTER ALL EFFECTS")
    PAnimSetActionNode("BarrGate", 150.232, -483.16, 2.05389, 125, "/Global/5_07a/NIS/Gate/GateExplodes", "Act/Conv/5_07a.act")
    --print("[RAUL] AFTER OPENING ANIMATION")
    Wait(1800)
    CameraFade(500, 0)
    Wait(600)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    PlayerSetControl(1)
    --print("[RAUL] BEFORE GEOMETRY INSTANCE OFF")
    VehicleRevertToDefaultAmbient()
    DeletePersistentEntity(BrokenGateId, BrokenGateObject)
    shared.forceRun5_07 = true
    gMissionRunning = false
    MissionDontFadeInAfterCompetion()
    MissionSucceed(true, false, false)
end

function F_StageThree()
    if PlayerIsInTrigger(TRIGGER._5_06_BARRICADEDOOR) then
        BlipRemove(gObjBlip)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        PlayerSetControl(0)
        Wait(600)
        CameraSetWidescreen(true)
        idCop = PedCreatePoint(97, POINTLIST._5_06_COPEVENT, 3)
        idBike = VehicleCreatePoint(275, POINTLIST._5_06_COPEVENT, 1)
        idWorker = PedCreatePoint(123, POINTLIST._5_06_COPEVENT, 2)
        PedFollowPath(idWorker, PATH._5_06_WORKERPATH, 0, 0)
        PedWarpIntoCar(idCop, idBike)
        CameraLookAtObject(gPlayer, 3, true, 1.5)
        CameraSetPath(PATH._5_06_BARRICADECAM, true)
        CameraFade(500, 1)
        Wait(600)
        TextPrint("5_06_06", 3, 2)
        WaitSkippable(3000)
        TextPrint("5_06_07", 3, 2)
        WaitSkippable(3000)
        PedFaceObject(gPlayer, idCop, 2, 1, true)
        Wait(50)
        PedFaceObject(idRussell, idCop, 2, 1, true)
        Wait(500)
        CameraLookAtObject(idCop, 2, false)
        PedFollowPath(idCop, PATH._5_06_BIKEPATH, 0, 0, CbCopBike)
        while not gCopArrived do
            Wait(0)
        end
        PedExitVehicle(idCop)
        Wait(1000)
        PedMoveToXYZ(idCop, 0, 187.943, -450.61)
        Wait(2000)
        CameraLookAtObject(gPlayer, 3, false, 1.5)
        TextPrintString("Jimmy: Maybe we can steal that bike and crash it against the barricade!", 3, 2)
        WaitSkippable(3000)
        TextPrintString("Russell: Sure, I like crushing!", 3, 2)
        WaitSkippable(3000)
        TextPrintString("Jimmy: I'll distract the cop, you drive the bike!", 3, 2)
        WaitSkippable(3000)
        CameraFade(500, 0)
        Wait(550)
        CameraReset()
        CameraReturnToPlayer()
        CameraSetWidescreen(false)
        CameraFade(500, 1)
        PlayerSetControl(1)
        TextPrintString("Get to the Bike", 5, 1)
        gObjBlip = AddBlipForCar(idBike, 0, 4)
        Wait(500)
        SoundFadeWithCamera(true)
        MusicFadeWithCamera(true)
        StageFunction = F_StageFourSetup
    end
end

function F_StageFourSetup()
    if PlayerIsInTrigger(TRIGGER._5_06_BIKETRIGGER) then
        BlipRemove(gObjBlip)
        PedDismissAlly(gPlayer, idRussell)
        Wait(50)
        PedEnterVehicle(idRussell, idBike)
        while not PedIsInVehicle(idRussell, idBike) do
            Wait(0)
        end
        PedFollowPath(idRussell, PATH._5_06_RUSSELLBIKE, 0, 0, CbRussellOnBike)
        while not gRussellCrashed do
            Wait(0)
        end
        TextPrintString("PLACEHOLDER: Russell crashes against barricade", 3, 2)
        Wait(5000)
        CameraFade(1000, 0)
        Wait(1000)
        PlayerDetachFromVehicle()
        MissionSucceed(true, false, false)
    end
end

function F_DeleteUnusedVehicles(x, y, z, radius)
    local tblFoundPeds = {}
    local tblFoundVehicles = {}
    tblFoundPeds = {
        PedFindInAreaXYZ(x, y, z, radius)
    }
    tblFoundVehicles = VehicleFindInAreaXYZ(x, y, z, radius, false)
    if tblFoundVehicles then
        for i, vehicle in tblFoundVehicles do
            local bDelete = true
            for _, ped in tblFoundPeds do
                if PedIsValid(ped) and PedIsInVehicle(ped, vehicle) then
                    --print("TESTING VEHICLE", i, "PED", _, "** PASSED **, detaching ped from Vehicle!")
                    PlayerDetachFromVehicle()
                    bDelete = true
                end
            end
            if bDelete then
                --print("DELETING VEHICLE", i)
                VehicleDelete(vehicle)
            end
        end
    end
end
