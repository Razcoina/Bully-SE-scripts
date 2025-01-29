--[[ Changes to this file
    * Added local variable L75_1
    * Modified function T_Photography, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibHud.lua")
ImportScript("Library/LibPhotography.lua")
local tblPedModels = {
    81,
    131,
    80
}
local tblVehicleModels = { 295 }
local tblWeaponModels = { 321 }
local IntroductionEnded = false
local NearDropout = false
local AtDropOut = false
local DropoutConvOver = false
local bGreaserFleeing = false
local BikeReturned = false
local IsThereMeat = false
local GotBike = false
local GotPaint = false
local GotMeat = false
local Spotted = false
local DogBribed = false
local CityHallTagged = false
local CityHallPhoto = false
local BackAtDorm = false
local bBBQHint01 = false
local bBBQHint02 = false
local bBBQHint03 = false
local CityHallCutOver = false
local bThugsOnTheMove = false
local bAmbushCreate = false
local bGreasersLoaded = false
local bDogAsleep = true
local bStanding = false
local bTagADone = false
local bTagBDone = false
local bTagCDone = false
local obj01 = 0
local obj02 = 0
local obj03 = 0
local obj04 = 0
local obj05 = 0
local obj06 = 0
local obj07 = 0
local obj08 = 0
local obj09 = 0
local objGetSpray, objTagCityHall, objTakePhoto
local DropX, DropY, DropZ = 0, 0, 0
local tempX, tempY, tempZ = 0, 0, 0
local tagIndex, tagObject = 0, 0
local Earnest = {}
local tblGawkers = {}
local Transport = {}
local DropoutContact = {}
local DropoutBike = {}
local GreaserThief = {}
local BBQMeat = {}
local Dog = {}
local Paint = {}
local DropoutThug01 = {}
local DropoutThug02 = {}
local CityHallCop01 = {}
local CityHallCop02 = {}
local PatrolCar = {}
local TagArea = {}
local bTagADone = false
local bTagBDone = false
local bTagCDone = false
local bTagsDone = false
local bMissionComplete = false
local objGetSpray = false
local gCurrentBlip, gCurrentObjective, gCurrentBlipPoint, gCurrentObjectiveText
local L75_1 = false -- Added this
local idPeter

function F_TableInit()
    Earnest = {
        model = 10,
        point = POINTLIST._5_09_EARNEST
    }
    Transport = {
        model = 281,
        point = POINTLIST._5_09_TRANSPORT,
        model2 = 279
    }
    DropoutContact = {
        model = 45,
        point = POINTLIST._5_09_DROPOUT_CONTACT
    }
    DropoutBike = {
        model = 280,
        point = POINTLIST._5_09_DROPOUT_BIKE
    }
    GreaserThief = {
        model = 24,
        point = POINTLIST._5_09_GREASER_THIEF,
        path = PATH._5_09_GREASER_THIEF,
        id = 0,
        model1 = 28,
        model2 = 26,
        model3 = 29,
        model4 = 22
    }
    Dog = {
        model = 141,
        point = POINTLIST._5_06_FIRST_GUARD_DOG,
        path = PATH._5_09_FIRST_GUARD_DOG
    }
    Paint = {
        model = MODELENUM._CAN,
        point = POINTLIST._5_09_PAINT
    }
    DropoutThug01 = {
        model = 43,
        point = POINTLIST._5_09_DROPOUT_THUG_01
    }
    DropoutThug02 = {
        model = 46,
        point = POINTLIST._5_09_DROPOUT_THUG_02
    }
    TagArea = {
        point = POINTLIST._CITYHALLTAGBLIP
    }
    PhotoArea = {
        point = POINTLIST._5_09_CITYHALL_PHOTOOP
    }
    PlayersRoom = {
        point = POINTLIST._5_09_PLAYERS_ROOM
    }
    DropX, DropY, DropZ = GetPointList(DropoutContact.point)
    tblGawkers = {
        { model = 81,  id = 0 },
        { model = 135, id = 0 },
        { model = 131, id = 0 },
        { model = 78,  id = 0 },
        { model = 80,  id = 0 }
    }
end

function F_LeaveDorm()
    DropoutContact.blip = BlipAddPoint(DropoutContact.point, 0)
    TextPrint("5_09_OT_01", 4, 1)
    obj01 = MissionObjectiveAdd("5_09_OT_01")
    while 14 == AreaGetVisible() do
        Wait(0)
    end
    F_CreateTransport()
end

function F_CityHallTagsInit()
    --print(">>>[RUI]", "!!F_GetToCityHall setup the big Tag")
    TaggingStartPersistentTag()
    while not PAnimRequest(TRIGGER._5_09_CITYHALL_TAG) do
        Wait(0)
    end
    PAnimCreate(TRIGGER._5_09_CITYHALL_TAG)
end

function F_CityHallTagsLock()
    --print(">>>[RUI]", "!!F_GetToCityHall setup the big Tag")
    TaggingStartPersistentTag()
end

function F_GetToCityHall()
    gCurrentBlip = BlipAddPoint(POINTLIST._5_09_CITYHALL_GROUNDS, 0)
    gCurrentBlipPoint = POINTLIST._5_09_CITYHALL_GROUNDS
    if not PlayerHasItem(321) then
        Wait(5000)
    end
    gCurrentObjective = MissionObjectiveAdd("5_09_OGETHALL")
    gCurrentObjectiveText = "5_09_OGETHALL"
    CreateThread("T_GetSpray")
    TextPrint("5_09_OGETHALL", 4, 1)
    while not PlayerIsInTrigger(TRIGGER._5_09_CITYHALL_GROUNDS) or objGetSpray do
        Wait(0)
    end
    MissionObjectiveComplete(gCurrentObjective)
    gCurrentObjective = MissionObjectiveAdd("5_09_OT_07")
    gCurrentObjectiveText = "5_09_OT_07"
    TextPrint("5_09_OT_07", 4, 1)
    BlipRemove(gCurrentBlip)
    gCurrentBlip = BlipAddPoint(POINTLIST._5_09_LADDER_CITYHALL_CHEAT, 0, 1, 1, 1)
    gCurrentBlipPoint = POINTLIST._5_09_LADDER_CITYHALL_CHEAT
    while not (PlayerIsInTrigger(TRIGGER._5_09_CITYHALL_BUILDING) and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true)) do
        Wait(0)
    end
    BlipRemove(gCurrentBlip)
    gCurrentBlip = BlipAddPoint(POINTLIST._5_09_CITYHALL_TAG, 0)
    gCurrentBlipPoint = POINTLIST._5_09_CITYHALL_TAG
    while not PlayerIsInTrigger(TRIGGER._5_09_CITYHALL_TOWER) do
        Wait(0)
    end
    F_CityHallTagsInit()
    while not PlayerIsInTrigger(TRIGGER._5_09_CITYHALLTAG2) do
        Wait(0)
    end
    MissionObjectiveComplete(gCurrentObjective)
    gCurrentObjective = MissionObjectiveAdd("5_09_OTAGCITY")
    gCurrentObjectiveText = "5_09_OTAGCITY"
    TextPrint("5_09_OTAGCITY", 4, 1)
    tempX, tempY, tempZ = GetPointList(POINTLIST._5_09_CITYHALL_SQUARE)
    while not PlayerIsInAreaXYZ(tempX, tempY, tempZ, 150, 0) do
        Wait(0)
    end
    if PlayerHasItem(426) then
        --print("PLAYER HAS DIGICAM")
        WeaponSetRangeMultiplier(gPlayer, 426, 4)
    else
        --print("PLAYER NOT HAS DIGICAM")
        WeaponSetRangeMultiplier(gPlayer, 328, 4)
    end
end

function F_Tag1Ready()
    if not bTagADone then
        --print(">>>[RUI]", "F_Tag1Ready")
        return 1
    else
        --print(">>>[RUI]", "F_Tag1Ready FALSE")
        return 0
    end
end

function F_Tag2Ready()
    if bTagADone then
        --print(">>>[RUI]", "F_Tag2Ready")
        return 1
    else
        --print(">>>[RUI]", "F_Tag2Ready FALSE")
        return 0
    end
end

function F_Tag3Ready()
    if bTagADone and bTagBDone then
        --print(">>>[RUI]", "F_Tag3Ready")
        return 1
    else
        --print(">>>[RUI]", "F_Tag3Ready FALSE")
        return 0
    end
end

function cbTagDone(tag)
    --print(">>>[RUI]", "cbTagDone " .. tostring(tag))
    if tag == TRIGGER._5_09_CITYHALL_TAG then
        bTagADone = true
        PAnimSetActionNode(TRIGGER._5_09_CITYHALL_TAG, "/Global/CityHallTag/BigTag/NotUseable/Tagged/Bull")
        PAnimCreate(TRIGGER._5_09_CITYHALLTAG2)
    elseif tag == TRIGGER._5_09_CITYHALLTAG2 then
        bTagBDone = true
        PAnimSetActionNode(TRIGGER._5_09_CITYHALL_TAG2, "/Global/CityHallTag/BigTag/NotUseable/Tagged/Worth")
        PAnimCreate(TRIGGER._5_09_CITYHALLTAG3)
    elseif tag == TRIGGER._5_09_CITYHALLTAG3 then
        PAnimSetActionNode(TRIGGER._5_09_CITYHALL_TAG3, "/Global/CityHallTag/BigTag/NotUseable/Tagged/Less")
        bTagCDone = true
    end
    if bTagADone and bTagBDone and bTagCDone then
        --print(">>>[RUI]", "cbTagDone All tags DONE")
        bTagsDone = true
    end
end

function F_TagCityHall()
    while not CityHallTagged do
        if bTagsDone then
            CityHallTagged = true
            break
        end
        Wait(0)
    end
    PlayerSetControl(0)
    if gCurrentObjective then
        MissionObjectiveComplete(gCurrentObjective)
    end
    PlayerSetPunishmentPoints(200)
    F_CreateGawkers()
    CreateThread("T_HACKPUNISHMENTLEVEL")
    BlipRemove(gCurrentBlip)
    TextPrint("5_09_OC_03", 4, 1)
    Wait(4000)
    MissionObjectiveComplete(obj07)
    TextPrint("5_09_OT_09", 4, 1)
    objTakePhoto = MissionObjectiveAdd("5_09_OT_09")
    TaggingStopPersistentTag()
    --print(">>>[ F_TagCityHall ]<<<", tagIndex, tagObject)
end

function IsTagValid()
    return true
end

function F_PhotoCityHall()
    local blipPhoto = BlipAddPoint(POINTLIST._5_09_PHOTOPOINT, 0)
    while not PlayerIsInTrigger(TRIGGER._5_09_CITYHALL_WALL_CLIMBED) do
        Wait(0)
    end
    tagIndex, tagObject = CreatePersistentEntity("DL_BU1d_bWless", 650.224, -90.3781, 34.5168, 0, 0)
    PAnimDelete(TRIGGER._5_09_CITYHALL_TAG)
    PAnimDelete(TRIGGER._5_09_CITYHALLTAG2)
    PAnimDelete(TRIGGER._5_09_CITYHALLTAG3)
    F_GivePlayerCamera()
    if PlayerHasItem(426) then
        --print("PLAYER HAS DIGICAM")
        WeaponSetRangeMultiplier(gPlayer, 426, 4)
    else
        --print("PLAYER NOT HAS DIGICAM")
        WeaponSetRangeMultiplier(gPlayer, 328, 4)
    end
    CreateThread("T_Photography")
    tempX, tempY, tempZ = GetPointFromPointList(PhotoArea.point, 1)
    while not CityHallPhoto do
        Wait(0)
    end
    BlipRemove(blipPhoto)
    L_StopMonitoringTargets()
    MissionObjectiveComplete(objTakePhoto)
end

function T_Photography() -- ! Modified
    local gPhotoTargets = {}
    x1, y1, z1 = GetPointFromPointList(POINTLIST._5_09_CITYHALL_TAG, 1)
    x2, y2, z2 = GetPointFromPointList(POINTLIST._5_09_CITYHALL_TAG, 2)
    x3, y3, z3 = GetPointFromPointList(POINTLIST._5_09_CITYHALL_TAG, 3)
    x4, y4, z4 = GetPointFromPointList(POINTLIST._5_09_CITYHALL_TAG, 4)
    table.insert(gPhotoTargets, {
        x = x1,
        y = y1,
        z = z1
    })
    table.insert(gPhotoTargets, {
        x = x2,
        y = y2,
        z = z2
    })
    table.insert(gPhotoTargets, {
        x = x3,
        y = y3,
        z = z3
    })
    table.insert(gPhotoTargets, {
        x = x4,
        y = y4,
        z = z4
    })
    local photohasbeentaken, wasValid
    local validCount = 0
    while not CityHallPhoto do
        Wait(0)
        validTarget = false
        validCount = 0
        for i, target in gPhotoTargets do
            if not target.taken and PhotoTargetInFrame(target.x, target.y, target.z) then
                gPhotoTargets[i].valid = true
                validCount = validCount + 1
            end
        end
        --print(validCount)
        if validCount == 4 then
            validTarget = true
        end
        joshLazyHack = validTarget or L75_1 -- Added this
        L75_1 = validTarget           -- Added this
        PhotoSetValid(validTarget)
        photohasbeentaken, wasValid = PhotoHasBeenTaken()
        --[[
        if photohasbeentaken and wasValid and validTarget and not PlayerIsInTrigger(TRIGGER._5_09_CITYHALL_BUILDING) then
        ]] -- Changed this to:
        if photohasbeentaken and wasValid and joshLazyHack and not PlayerIsInTrigger(TRIGGER._5_09_CITYHALL_BUILDING) then
            CityHallPhoto = true
        end
        for i, target in gPhotoTargets do
            if target.valid == true and not target.taken then
                target.valid = false
            end
        end
    end
end

function T_GetSpray()
    objGetSpray = nil
    local blipGetSpray
    while not CityHallTagged do
        if not PlayerHasItem(321) then
            if PlayerGetMoney() < 100 and not shared.playerShopping then
                Wait(2000)
                if not CityHallTagged then
                    SoundPlayMissionEndMusic(false, 10)
                    MissionFail(false, true, "5_09_FAILSPRAY")
                    break
                end
                break
            end
            if not objGetSpray then
                objGetSpray = MissionObjectiveAdd("5_09_OSPRAY")
                blipGetSpray = BlipAddPoint(POINTLIST._5_09_GETSPRAY, 0)
                TextPrint("5_09_OSPRAY", 4, 1)
                if gCurrentObjective then
                    MissionObjectiveRemove(gCurrentObjective)
                end
                BlipRemove(gCurrentBlip)
                gCurrentObjective = nil
            end
        elseif objGetSpray then
            MissionObjectiveRemove(objGetSpray)
            BlipRemove(blipGetSpray)
            gCurrentObjective = MissionObjectiveAdd(gCurrentObjectiveText)
            if gCurrentBlipPoint == POINTLIST._5_09_LADDER_CITYHALL_CHEAT then
                gCurrentBlip = BlipAddPoint(gCurrentBlipPoint, 0, 1, 1, 1)
            else
                gCurrentBlip = BlipAddPoint(gCurrentBlipPoint, 0)
            end
            while AreaGetVisible() == 26 do
                Wait(0)
            end
            TextPrint(gCurrentObjectiveText, 4, 1)
            objGetSpray = nil
        end
        Wait(0)
    end
    if objGetSpray then
        MissionObjectiveRemove(objGetSpray)
    end
    BlipRemove(blipGetSpray)
end

function F_PictureTaken(tblTargets)
    for i, tblEntry in tblTargets do
        tempX, tempY, tempZ = GetPointList(POINTLIST._5_09_CITYHALL_TAG)
        if tblEntry.x == tempX and tblEntry.y == tempY and tblEntry.z == tempZ and CityHallTagged then
            L_SetTargetValid(tblEntry, false)
            CityHallPhoto = true
            return true
        end
    end
    return false
end

function F_GetBackToDorm()
    local x, y, z = GetPointList(POINTLIST._5_09_PETEY)
    PlayersRoom.blip = BlipAddPoint(POINTLIST._5_09_PLAYERS_ROOM, 0)
    local objective = MissionObjectiveAdd("5_09_ORETURN")
    TextPrint("5_09_ORETURN", 4, 1)
    while not PedRequestModel(134) do
        Wait(0)
    end
    idPeter = PedCreatePoint(134, POINTLIST._5_09_PETEY)
    PedIgnoreStimuli(idPeter, true)
    PedIgnoreAttacks(idPeter, true)
    PedSetMinHealth(idPeter, 0.5)
    while not (BackAtDorm or PedIsHit(idPeter, 2, 1000)) do
        DropX, DropY, DropZ = GetPointFromPointList(POINTLIST._5_09_PLAYERS_ROOM, 1)
        PlayerIsInAreaXYZ(DropX, DropY, DropZ, 1, 1)
        if PlayerIsInTrigger(TRIGGER._5_09_PLAYERS_ROOM) then
            BackAtDorm = true
        end
        if not PedIsPlaying(idPeter, "/Global/5_09/Anims/PeteSit", false) then
            PedSetActionNode(idPeter, "/Global/5_09/Anims/PeteSit", "Act/Conv/5_09.act")
        end
        if not PedIsInAreaXYZ(idPeter, x, y, z, 0.3, 0) then
            PedSetPosPoint(idPeter, POINTLIST._5_09_PETEY, 1)
        end
        Wait(0)
    end
    PlayerSetControl(0)
    MissionObjectiveComplete(objective)
    BlipRemove(PlayersRoom.blip)
end

function F_CreateTransport()
    Transport.id1 = VehicleCreatePoint(Transport.model, Transport.point, 1)
    Transport.id2 = VehicleCreatePoint(Transport.model2, Transport.point, 2)
end

function F_CreatePaint()
    Paint.id = PickupCreatePoint(Paint.model, Paint.point, 0, 0, "PermanentMission")
end

function F_CreateCutPaint()
    Paint.blip = BlipAddPoint(Paint.point, 0)
end

function F_RemoveCutPaint()
    BlipRemove(Paint.blip)
end

function F_GivePlayerCamera()
end

function F_CreateMeat()
    BBQMeat.id01 = PickupCreatePoint(BBQMeat.model, BBQMeat.point, 1, 0, "PermanentMission")
    BBQMeat.id02 = PickupCreatePoint(BBQMeat.model, BBQMeat.point, 2, 0, "PermanentMission")
end

function F_CreateGuardDog()
    Dog.id = PedCreatePoint(Dog.model, Dog.point)
    PedSetIsStealthMissionPed(Dog.id, true)
    PedSetPedToTypeAttitude(Dog.id, 13, 0)
    PedOverrideStat(Dog.id, 14, 100)
    PedOverrideStat(Dog.id, 6, 0)
    PedOverrideStat(Dog.id, 7, 0)
    PedSetActionNode(Dog.id, "/Global/5_09/Dog/Sleep", "Act/Conv/5_09.act")
end

function F_CreateGreaserThief()
    GreaserThief.id = PedCreatePoint(GreaserThief.model, GreaserThief.point)
    PedFollowPath(GreaserThief.id, GreaserThief.path, 0, 1, cbGreaserThief)
end

function F_CreateGreaserThugs()
    GreaserThief.id1 = PedCreatePoint(GreaserThief.model1, GreaserThief.point, 2)
    GreaserThief.id2 = PedCreatePoint(GreaserThief.model2, GreaserThief.point, 3)
    GreaserThief.id3 = PedCreatePoint(GreaserThief.model3, GreaserThief.point, 4)
    GreaserThief.id4 = PedCreatePoint(GreaserThief.model4, GreaserThief.point, 5)
    PedSetAsleep(GreaserThief.id1, true)
    PedSetAsleep(GreaserThief.id2, true)
    PedSetAsleep(GreaserThief.id3, true)
    PedSetAsleep(GreaserThief.id4, true)
end

function F_WhenGreasersAttack()
    PedSetAsleep(GreaserThief.id1, false)
    PedSetAsleep(GreaserThief.id2, false)
    PedSetAsleep(GreaserThief.id3, false)
    PedSetAsleep(GreaserThief.id4, false)
    PedAttackPlayer(GreaserThief.id, 3)
    PedAttackPlayer(GreaserThief.id1, 3)
    PedAttackPlayer(GreaserThief.id2, 3)
    PedAttackPlayer(GreaserThief.id3, 3)
    PedAttackPlayer(GreaserThief.id4, 3)
end

function F_MakeGreasersAmbient()
    if PedIsValid(GreaserThief.id1) and not PedIsDead(GreaserThief.id1) then
        PedClearObjectives(GreaserThief.id1)
        PedMakeAmbient(GreaserThief.id1)
    end
    if PedIsValid(GreaserThief.id2) and not PedIsDead(GreaserThief.id2) then
        PedClearObjectives(GreaserThief.id2)
        PedMakeAmbient(GreaserThief.id2)
    end
    if PedIsValid(GreaserThief.id3) and not PedIsDead(GreaserThief.id3) then
        PedClearObjectives(GreaserThief.id3)
        PedMakeAmbient(GreaserThief.id3)
    end
    if PedIsValid(GreaserThief.id4) and not PedIsDead(GreaserThief.id4) then
        PedClearObjectives(GreaserThief.id4)
        PedMakeAmbient(GreaserThief.id4)
    end
end

function F_CreateCops()
    PatrolCar.id = VehicleCreatePoint(295, PatrolCar.point, 2)
    VehicleEnableSiren(PatrolCar.id, true)
    PatrolCar.id2 = VehicleCreatePoint(295, PatrolCar.point, 3)
    VehicleEnableSiren(PatrolCar.id2, true)
end

function F_LoadGawkerModels()
    for i, gawker in tblGawkers do
        while not PedRequestModel(gawker.model) do
            Wait(0)
        end
    end
end

function F_CreateGawkers()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaClearAllVehicles()
    AreaClearAllPeds()
    F_LoadGawkerModels()
    while not VehicleRequestModel(295) do
        Wait(0)
    end
    while not PedRequestModel(83) do
        Wait(0)
    end
    idCop = PedCreatePoint(83, POINTLIST._5_09_COPCAR, 2)
    idCopCar = VehicleCreatePoint(295, POINTLIST._5_09_COPCAR)
    VehicleFollowPath(idCopCar, PATH._5_09_COPCARNISPATH, false, false)
    VehicleEnableSiren(idCopCar, true)
    VehicleSirenAllwaysOn(idCopCar, true)
    PedWarpIntoCar(idCop, idCopCar)
    for i, gawker in tblGawkers do
        gawker.id = PedCreatePoint(gawker.model, POINTLIST._5_09_GAWKERS, i)
        PedSetActionNode(gawker.id, "/Global/5_09/5_09_Cityhall_Cut", "Act/Conv/5_09.act")
    end
    F_Cinematic(true)
    SoundPlayAmbience("MS_5-09_CrowdNIS.rsm", 1)
    SoundSetAudioFocusCamera()
    CameraSetSpeed(12, 12, 12)
    CameraLookAtPathSetSpeed(15, 15, 15)
    CameraLookAtPath(PATH._5_09_AFTERTAGLOOK, true)
    CameraSetPath(PATH._5_09_AFTERTAGCAM, true)
    Wait(8000)
    SoundSetAudioFocusPlayer()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    SoundFadeoutAmbience(500)
    CameraFade(500, 0)
    Wait(505)
    CameraSetSpeed(20, 20, 20)
    CameraLookAtPathSetSpeed(20, 20, 20)
    CameraSetPath(PATH._5_09_TowerCam, true)
    CameraLookAtPath(PATH._5_09_TowerCamLook, true)
    CameraFade(500, 1)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
end

function T_GawkerSpeech()
    while not CityHallPhoto do
        Wait(0)
        local choice = tblGawkers[math.random(1, table.getn(tblGawkers))].id
        --print("T_GawkerSpeech Choice: ", tostring(choice))
        if PedIsValid(choice) then
            SoundPlayScriptedSpeechEvent(choice, "SEE_SOMETHING_CRAP", 0, "medium", false)
            Wait(5000)
        end
    end
end

function F_Cinematic(bStart)
    if bStart then
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(505)
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        F_MakePlayerSafeForNIS(true)
        CameraFade(500, 1)
    elseif not bStart then
        MusicFadeWithCamera(false)
        CameraFade(500, 0)
        Wait(505)
        CameraReturnToPlayer()
        CameraFade(500, 1)
        PlayerSetControl(1)
        CameraSetWidescreen(false)
        F_MakePlayerSafeForNIS(false)
    end
end

function cbGreaserThief(pedId, pathId, pathNode)
    if pathNode == 4 then
        PedEnterVehicle(pedId, DropoutBike.id)
    end
end

function cbGreaserFlee(pedId, pathId, pathNode)
end

function cbDog(pedId, pathId, pathNode)
end

function cbCityHallCop01(pedId, pathId, pathNode)
end

function cbCityHallCop02(pedId, pathId, pathNode)
end

function cbPatrolCar(pedId, pathId, pathNode)
end

function cbCheckTag()
end

function F_ModelRequest()
    PedRequestModel(GreaserThief.model)
    PedRequestModel(GreaserThief.model1)
    PedRequestModel(GreaserThief.model2)
    PedRequestModel(GreaserThief.model3)
    PedRequestModel(GreaserThief.model4)
end

function MissionSetup()
    SoundPlayInteractiveStream("MS_WIldstyleLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_WIldstyleMid.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_WIldstyleHigh.rsm", MUSIC_DEFAULT_VOLUME)
    PlayCutsceneWithLoad("5-09", true, false, false)
    MissionDontFadeIn()
    TaggingStopPersistentTag()
    DATLoad("5_09.DAT", 2)
    DATInit()
    LoadAnimationGroup("5_09MakingAMark")
    LoadAnimationGroup("W_SprayCan")
    LoadAnimationGroup("NPC_Adult")
    LoadActionTree("Act/Conv/5_09.act")
    if PlayerGetMoney() < 100 then
        PlayerSetMoney(100)
    end
end

function MissionCleanup()
    WeaponSetRangeMultiplier(gPlayer, 328, 1)
    WeaponSetRangeMultiplier(gPlayer, 426, 1)
    CameraAllowChange(true)
    DeletePersistentEntity(tagIndex, tagObject)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    CameraReturnToPlayer(false)
    SoundStopInteractiveStream()
    DATUnload(2)
    UnLoadAnimationGroup("5_09MakingAMark")
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("W_SprayCan")
end

function main()
    LoadModels(tblPedModels)
    LoadVehicleModels(tblVehicleModels)
    LoadWeaponModels(tblWeaponModels)
    F_TableInit()
    CreateThread("T_TowerCam")
    AreaTransitionPoint(0, POINTLIST._5_09_PLAYER_START)
    PlayerSetControl(1)
    CameraFade(1000, 1)
    Wait(1000)
    F_GetToCityHall()
    F_TagCityHall()
    F_PhotoCityHall()
    F_GetBackToDorm()
    UnloadModels(tblPedModels)
    UnloadModels(tblVehicleModels)
    UnloadModels(tblWeaponModels)
    UnLoadAnimationGroup("5_09MakingAMark")
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("W_SprayCan")
    CameraFade(500, 0)
    Wait(505)
    if PedIsValid(idPeter) then
        PedDelete(idPeter)
    end
    PlayCutsceneWithLoad("5-09B", true, false)
    bMissionComplete = true
    CameraReset()
    CameraReturnToPlayer()
    Wait(10)
    PlayerSetControl(0)
    PlayerSetPosPoint(POINTLIST._5_09_ENDPOINT, 1)
    PlayerSetControl(0)
    CameraSetXYZ(-496.31378, 312.60037, 32.44427, -495.61215, 311.88794, 32.432938)
    CameraSetWidescreen(true)
    Wait(500)
    CameraFade(500, 1)
    Wait(501)
    MinigameSetCompletion("M_PASS", true, 0)
    MinigameAddCompletionMsg("MRESPECT_DP25", 2)
    MinigameAddCompletionMsg("MRESPECT_NM75", 1)
    MinigameAddCompletionMsg("MRESPECT_PM75", 1)
    MinigameAddCompletionMsg("MRESPECT_GM75", 1)
    MinigameAddCompletionMsg("MRESPECT_JM75", 1)
    SoundPlayMissionEndMusic(true, 10)
    SetFactionRespect(1, 25)
    SetFactionRespect(5, 25)
    SetFactionRespect(4, 25)
    SetFactionRespect(2, 25)
    SetFactionRespect(3, 25)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(501)
    CameraReset()
    CameraReturnToPlayer()
    MissionSucceed(false, false, false)
    Wait(500)
    CameraFade(500, 1)
    Wait(101)
    PlayerSetControl(1)
end

function T_TowerCam()
    local bInTrigger = false
    while MissionActive() do
        Wait(0)
        if not bInTrigger then
            if PlayerIsInTrigger(TRIGGER._5_09_TOWERTOP) then
                CameraSetSpeed(20, 20, 20)
                CameraLookAtPathSetSpeed(20, 20, 20)
                CameraSetPath(PATH._5_09_TowerCam, false)
                CameraLookAtPath(PATH._5_09_TowerCamLook, false)
                CameraAllowChange(false)
                bInTrigger = true
            end
        elseif not PlayerIsInTrigger(TRIGGER._5_09_TOWERTOP) then
            CameraAllowChange(true)
            CameraReturnToPlayer(false)
            bInTrigger = false
        end
    end
end

local bButtonPress = false

function F_CameraText()
end

function T_HACKPUNISHMENTLEVEL()
    while not (not PlayerIsInTrigger(TRIGGER._5_09_CITYHALL_GROUNDS) or PlayerIsInStealthProp()) do
        PlayerSetPunishmentPoints(200)
        Wait(250)
    end
end
