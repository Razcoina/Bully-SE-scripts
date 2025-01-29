local GARAGE_OPEN_RADIUS = 15
local clint
local bMissionFailed = false
local tblPathBikers = {}
local numBikes = 0
local maxBikes = 3
local currentBike, currentObjective, currentBlip
local bFacePlayer = true
local strFailReason
local bClintSpeechRunning = false
local bCheckGarageRunning = false

function MissionSetup()
    DATLoad("3_R07.DAT", 2)
    PedSetUniqueModelStatus(45, -1)
    PedSetUniqueModelStatus(46, -1)
    PedSetUniqueModelStatus(42, -1)
    MissionDontFadeIn()
    PlayCutsceneWithLoad("3-R07", true)
end

function main()
    CameraFade(0, 0)
    PlayerSetControl(0)
    AreaTransitionPoint(0, POINTLIST._5_T1_PLAYERSTART, 1, false)
    while not RequestModel(45) do
        Wait(0)
    end
    PedSetTypeToTypeAttitude(3, 13, 2)
    F_StartMission()
    F_StartGetBike()
    SoundPlayScriptedSpeechEvent(clint, "M_3_R07", 12, "large")
    F_StartGetBike()
    SoundPlayScriptedSpeechEvent(clint, "M_3_R07", 12, "large")
    F_StartGetBike()
    F_MissionFinished()
end

function F_StartMission()
    F_SetupAmbientVehicles()
    F_SetupMissionBikes()
    clint = PedCreatePoint(45, POINTLIST._5_T1_CLINTSTART)
    PedIgnoreStimuli(clint, true)
    PedSetAsleep(clint, true)
    PedSetPosPoint(clint, POINTLIST._5_T1_CLINTSTART, 1)
    F_SetupClintSocialize()
    CreateThread("F_ClintFacePlayer")
    CreateThread("F_MissionFail")
    CreateThread("F_CheckGarage")
    PlayerSetControl(0)
    PlayerFaceHeadingNow(160)
    PedSetPosPoint(gPlayer, POINTLIST._5_T1_PLAYERSTART, 1)
    CameraSetWidescreen(false)
    CameraReset()
    CameraReturnToPlayer()
    Wait(500)
    CameraFade(1000, 1)
    Wait(1000)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    ShowBikeCounter(true)
end

function F_CheckGarage()
    bCheckGarageRunning = true
    local bGarageDoorOpen = false
    while bCheckGarageRunning == true do
        Wait(0)
        local garageIndex, garagePool = PAnimGetPoolIndex("SBikeGar", 302.107, -421.098, 2.92139, 1)
        local x1, y1, z1 = PedGetPosXYZ(gPlayer)
        local x2, y2, z2 = GetPointList(POINTLIST._5_T1_BIKEDROP)
        if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) < GARAGE_OPEN_RADIUS and bGarageDoorOpen == false then
            PAnimSetActionNode("SBikeGar", 302.107, -421.098, 2.92139, 5, "/Global/Door/DoorFunctions/Opening/BIKEGAR", "Act/Props/Door.act")
            bGarageDoorOpen = true
        elseif DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > GARAGE_OPEN_RADIUS and bGarageDoorOpen == true then
            PAnimSetActionNode("SBikeGar", 302.107, -421.098, 2.92139, 5, "/Global/Door/DoorFunctions/Closing/BIKEGAR", "Act/Props/Door.act")
            bGarageDoorOpen = false
        end
    end
end

function F_SetupAmbientVehicles()
    VehicleBikeGeneratorToggle(false)
    AreaClearAllVehicles()
    VehicleOverrideAmbient(3, 2, 0, 1)
    local x, y, z = PlayerGetPosXYZ()
    tblBikes = VehicleFindInAreaXYZ(x, y, z, 200, false)
    if not tblBikes then
        return
    end
    for i, bike in tblBikes do
        VehicleDelete(bike)
    end
end

function F_SetupMissionBikes()
    tblPathBikers = {
        {
            pedModel = 44,
            bikeModel = 274,
            ped = nil,
            bike = nil,
            blip = nil,
            pedPoint = POINTLIST._5_T1_PATHPEDSTART01,
            path = PATH._5_T1_BIKEPATH01,
            retrieved = false,
            pedOffBike = false
        },
        {
            pedModel = 43,
            bikeModel = 279,
            ped = nil,
            bike = nil,
            blip = nil,
            pedPoint = POINTLIST._5_T1_PATHPEDSTART02,
            path = PATH._5_T1_BIKEPATH02,
            retrieved = false,
            pedOffBike = false
        },
        {
            pedModel = 123,
            bikeModel = 282,
            ped = nil,
            bike = nil,
            blip = nil,
            pedPoint = POINTLIST._5_T1_PATHPEDSTART03,
            path = PATH._5_T1_BIKEPATH03,
            retrieved = false,
            pedOffBike = false
        },
        {
            pedModel = 222,
            bikeModel = 280,
            ped = nil,
            bike = nil,
            blip = nil,
            pedPoint = POINTLIST._5_T1_PATHPEDSTART04,
            path = PATH._5_T1_BIKEPATH04,
            retrieved = false,
            pedOffBike = false
        },
        {
            pedModel = 128,
            bikeModel = 283,
            ped = nil,
            bike = nil,
            blip = nil,
            pedPoint = POINTLIST._5_T1_PATHPEDSTART05,
            path = PATH._5_T1_BIKEPATH05,
            retrieved = false,
            pedOffBike = false
        }
    }
    for i, item in tblPathBikers do
        item.ped = PedCreatePoint(item.pedModel, item.pedPoint)
        item.bike = VehicleCreatePoint(item.bikeModel, item.pedPoint)
        PedPutOnBike(item.ped, item.bike)
        PedFollowPath(item.ped, item.path, 1, 0)
    end
end

function F_ResetMissionBikes()
    for i, item in tblPathBikers do
        if item.retrieved == false then
            if PedIsValid(item.ped) then
                PedDelete(item.ped)
            end
            if VehicleIsValid(item.bike) then
                VehicleDelete(item.bike)
            end
            item.ped = PedCreatePoint(item.pedModel, item.pedPoint)
            item.bike = VehicleCreatePoint(274, item.pedPoint)
            PedPutOnBike(item.ped, item.bike)
            PedFollowPath(item.ped, item.path, 1, 0)
        elseif PedIsValid(item.ped) then
            PedDelete(item.ped)
        end
    end
end

function F_ClintHit()
    if clint and PedIsValid(clint) then
        PedSetInvulnerable(clint, false)
        PedSetFlag(clint, 113, false)
        PedSetStationary(clint, false)
        PedIgnoreStimuli(clint, false)
        PedMakeAmbient(clint)
    end
    bMissionFailed = true
    bFacePlayer = false
    strFailReason = "5_T1_FAIL_01"
end

function F_SetupClintSocialize()
    PedSetMissionCritical(clint, true, F_ClintHit, true)
    PedSetEmotionTowardsPed(clint, gPlayer, 8)
    PedOverrideSocialResponseToStimulus(clint, 28, 4)
    PlayerSocialDisableActionAgainstPed(clint, 28, true)
    PlayerSocialDisableActionAgainstPed(clint, 29, true)
    PedUseSocialOverride(clint, 4)
end

function F_ClintFacePlayer()
    while bFacePlayer == true do
        Wait(0)
        PedFaceObject(clint, gPlayer, 3, 1)
        Wait(3000)
    end
end

local bFirstTimeSecondBike = false

function F_StartGetBike()
    currentObjective = MissionObjectiveAdd("5_T1_OBJ01")
    if 1 <= numBikes then
        TextPrint("5_T1_OBJ03", 4, 1)
    else
        TextPrint("5_T1_OBJ01", 4, 1)
    end
    for i, item in tblPathBikers do
        if item.retrieved == false and VehicleIsValid(item.bike) then
            BlipRemove(item.blip)
            item.blip = AddBlipForCar(item.bike, 0, 4)
        end
    end
    while F_CheckOnBike() == false and bMissionFailed == false do
        Wait(0)
        if DistanceBetweenPeds3D(clint, gPlayer) < 3 and bClintSpeechRunning == false then
            CreateThread("F_ClintNoBikeSpeech")
            bClintSpeechRunning = true
        end
        F_CheckPathBiker()
    end
    if VehicleIsValid(currentBike) then
        VehicleSetOwner(currentBike, gPlayer)
    end
    MissionObjectiveRemove(currentObjective)
    F_GetBackToClint()
end

function F_CheckOnBike()
    for i, item in tblPathBikers do
        if item.retrieved == false and VehicleIsValid(item.bike) and PedIsInVehicle(gPlayer, item.bike) == true then
            currentBike = PlayerGetBikeId()
            return true
        end
    end
    return false
end

function F_CheckPathBiker()
    for i, item in tblPathBikers do
        if PedIsValid(item.ped) == true and VehicleIsValid(item.bike) == true and PedIsInVehicle(item.ped, item.bike) == false and item.pedOffBike == false then
            --print("[ScottieP] --> Setting ped to attack!")
            PedStop(item.ped)
            PedClearObjectives(item.ped)
            PedSetPedToTypeAttitude(item.ped, 13, 0)
            PedAttack(item.ped, gPlayer, 3)
            PedMakeAmbient(item.ped)
            item.pedOffBike = true
        end
    end
end

function F_ClintNoBikeSpeech()
    SoundPlayScriptedSpeechEvent(clint, "M_3_R07", 11, "large")
    Wait(6000)
    bClintSpeechRunning = false
end

function F_GetBackToClint()
    for i, item in tblPathBikers do
        BlipRemove(item.blip)
    end
    currentObjective = MissionObjectiveAdd("5_T1_OBJ02")
    TextPrint("5_T1_OBJ02", 4, 1)
    local x, y, z = GetPointList(POINTLIST._5_T1_BIKEDROP)
    currentBlip = BlipAddXYZ(x, y, z, 0, 1, 7)
    while PlayerIsInTrigger(TRIGGER._5_T1_BIKEGARAGE) == false and bMissionFailed == false do
        Wait(0)
        if DistanceBetweenPeds3D(clint, gPlayer) < 10 and bClintSpeechRunning == false then
            CreateThread("F_ClintGotBikeSpeech")
            bClintSpeechRunning = true
        end
        if PlayerIsInAnyVehicle() == false then
            MissionObjectiveRemove(currentObjective)
            BlipRemove(currentBlip)
            F_StartGetBike()
            return
        end
    end
    if bMissionFailed == false then
        MissionObjectiveComplete(currentObjective)
        BlipRemove(currentBlip)
        F_GotBikeToClint()
    end
end

function F_ClintGotBikeSpeech()
    SoundPlayScriptedSpeechEvent(clint, "M_3_R07", 10, "large")
    Wait(6000)
    bClintSpeechRunning = false
end

function F_GotBikeToClint()
    numBikes = numBikes + 1
    CounterSetCurrent(numBikes)
    PlayerSetPunishmentPoints(0)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    PlayerSetInvulnerable(true)
    F_PlayerDismountBike()
    F_MakePlayerSafeForNIS(true)
    while PedIsInAnyVehicle(gPlayer) == true do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(600)
    for i, item in tblPathBikers do
        if item.bike == currentBike then
            item.retrieved = true
        end
    end
    F_ResetMissionBikes()
    PlayerSetPosPoint(POINTLIST._5_T1_PLAYERDROP)
    local modelId = VehicleGetModelId(currentBike)
    VehicleDelete(currentBike)
    currentBike = VehicleCreatePoint(modelId, POINTLIST._5_T1_BIKEDROP)
    CameraSetXYZ(296.0974, -427.41077, 5.95378, 296.9142, -426.89893, 5.687579)
    Wait(100)
    CameraFade(500, 1)
    Wait(100)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedMoveToPoint(gPlayer, 0, POINTLIST._5_T1_PLAYERSTART)
    bCheckGarageRunning = false
    PAnimSetActionNode("SBikeGar", 302.107, -421.098, 2.92139, 5, "/Global/Door/DoorFunctions/Closing/BIKEGAR", "Act/Props/Door.act")
    bGarageDoorOpen = false
    Wait(2000)
    if VehicleIsValid(currentBike) then
        VehicleDelete(currentBike)
    end
    CameraReset()
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    if numBikes == 3 then
        PedStop(clint)
        PedClearObjectives(clint)
        PedMakeAmbient(clint)
        SoundPlayScriptedSpeechEvent(clint, "M_3_R07", 12, "large")
        ShowBikeCounter(false)
        Wait(1000)
        MinigameSetCompletion("M_PASS", true, 5000)
        SoundPlayMissionEndMusic(true, 10)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        MissionSucceed(true, false, false)
    else
        Wait(1000)
        bCheckGarageRunning = true
        CreateThread("F_CheckGarage")
    end
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
end

function ShowBikeCounter(bOn)
    if bOn then
        CounterSetCurrent(0)
        CounterSetMax(maxBikes)
        CounterMakeHUDVisible(true)
    else
        CounterMakeHUDVisible(false)
        CounterSetMax(0)
        CounterSetCurrent(0)
        CounterClearIcon()
    end
end

function F_MissionFinished()
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    PlayerSetInvulnerable(true)
    F_PlayerDismountBike()
    F_MakePlayerSafeForNIS(true)
end

function F_MissionFail()
    while bMissionFailed == false do
        Wait(0)
    end
    SoundPlayMissionEndMusic(false, 6)
    if strFailReason then
        MissionFail(false, true, strFailReason)
    else
        MissionFail(false)
    end
end

function MissionCleanup()
    --print("[SCOTTIE P] -> Mission Cleanup called")
    SoundStopInteractiveStream()
    if PedIsValid(clint) then
        PedDelete(clint)
    end
    if PedIsValid(gurney) then
        PedDelete(gurney)
    end
    if PedIsValid(otto) then
        PedDelete(otto)
    end
    for i, item in tblPathBikers do
        if PedIsValid(item.ped) then
            PedDelete(item.ped)
        end
        if VehicleIsValid(item.bike) then
            VehicleDelete(item.bike)
        end
    end
    PedSetUniqueModelStatus(45, 0)
    PedSetUniqueModelStatus(46, 0)
    PedSetUniqueModelStatus(42, 0)
    DATUnload(2)
    if bMissionFailed == true then
        PlayerSetControl(1)
        ShowBikeCounter(false)
    end
    AreaRevertToDefaultPopulation()
    VehicleBikeGeneratorToggle(true)
    F_MakePlayerSafeForNIS(false)
    CameraSetWidescreen(false)
end
