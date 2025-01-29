local gGary
local gObjectives = {}
local gMissionState = "main"
local gMissionUpdateFunction
local gClothingTutorial = false
local gChangedProperly = false
local gPlayerDrankPop = false
local bPlayerSawGaryCutscene = false
local bGarySaidFinalSpeech = false
local shoesModel, shoesTxd, topModel, topTxd, pantsModel, pantsTxd, headModel, headTxd, leftWristModel, leftWristTxd, rightWristModel, rightWristTxd

function F_LockDoorGeneral(doorId, state)
    AreaSetDoorLocked(doorId, state)
    AreaSetDoorLockedToPeds(doorId, state)
end

function MissionSetup()
    MissionDontFadeIn()
    PlayerSetHealth(75)
    ClothingSetPlayerOutfit("Starting")
    ClothingBuildPlayer()
    AreaDisableCameraControlForTransition(true)
    PlayCutsceneWithLoad("1-02B", true, false, true)
    AreaDisableCameraControlForTransition(false)
    DATLoad("1_02A.DAT", 2)
    DATInit()
end

function F_MissionSetup()
    WeatherSet(0)
    ClockSet(8, 30)
    gModelList = { 130 }
    LoadPedModels(gModelList)
    LoadWeaponModels({ 362 })
    shared.lockClothingManager = true
    shared.cm_lockHead = true
    shared.cm_lockTorso = true
    shared.cm_lockLWrist = true
    shared.cm_lockRWrist = true
    shared.cm_lockLegs = true
    shared.cm_lockFeet = true
    shared.cm_lockOutfit = false
    LoadAnimationGroup("Area_School")
    LoadActionTree("Act/Conv/1_02.act")
    PlayerSetControl(1)
end

function MissionCleanup()
    ClearTextQueue()
    F_LockDoorGeneral("DT_DORMEXITDOORL", false)
    F_LockDoorGeneral("DORMEXITDOORR", false)
    if gMissionState == "passed" then
        PlayerSetPosPoint(POINTLIST._ENDPOSITION, 1)
        CameraSetXYZ(-483.5392, 310.9543, 39.141697, -482.76212, 310.40588, 38.833183)
        shared.lockClothingManager = false
        shared.cm_lockHead = false
        shared.cm_lockTorso = false
        shared.cm_lockLWrist = false
        shared.cm_lockRWrist = false
        shared.cm_lockLegs = false
        shared.cm_lockFeet = false
    else
        shared.lockClothingManager = true
        shared.cm_lockHead = true
        shared.cm_lockTorso = true
        shared.cm_lockLWrist = true
        shared.cm_lockRWrist = true
        shared.cm_lockLegs = true
        shared.cm_lockFeet = true
        shared.cm_lockOutfit = false
    end
    DATUnload(2)
    UnLoadAnimationGroup("Area_School")
    PlayerSetControl(1)
    CameraAllowChange(true)
    CameraReturnToPlayer()
    CameraReset()
    SoundEnableSpeech_ActionTree()
    PedSetActionNode(gPlayer, "/Global/1_02/IdleFight/SimpleIdle", "Act/Conv/1_02.act")
    if gGary ~= nil and PedIsValid(gGary) then
        PedSetFlag(gGary, 129, false)
        PedDelete(gGary)
    end
end

function F_ClothingTutorial()
    if ClothingGetPlayer(1) == ObjectNameToHashID(shared.gUniformTorso) and not shared.PlayerInClothingManager then
        shared.lockClothingManager = true
        if gGary and PedIsValid(gGary) then
            PedSetFlag(gGary, 129, false)
            PedDelete(gGary)
        end
        CameraFade(1, 0)
        Wait(1)
        F_RemoveObjectiveBlip()
        gChangedProperly = true
        CameraFade(1, 0)
        Wait(100)
        UnLoadAnimationGroup("Area_School")
        PlayerSetPosPoint(POINTLIST._ENDPOSITION, 1)
        Wait(100)
        PlayCutsceneWithLoad("1-02E", true, true)
        MissionObjectiveComplete(gObjectives[2])
        PlayerSetControl(1)
        gMissionState = "passed"
        shared.lockClothingManager = false
    end
end

function F_RunTutorials()
    shared.lockClothingManager = false
    shared.cm_lockHead = true
    shared.cm_lockTorso = true
    shared.cm_lockLWrist = true
    shared.cm_lockRWrist = true
    shared.cm_lockLegs = true
    shared.cm_lockFeet = true
    shared.cm_lockOutfit = false
    --print("CLOTHING TUTORIAL!!!!")
    --print("CLOTHING TUTORIAL!!!!")
    --print("CLOTHING TUTORIAL!!!!")
    --print("CLOTHING TUTORIAL!!!!")
    --print("CLOTHING TUTORIAL!!!!")
    --print("CLOTHING TUTORIAL!!!!")
    gMissionUpdateFunction = F_ClothingTutorial
end

function F_GoToRoom()
    local x, y, z = GetPointFromPointList(POINTLIST._INBEDROOM, 2)
    if AreaGetVisible() == 14 and PlayerIsInTrigger(TRIGGER._PLAYER_ROOM) then
        gMissionUpdateFunction = F_RunTutorials
    end
end

function CB_ReachedBedroom(pedId, pathId, nodeId)
    --print("Gary reached node: ", nodeId)
    if nodeId == PathGetLastNode(pathId) then
        SoundEnableSpeech_ActionTree()
        PedIgnoreStimuli(gGary, false)
        PedFaceHeading(gGary, 0, 0)
        --print("WTF????")
        bGarySaidFinalSpeech = true
    end
end

function CB_GiveRoomObjective()
    TextPrint("1_02A_LOGOBJ04", 5, 1)
    table.insert(gObjectives, MissionObjectiveAdd("1_02A_LOGOBJ04"))
    MissionObjectiveComplete(gObjectives[1])
    F_AddObjectiveBlip("POINT", POINTLIST._CLOTHESDORM, 1, 1)
end

function F_GrabPop()
    local x, y, z = GetPointFromPointList(POINTLIST._1_02A_POPMACH, 1)
    if PlayerIsInAreaXYZ(x, y, z, 2, 0) then
        if PlayerGetMoney() < 100 then
            PlayerSetMoney(100)
        end
        if PedIsPlaying(gPlayer, "/Global/SodaMach", true) then
            SoundDisableSpeech_ActionTree()
            while PedIsPlaying(gPlayer, "/Global/SodaMach", true) do
                Wait(0)
            end
            gPlayerDrankPop = true
            PedSetActionNode(gGary, "/Global/1_02/PointAtPlayer", "Act/Conv/1_02.act")
            SoundPlayScriptedSpeechEvent(gGary, "M_1_02A", 72, "large")
            SoundEnableSpeech_ActionTree()
            while PedIsPlaying(gGary, "/Global/1_02/PointAtPlayer", true) do
                Wait(0)
            end
            PedFollowPath(gGary, PATH._TOBEDROOM, 0, 0, CB_ReachedBedroom, 3)
            TextPrint("1_02A_CLOTHOBJ", 5, 1)
            table.insert(gObjectives, MissionObjectiveAdd("1_02A_CLOTHOBJ"))
            MissionObjectiveComplete(gObjectives[1])
            F_AddObjectiveBlip("POINT", POINTLIST._CLOTHESDORM, 1, 1)
            gMissionUpdateFunction = F_GoToRoom
        end
    end
end

function CB_ReachedMachine(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) then
        PedFaceHeading(gGary, 0, 1)
    end
end

function CB_GaryDied()
    --print("GARY DIED!!!")
    --print("GARY DIED!!!")
    --print("GARY DIED!!!")
    --print("GARY DIED!!!")
    shared.lockClothingManager = true
    shared.cm_lockHead = true
    shared.cm_lockTorso = true
    shared.cm_lockLWrist = true
    shared.cm_lockRWrist = true
    shared.cm_lockLegs = true
    shared.cm_lockFeet = true
    shared.cm_lockOutfit = false
    gMissionState = "GaryDied"
end

function CB_GiveSodaObjective()
    SoundEnableSpeech_ActionTree()
    TextPrint("1_02A_SODAMACH", 5, 1)
    table.insert(gObjectives, MissionObjectiveAdd("1_02A_SODAMACH"))
    F_AddObjectiveBlip("POINT", POINTLIST._1_02A_POPMACH, 1, 1)
end

function main()
    F_MissionSetup()
    AreaTransitionPoint(14, POINTLIST._AREATRANSITIONBOYS, 1)
    PlayerFaceHeadingNow(0)
    SoundDisableSpeech_ActionTree()
    CameraReturnToPlayer()
    CameraReset()
    PlayerSetPunishmentPoints(0)
    gGary = PedCreatePoint(130, POINTLIST._INBEDROOM, 1)
    PedIgnoreStimuli(gGary, true)
    PedSetTypeToTypeAttitude(11, 6, 3)
    PedSetFlag(gGary, 129, true)
    PedSetMissionCritical(gGary, true, CB_GaryDied)
    PedFollowPath(gGary, PATH._TOSODAMACHINE, 0, 0, CB_ReachedMachine)
    CameraFade(500, 1)
    Wait(501)
    SoundStopCurrentSpeechEvent()
    QueueSoundSpeech(gGary, "M_1_02A", 116)
    Wait(10)
    TutorialStart("SODACAN")
    Wait(1000)
    CB_GiveSodaObjective()
    gMissionUpdateFunction = F_GrabPop
    while gMissionState == "main" do
        Wait(0)
        gMissionUpdateFunction()
        PedLockTarget(gGary, gPlayer, 3)
        UpdateTextQueue()
        if gGary and PedIsValid(gGary) and PedIsPlaying(gGary, "/Global/Garbagecan/PedPropsActions/StuffGrap", true) then
            F_LockDoorGeneral("DT_DORMEXITDOORL", true)
            F_LockDoorGeneral("DORMEXITDOORR", true)
            PedSetMissionCritical(gGary, false)
            shared.lockClothingManager = true
            shared.cm_lockHead = true
            shared.cm_lockTorso = true
            shared.cm_lockLWrist = true
            shared.cm_lockRWrist = true
            shared.cm_lockLegs = true
            shared.cm_lockFeet = true
            shared.cm_lockOutfit = false
            gMissionState = "GaryDied"
        end
    end
    if gMissionState == "passed" then
        MissionSucceed(false, false, false)
        shared.schoolSave = true
    elseif gMissionState == "GaryDied" then
        --print("Gary was knocked out!")
        local bHumiliated, gPed = PedHasGeneratedStimulusOfType(gPlayer, 49)
        if 0 >= PedGetHealth(gGary) and gPed ~= gGary then
            MissionFail(true, true, "1_02A_GARYKO")
        else
            MissionFail(true, true, "1_02A_GARYHAR")
        end
    else
        SoundPlayMissionEndMusic(false, 10)
        MissionFail()
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
            gObjectiveBlip = BlipAddXYZ(x, y, z + 0.1, 0, blipEnum)
        elseif blipType == "CHAR" and not PedIsDead(point) then
            Wait(100)
            gObjectiveBlip = AddBlipForChar(point, index, 0, blipEnum)
        end
    end
end

function F_PlayerDrankPop()
    if not gPlayerDrankPop then
        --print("PLAYER IS GETTING POP!!")
        return 1
    end
    return 0
end
