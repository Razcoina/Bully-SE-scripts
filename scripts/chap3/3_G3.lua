--[[ Changes to this file:
    * Modified function F_TableInit, may require testing
    * Removed unused local variables
    * Removed function F_PlayerPressedDebugSquare, not present in original script
    * Removed function F_PlayerSelectNIS, not present in original script
    * Removed function F_EndingCinematicTest, not present in original script
    * Modified function main, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/BikeRace_util.lua")
ImportScript("Library/LibPropNewer.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibObjective.lua")
local debug_level = 2
local treeLockDelay = 5000
local treeResetRange = 75
local tblPersistentEntity, tblCar, tblBoulder, tblTreePed, tblTree, tblCar, tblAnimGroup, tblRace, tblPlayer, tblRacer, tblShortcut, tblHighlightedNode
local greaserToPlayerAttitude = PedGetTypeToTypeAttitude(4, 13)
local dBouldersRolling = 0
local tblCutscenePed, gPlayerCurrentNode
local cheeringCrowdGenerated = false
local ambientLola, bCritFail, bLolaMoved
local bWin = false
local szFailReason
--[[
local currentNIS = 1
]] -- Not present in original script
local tblRequestCheerers = {
    22,
    29,
    26,
    27
}

function F_TableInit() -- ! Modified
    tblAnimGroup = {
        "NPC_Love",
        "F_Girls",
        "F_Greas",
        "GEN_Social",
        "NPC_Adult",
        "NPC_Cheering"
    }
    tblCutscenePed = {
        lola = {
            model = 25,
            point = POINTLIST._3_G3_ECS_LOLA
        },
        johnny = {
            model = 23,
            point = POINTLIST._3_G3_ECS_JOHNNY
        },
        lucky = {
            model = 26,
            point = POINTLIST._3_G3_ECS_LUCKY
        },
        ricky = {
            model = 28,
            point = POINTLIST._3_G3_ECS_RICKY
        }
    }
    tblPersistentEntity = {
        {
            id = "TrainCarA",
            x = 269.828,
            y = -320.245,
            z = 8.04618,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR1A,
            speed = 30,
            proximity = 50
        },
        {
            id = "TrainCarB",
            x = 259.247,
            y = -325.883,
            z = 8.0465,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR1B,
            speed = 30,
            proximity = 50
        },
        {
            id = "TrainCarC",
            x = 214.972,
            y = -324.634,
            z = 8.04649,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR2A,
            speed = 20,
            proximity = 30
        },
        {
            id = "TrainCarA",
            x = 237.265,
            y = -325.231,
            z = 8.04209,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR2B,
            speed = 20,
            proximity = 30
        },
        {
            id = "TrainCarB",
            x = 197.714,
            y = -335.339,
            z = 8.0422,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR3A,
            speed = 20,
            proximity = 30
        },
        {
            id = "TrainCarC",
            x = 177.313,
            y = -334.695,
            z = 8.04544,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR3B,
            speed = 20,
            proximity = 30
        },
        {
            id = "TrainCarB",
            x = 66.7701,
            y = -356.466,
            z = 8.04554,
            heading = 104,
            visibleArea = 0
        },
        {
            id = "TrainCarA",
            x = 64.7703,
            y = -352.59,
            z = 8.04618,
            heading = 104,
            visibleArea = 0
        },
        {
            id = "TrainCarB",
            x = 57.7807,
            y = -350.614,
            z = 8.0465,
            heading = 106,
            visibleArea = 0
        },
        {
            id = "TrainCarA",
            x = 79.2999,
            y = -353.974,
            z = 8.04206,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR4A,
            speed = 35,
            proximity = 65
        },
        {
            id = "TrainCarB",
            x = 77.8257,
            y = -350.025,
            z = 8.0422,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR4B,
            speed = 35,
            proximity = 65
        }
    }
    shared.tblPersistentEntity = tblPersistentEntity
    tblTreePed = {
        {
            point = POINTLIST._3_G3_TREEPED1,
            model = 29,
            asleep = true,
            ignoreStimuli = true
        },
        {
            point = POINTLIST._3_G3_TREEPED3,
            model = 22,
            asleep = true,
            ignoreStimuli = true
        },
        {
            point = POINTLIST._3_G3_TREEPED4,
            model = 28,
            asleep = true,
            ignoreStimuli = true
        }
    }
    tblTree = {
        {
            id = TRIGGER._3_G3_TREE1,
            fallen = false,
            fallTrigger = TRIGGER._3_G3_TREE1,
            treePed = tblTreePed[1]
        },
        {
            id = TRIGGER._3_G3_TREE3,
            fallen = false,
            fallTrigger = TRIGGER._3_G3_TREE3,
            treePed = tblTreePed[2]
        },
        {
            id = TRIGGER._3_G3_TREE4,
            fallen = false,
            fallTrigger = TRIGGER._3_G3_TREE4,
            treePed = tblTreePed[3]
        }
    }
    for i, tree in tblTree, nil do
        tree.x, tree.y, tree.z = GetAnchorPosition(tree.id)
    end
    tblCar = {}
    tblRace = {
        laps = 1,
        path = PATH._3_G3_RACE,
        missionCode = "3_G3",
        jump_nodes = {
            7,
            14,
            15,
            36,
            42
        },
        end_mission_on_finish = false,
        countdown_ped = {
            model = 25,
            point = POINTLIST._3_G3_LOLACOUNTDOWN
        },
        auto_lineup = true,
        soundTrack = "MS_BikeRace01.rsm",
        volume = 1
    }
    tblPlayer = {
        id = nil,
        bike = nil,
        start_pos = POINTLIST._3_G3_PLAYER,
        area_code = 0,
        bike_model = 273
    }
    tblRacer = {
        {
            id = nil,
            bike = nil,
            blip = nil,
            model = 26,
            bike_model = 273,
            max_sprint_speed = 0.88,
            max_normal_speed = 0.83,
            catch_up_dist = 14.5,
            catch_up_speed = 1.3,
            slow_down_dist = 25,
            slow_down_speed = 0.35,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            target = nil,
            sprint_freq = 0,
            sprint_duration = 0,
            sprint_likelyhood = 0,
            aggressiveness = 0.65
        },
        {
            id = nil,
            bike = nil,
            blip = nil,
            model = 28,
            bike_model = 273,
            max_sprint_speed = 0.88,
            max_normal_speed = 0.83,
            catch_up_dist = 14.5,
            catch_up_speed = 1.3,
            slow_down_dist = 25,
            slow_down_speed = 0.35,
            shortcut_odds = 40,
            shooting_odds = 0,
            trick_odds = 0,
            target = nil,
            sprint_freq = 0,
            sprint_duration = 0,
            sprint_likelyhood = 0,
            aggressiveness = 0.6
        },
        {
            id = nil,
            bike = nil,
            blip = nil,
            model = 23,
            bike_model = 273,
            max_sprint_speed = 0.92,
            max_normal_speed = 0.85,
            catch_up_dist = 10,
            catch_up_speed = 1.6,
            slow_down_dist = 25,
            slow_down_speed = 0.35,
            shortcut_odds = 100,
            shooting_odds = 0,
            trick_odds = 0,
            target = nil,
            sprint_freq = 0,
            sprint_duration = 0,
            sprint_likelyhood = 0,
            aggressiveness = 0.8
        }
    }
    tblShortcut = {
        {
            path = PATH._3_G3_SCUT01,
            start_node = 3,
            end_node = 5,
            jump_nodes = { 1 }
        },
        {
            path = PATH._3_G3_SCUT02,
            start_node = 9,
            end_node = 9,
            jump_nodes = { 2 }
        },
        {
            path = PATH._3_G3_SCUT05,
            start_node = 16,
            end_node = 20
        },
        {
            path = PATH._3_G3_SCUT08,
            start_node = 42,
            end_node = 48
        },
        {
            path = PATH._3_G3_SCUT09,
            start_node = 51,
            end_node = 56
        },
        {
            path = PATH._3_G3_SCUT10,
            start_node = 82,
            end_node = 85,
            jump_nodes = { 3 }
        }
    }
    tblHighlightedNode = {
        1,
        2,
        3,
        6,
        8,
        10,
        11,
        12,
        13,
        16,
        20,
        21,
        22,
        23,
        24,
        25,
        27,
        31,
        32,
        34,
        35,
        36,
        37,
        39,
        40,
        41,
        43,
        48,
        49,
        50,
        51,
        57,
        58,
        59,
        60,
        62,
        63,
        64,
        66,
        72,
        74,
        77,
        80,
        81,
        82,
        83,
        85,
        86
    }
    tblRaceInfo = { race = tblRace, racers = tblRacer }
    tblObjective = {
        --[[
        enterNISDebug = {
            successConditions = { F_PlayerPressedDebugSquare }
        },
        selectNIS = {
            activator = {
                "enterNISDebug"
            },
            successConditions = { F_PlayerSelectNIS },
            successConditionParam = { F_EndingCinematicTest }
        },
        ]] -- Not present in original script
        winRace = {
            successConditions = { L_RaceIsOver },
            successConditionParam = tblRaceInfo,
            completeActions = { F_EndRaceProperly },
            completeActionParam = tblRaceInfo,
            stopOnCompleted = true
        },
        loseRace = {
            successConditions = { L_RacePlayerNotFirst },
            successConditionParam = tblRaceInfo,
            completeActions = { F_EndRaceProperly },
            completeActionParam = tblRaceInfo,
            stopOnCompleted = true
        },
        stayOnBike = {
            failureConditions = { L_RaceStayOnBike },
            failureConditionParam = tblRaceInfo,
            failActions = { F_EndRaceProperlyNoBike },
            failActionParam = tblRaceInfo,
            stopOnFailed = true
        },
        tooFarBehind = {
            failureConditions = { L_RaceTooFarBehind },
            failureConditionParam = tblRaceInfo,
            failActions = { F_EndRaceProperlyTooFarBehind },
            failActionParam = tblRaceInfo,
            stopOnFailed = true
        }
    }
end

--[[
function F_PlayerPressedDebugSquare()
    retVal = F_IsButtonPressedWithDelayCheck(6, 1)
    return false
end

function F_PlayerSelectNIS(tblNIS)
    if F_IsButtonPressedWithDelayCheck(11, 1) then
        local NISCount = table.getn(tblNIS)
        currentNIS = currentNIS - 1
        currentNIS = 0 < currentNIS and currentNIS or NISCount
    elseif F_IsButtonPressedWithDelayCheck(13, 1) then
        local NISCount = table.getn(tblNIS)
        currentNIS = currentNIS + 1
        currentNIS = NISCount >= currentNIS and currentNIS or 1
    elseif F_IsButtonPressedWithDelayCheck(6, 1) then
        tblNIS[currentNIS]()
        CameraFade(1000, 1)
    end
    TextPrintString("Current NIS: " .. tostring(currentNIS), 0, 1)
    return false
end

function F_EndingCinematicTest()
    F_EndingCinematic_new()
    SoundPlayMissionEndMusic(true, 8)
    MissionSucceed(true)
    RaceForceEnd()
end
]] -- Not present in original script

function F_EndingCinematicPlacement()
    tblPlayer.bike = nil
    if PedIsOnVehicle(gPlayer) then
        tblPlayer.bike = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
        VehicleStop(tblPlayer.bike)
    end
    L_PedLoadPoint("endCutScene", tblCutscenePed)
    L_PedExec("endCutScene", PedSetStationary, "id", true)
    AreaTransitionPoint(0, POINTLIST._3_G3_ECS_PLAYER)
    if tblPlayer.bike then
        VehicleSetPosPoint(tblPlayer.bike, POINTLIST._3_G3_ECS_PLAYERENDBIKE)
    end
end

function F_EndingCinematic()
    PedSetTypeToTypeAttitude(4, 13, 2)
    CameraSetXYZ(448.43118, -453.8729, 3.481086, 449.27124, -453.35522, 3.643245)
    CameraFade(1000, 1)
    Wait(1000)
    TextPrintString("LOLA: Wow Jimmy, you really are FAST.", 3)
    WaitSkippable(3000)
    TextPrintString("LOLA: Here's your reward...", 3)
    WaitSkippable(3000)
    TextPrintString("", 0)
    CameraSetXYZ(451.51382, -455.31387, 3.881687, 451.39505, -454.32098, 3.889789)
    PedMoveToPoint(tblCutscenePed.lola.id, 0, POINTLIST._3_G3_ECS_PLAYER)
    PedFaceObjectNow(tblCutscenePed.johnny.id, gPlayer, 2)
    PedFaceObjectNow(tblCutscenePed.lucky.id, gPlayer, 2)
    PedFaceObjectNow(tblCutscenePed.ricky.id, gPlayer, 2)
    while not PedIsInAreaObject(tblCutscenePed.lola.id, gPlayer, 2, 0.7, 0) do
        Wait(0)
    end
    ExecuteActionNode(gPlayer, "/Global/3_G3/CustomAnim/Kiss", "Act/Conv/3_G3.act")
    ExecuteActionNode(tblCutscenePed.johnny.id, "/Global/3_G3/CustomAnim/StraightenCollar", "Act/Conv/3_G3.act")
    while PedIsPlaying(gPlayer, "/Global/3_G3/CustomAnim/Kiss", true) do
        Wait(0)
    end
    TextPrintString("", 0)
    PedFollowPath(tblCutscenePed.lola.id, PATH._3_G3_ECS_LOLA, 0, 0, F_LolaCallback)
    while tblCutscenePed.lola.currentNode ~= 1 do
        Wait(0)
    end
    CameraSetXYZ(450.29413, -452.8266, 4.581086, 449.91525, -452.0024, 3.660151)
    CameraLookAtObject(tblCutscenePed.lola.id, 2, true)
    PedFaceObjectNow(gPlayer, tblCutscenePed.lola.id, 2)
    while tblCutscenePed.lola.currentNode ~= 2 do
        Wait(0)
    end
    CameraSetXYZ(450.80664, -453.09134, 5.081076, 451.1208, -452.2524, 4.636652)
    TextPrintString("JOHNNY: What do you think you're doing?", 3)
    ExecuteActionNode(tblCutscenePed.johnny.id, "/Global/3_G3/CustomAnim/Angry", "Act/Conv/3_G3.act")
    WaitSkippable(3000)
    TextPrintString("", 0)
    CameraSetXYZ(448.2099, -454.3673, 4.281082, 448.99185, -453.7759, 4.084187)
    PedFaceObjectNow(gPlayer, tblCutscenePed.johnny.id, 2)
    ExecuteActionNode(gPlayer, "/Global/3_G3/CustomAnim/Dismiss", "Act/Conv/3_G3.act")
    WaitSkippable(1000)
    TextPrintString("JIMMY: Don't hate the player, hate the game.", 3)
    WaitSkippable(3000)
    TextPrintString("", 0)
    PedFollowPath(gPlayer, PATH._3_G3_ECS_LOLA, 0, 0, F_PlayerCallback)
    while PedIsOnScreen(gPlayer) do
        PedFaceObjectNow(tblCutscenePed.johnny.id, gPlayer, 2)
        PedFaceObjectNow(tblCutscenePed.lucky.id, gPlayer, 2)
        PedFaceObjectNow(tblCutscenePed.ricky.id, gPlayer, 2)
        PedFaceObjectNow(tblCutscenePed.lola.id, gPlayer, 2)
        Wait(0)
    end
    CameraFade(1000, 0)
    Wait(1000)
    PedStop(gPlayer)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
end

function F_EndingCinematic_new()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(501)
    if PedIsValid(tblRaceInfo.race.countdown_ped.id) then
        PedDelete(tblRaceInfo.race.countdown_ped.id)
    end
    if PedIsValid(cheerer1) then
        PedMakeAmbient(cheerer1)
    end
    if PedIsValid(cheerer2) then
        PedMakeAmbient(cheerer2)
    end
    if PedIsValid(cheerer3) then
        PedMakeAmbient(cheerer3)
    end
    if PedIsValid(cheerer4) then
        PedMakeAmbient(cheerer4)
    end
    F_RaceEndNIS()
    PlayerDetachFromVehicle()
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(true)
    for i, ped in tblTreePed do
        if PedIsValid(ped.id) then
            PedDelete(ped.id)
        end
    end
    RaceDeleteRacers()
    local greaserAttitude = PedGetTypeToTypeAttitude(4, 13)
    PedSetTypeToTypeAttitude(4, 13, 2)
    F_EndingCinematicPlacement()
    PedFaceObject(tblCutscenePed.lola.id, gPlayer, 3, 0)
    PedLockTarget(tblCutscenePed.lola.id, gPlayer, 3)
    DoublePedShadowDistance(true)
    CameraFade(500, 1)
    CameraSetXYZ(447.92715, -452.50043, 3.676833, 448.8808, -452.2007, 3.654106)
    PedSetActionNode(tblCutscenePed.johnny.id, "/Global/3_G3_Conv/WinRaceNIS/Greasers/Johnny", "Act/Conv/3_G3.act")
    F_PlaySpeechWait(tblCutscenePed.johnny.id, "M_3_G3", 10, "large", false)
    CameraSetXYZ(449.7887, -450.4285, 3.799799, 450.55457, -451.05997, 3.918999)
    PedSetActionNode(tblCutscenePed.lola.id, "/Global/3_G3_Conv/WinRaceNIS/Greasers/Lola", "Act/Conv/3_G3.act")
    F_PlaySpeechWait(tblCutscenePed.lola.id, "M_3_G3", 12, "large", false)
    PedSetTypeToTypeAttitude(4, 13, greaserAttitude)
    ambientLola = tblCutscenePed.lola.id
    L_PedExec("endCutScene", F_GreasersLeave, "id")
    PedSetEmotionTowardsPed(ambientLola, gPlayer, 8, true)
    PedSetPedToTypeAttitude(ambientLola, gPlayer, 4)
    PedSetFlag(ambientLola, 84, true)
    PedClearObjectives(ambientLola)
    PedFaceObject(gPlayer, ambientLola, 2, 1)
    PedFaceObject(ambientLola, gPlayer, 3, 0)
    PedLockTarget(gPlayer, ambientLola, 3)
    Wait(500)
    PedSetStationary(ambientLola, false)
    PedSetActionNode(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt", "Act/Player.act")
    while not PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
        Wait(0)
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    Wait(1000)
    MinigameSetCompletion("M_PASS", true, 0, "3_G3_UNLOCK")
    MinigameAddCompletionMsg("MRESPECT_GM20", 1)
    SoundPlayMissionEndMusic(true, 8)
    Wait(500)
    while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) or PedIsPlaying(ambientLola, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
        Wait(0)
    end
    PedLockTarget(gPlayer, -1, 3)
    Wait(500)
    PedMakeAmbient(ambientLola)
    PedWander(ambientLola, 0)
    DoublePedShadowDistance(false)
end

function F_RaceEndNIS()
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    PedStop(gPlayer)
    F_MakePlayerSafeForNIS(true)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(1500)
    RaceDeleteRacers()
    local x, y, z = PedGetOffsetInWorldCoords(gPlayer, 0.9, 1.8, 1)
    local fx, fy, fz = PedGetOffsetInWorldCoords(gPlayer, 0, 0, 1)
    CameraSetXYZ(x, y, z, fx, fy, fz)
    CameraFade(500, 1)
    MinigameSetCompletion("M_RACEWIN", true)
    SoundStopInteractiveStream(3000)
    Wait(400)
    if PedIsInAnyVehicle(gPlayer) and not VehicleIsModel(VehicleFromDriver(gPlayer), 276) then
        PedSetActionNode(gPlayer, "/Global/Vehicles/Bikes/ScriptCalls/RaceVictory", "Act/Vehicles.act")
    end
    while PedIsPlaying(gPlayer, "/Global/Vehicles/Bikes/ScriptCalls/RaceVictory", true) do
        Wait(0)
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    Wait(2000)
    CameraFade(500, 0)
    Wait(505)
end

function F_GreasersDelete(id)
    if PedIsValid(id) and not PedIsModel(id, 25) then
        PedDelete(id)
    end
end

function F_GreasersLeave(id)
    if id ~= tblCutscenePed.lola.id then
        PedSetStationary(id, false)
        PedIgnoreStimuli(id, true)
        PedFollowPath(id, PATH._3_G3_ECS_LOLA, 0, 0)
    end
end

function F_WaterMonitor()
    Wait(10000)
    local race_lost = false
    local last_z = 0
    while not race_lost do
        local x, y, z = VehicleGetPosXYZ(tblPlayer.bike)
        if z < 0 and last_z < 0 then
            TextPrintString("Try to stay out of the water", 3, 1)
            Wait(3000)
            SoundPlayMissionEndMusic(false, 8)
            MissionFail()
            race_lost = true
        end
        Wait(1000)
        last_z = z
    end
end

function F_TreeMonitor(tree)
    if not tree.pedSpawned and PlayerIsInAreaXYZ(tree.x, tree.y, tree.z, 100, 0) then
        tree.pedSpawned = true
        L_PedCreate(tree.treePed)
    elseif tree.pedSpawned and not tree.fallen and PlayerIsInTrigger(tree.fallTrigger) then
        local treePedID = tree.treePed.id
        tree.fallen = true
        PedSetActionNode(treePedID, "/Global/3_G3_Conv/CustomAnim/Push", "Act/Conv/3_G3.act")
        PAnimSetActionNode(tree.id, "/Global/TreeFall/Damage/Fall", "Act/Props/TreeFall.act")
        PedSetAsleep(treePedID, false)
        PedMakeAmbient(treePedID)
        PedAttackPlayer(treePedID, 3)
    elseif not tree.deleted and tree.fallen and not PlayerIsInAreaXYZ(tree.x, tree.y, tree.z, treeResetRange, 0) then
        PAnimDelete(tree.id)
        tree.deleted = true
    elseif tree.deleted and PlayerIsInAreaXYZ(tree.x, tree.y, tree.z, treeResetRange, 0) then
        PAnimCreate(tree.id)
        Wait(0)
        PAnimSetActionNode(tree.id, "/Global/TreeFall/Damage/Fall", "Act/Props/TreeFall.act")
        tree.deleted = false
    end
end

function F_TrainMonitor()
    for i, train in tblPersistentEntity do
        if train.path and not train.moving and PlayerIsInAreaXYZ(train.x, train.y, train.z, train.proximity, 0) then
            train.moving = true
            PAnimSetPathFollowSpeed(train.poolIndex, train.type, train.speed)
            PAnimFollowPathSoundLoop(train.poolIndex, train.type, "TrainLoop")
        end
    end
end

function F_LolaCallback(ped, path, node)
    tblCutscenePed.lola.currentNode = node
end

function F_PlayerCallback(ped, path, node)
    gPlayerCurrentNode = node
end

function F_LolaMakeKissable()
    local lolaID = tblCutscenePed.lola.id
    PedRecruitAlly(gPlayer, lolaID)
    PedSetRequiredGift(lolaID, 2, false)
    PedSetEmotionTowardsPed(lolaID, gPlayer, 8)
end

function F_PedFacePlayer(id)
    PedFaceObjectNow(id, gPlayer, 2)
end

function F_TrainSoundCallback(trainID, path, node)
    if node == 1 then
        local x, y, z = GetPointFromPath(path, 1)
        SoundPlay2D("TrainStop")
        for i, train in shared.tblPersistentEntity do
            if train.path == path then
                PAnimClearWhenDoneRotation(train.poolIndex, train.type)
                PAnimFollowPathSoundLoop(train.poolIndex, train.type, "")
            end
        end
    end
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while SoundSpeechPlaying() do
            Wait(0)
        end
    end
    return false
end

function MissionSetup()
    if not shared.g3G3TrainTest then
        SoundEnableInteractiveMusic(false)
        PlayCutsceneWithLoad("3-G3", true)
    end
    GarageSetIsDeactivated(true)
    MissionDontFadeIn()
    DisablePOI()
end

function F_MissionPlacement()
    DATLoad("3_G3.DAT", 2)
    DATInit()
    F_TableInit()
    L_ObjectiveSetParam(tblObjective)
    for i, entity in tblPersistentEntity do
        entity.poolIndex, entity.type = CreatePersistentEntity(entity.id, entity.x, entity.y, entity.z, entity.heading, entity.visibleArea)
        if entity.path then
            PAnimFollowPath(entity.poolIndex, entity.type, entity.path, false, F_TrainSoundCallback)
            PAnimSetPathFollowSpeed(entity.poolIndex, entity.type, 0)
        end
    end
    if shared.g3G3TrainTest then
        CameraFade(1000, 1)
        Wait(1000)
        F_TrainTest()
    end
    ToggleHUDComponentVisibility(0, false)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaClearAllVehicles()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
    AreaClearAllPeds()
    DisablePOI()
    L_PropLoad("tree", tblTree)
    L_PropLoad("car", tblCar)
    L_PedRequestModel(tblTreePed)
    SetParam_Race(tblRace)
    SetParam_Player(tblPlayer)
    SetParam_Racers(tblRacer)
    SetParam_HighlightedNodes(tblHighlightedNode)
    SetParam_Shortcuts(tblShortcut)
    greaserToPlayerAttitude = PedGetTypeToTypeAttitude(4, 13)
    PedSetTypeToTypeAttitude(4, 13, 0)
    for i, group in tblAnimGroup do
        LoadAnimationGroup(group)
        LoadAnimationGroup("NIS_3_G3")
    end
end

function MissionCleanup()
    EnablePOI()
    shared.gPlayerIncapacitated = nil
    PedSetMissionCritical(gPlayer, false)
    UnLoadAnimationGroup("3_G3")
    UnLoadAnimationGroup("Cheer_Girl3")
    UnLoadAnimationGroup("Cheer_Cool2")
    GarageSetIsDeactivated(false)
    SoundStopInteractiveStream()
    CameraSetWidescreen(false)
    for i, entity in tblPersistentEntity do
        --print("[MissionCleanup]>> Deleting Persisten Entity: " .. i)
        DeletePersistentEntity(entity.poolIndex, entity.type)
    end
    PedSetTypeToTypeAttitude(4, 13, greaserToPlayerAttitude)
    ToggleHUDComponentVisibility(0, true)
    RaceCleanup()
    VehicleRevertToDefaultAmbient()
    AreaRevertToDefaultPopulation()
    EnablePOI()
    shared.tblPersistentEntity = nil
    for i, group in tblAnimGroup do
        UnLoadAnimationGroup(group)
    end
    if ambientLola and PedIsValid(ambientLola) then
        PedMakeAmbient(ambientLola)
        PedWander(ambientLola, 0)
    end
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(false)
    CameraReset()
    CameraReturnToPlayer()
    DATUnload(2)
    AreaEnsureSpecialEntitiesAreCreatedWithOverride("3_G3", 0)
end

function main() -- ! Modified
    LoadActionTree("Act/Conv/3_G3.act")
    LoadActionTree("Act/Anim/Race.act")
    LoadAnimationGroup("3_G3")
    LoadAnimationGroup("Cheer_Girl3")
    LoadAnimationGroup("Cheer_Cool2")
    LoadModels(tblRequestCheerers)
    F_MissionPlacement()
    PlayerSetControl(0)
    RaceSetup()
    Wait(2000)
    F_NISRace(PATH._3_G3_PATHCAMLOOK, PATH._3_G3_PATHCAM)
    L_RaceStart(tblRaceInfo)
    PedSetMissionCritical(gPlayer, true, cbCritPlayer)
    PedSetMissionCritical(tblRaceInfo.race.countdown_ped.id, true, cbCritFail, true)
    while not L_ObjectiveProcessingDone() do
        L_PropExec("tree", F_TreeMonitor, "element")
        F_TrainMonitor()
        F_ObjectiveMonitor()
        F_MoveLola()
        Wait(0)
    end
    RaceHUDVisible(false)
    --[[
    for i, objective in tblObjective do
        print("Objective " .. tostring(i) .. " was failed? " .. tostring(objective.failed))
        print("Objective " .. tostring(i) .. " was completed? " .. tostring(objective.completed))
    end
    ]] -- Not present in original script
    PedSetMissionCritical(tblRaceInfo.race.countdown_ped.id, false)
    if bWin then
        F_EndingCinematic_new()
        SetFactionRespect(4, GetFactionRespect(4) - 20)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        L_PedExec("endCutScene", F_GreasersDelete, "id")
        CameraReset()
        CameraReturnToPlayer()
        MissionSucceed(false, false, false)
        CameraSetWidescreen(false)
        Wait(500)
        CameraFade(500, 1)
        Wait(101)
        PlayerSetControl(1)
    else
        if PedIsValid(tblRaceInfo.race.countdown_ped.id) then
            PedMakeAmbient(tblRaceInfo.race.countdown_ped.id)
        end
        if PedIsValid(cheerer1) then
            PedMakeAmbient(cheerer1)
        end
        if PedIsValid(cheerer2) then
            PedMakeAmbient(cheerer2)
        end
        if PedIsValid(cheerer3) then
            PedMakeAmbient(cheerer3)
        end
        if PedIsValid(cheerer4) then
            PedMakeAmbient(cheerer4)
        end
        SoundPlayMissionEndMusic(false, 8)
        if szFailReason then
            MissionFail(false, true, szFailReason)
        else
            MinigameSetCompletion("GKART_YOULOSE", false)
            while MinigameIsShowingCompletion() do
                Wait(0)
            end
            MissionFail(false, false)
        end
    end
end

function F_MoveLola()
    if not bLolaMoved and PlayerIsInTrigger(TRIGGER._3_G3_MOVELOLA) then
        PedSetPosPoint(tblRaceInfo.race.countdown_ped.id, POINTLIST._3_G3_CHEERINGPED1, 1)
        PedIgnoreAttacks(tblRaceInfo.race.countdown_ped.id, true)
        PedIgnoreStimuli(tblRaceInfo.race.countdown_ped.id, true)
        PedMakeTargetable(tblRaceInfo.race.countdown_ped.id, true)
        PedSetStationary(tblRaceInfo.race.countdown_ped.id, true)
        PedClearAllWeapons(tblRaceInfo.race.countdown_ped.id)
        PedSetActionNode(tblRaceInfo.race.countdown_ped.id, "/Global/3_G3_Conv/Cheerage", "Act/Conv/3_G3.act")
        cheerer1 = F_CreateCheerer(22, POINTLIST._3_G3_CHEERINGPED2, 1)
        cheerer2 = F_CreateCheerer(29, POINTLIST._3_G3_CHEERINGPED3, 1)
        cheerer3 = F_CreateCheerer(26, POINTLIST._3_G3_CHEERINGPED4, 1)
        cheerer4 = F_CreateCheerer(27, POINTLIST._3_G3_CHEERINGPED5, 1)
        bLolaMoved = true
    end
end

function F_CreateCheerer(model, point, element)
    local ped = PedCreatePoint(model, point, element)
    PedIgnoreAttacks(ped, true)
    PedIgnoreStimuli(ped, true)
    PedMakeTargetable(ped, true)
    PedSetStationary(ped, true)
    PedClearAllWeapons(ped)
    PedSetActionNode(ped, "/Global/3_G3_Conv/Cheerage", "Act/Conv/3_G3.act")
    return ped
end

function F_TrainTest()
    PedSetEffectedByGravity(gPlayer, false)
    PedSetPosXYZ(gPlayer, 273.1, -314.6, 9)
    while IsStreamingBusy() do
        Wait(0)
    end
    PedSetEffectedByGravity(gPlayer, true)
    TextPrintString("Initializing Trains in 5s. Press SELECT on Debug Controller to end test.", 4, 1)
    Wait(5000)
    while not IsButtonPressed(4, 1) do
        Wait(0)
        F_TrainMonitor()
    end
    MissionSucceed()
    Wait(50000)
end

function F_NISRace(path, pathlook)
    local x, y, z = PlayerGetPosXYZ()
    F_DeleteUnusedVehicles(x, y, z, 20)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    Wait(500)
    CameraFade(500, 1)
    CameraSetPath(path, true)
    CameraLookAtPath(pathlook, true)
    CameraSetSpeed(5, 5, 5)
    CameraLookAtPathSetSpeed(5, 5, 5)
    Wait(400)
    F_RacerSpeech(tblRaceInfo, 1)
    Wait(1200)
    F_RacerSpeech(tblRaceInfo, 2)
    Wait(1800)
    F_RacerSpeech(tblRaceInfo, 3)
    Wait(1000)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(550)
    CameraReturnToPlayer()
    CameraFade(500, 1)
    Wait(1350)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    F_MakePlayerSafeForNIS(false)
    CameraSetWidescreen(false)
end

function F_RacerSpeech(tblOfTheRace, nRacer)
    SoundPlayScriptedSpeechEvent(tblOfTheRace.racers[nRacer].id, "TRASH_TALK_TEAM", 0, "jumbo", nil)
end

function F_EndRaceProperly(param)
    local win = false
    --print("[F_EndRaceProperly] >> RUNNING")
    EndMission(param)
    if RaceGetPositionInRaceOfRacer(gPlayer) == 1 then
        bWin = true
    else
        bWin = false
    end
end

function F_EndRaceProperlyNoBike(param)
    local win = false
    --print("[F_EndRaceProperlyNoBike] >> RUNNING")
    EndMission(param)
    bWin = false
    szFailReason = "RACING_L_NOBIKE"
end

function F_EndRaceProperlyTooFarBehind(param)
    local win = false
    --print("[F_EndRaceProperlyTooFarBehind] >> RUNNING")
    EndMission(param)
    bWin = false
    szFailReason = "RACE_TOOFAR"
end

function cbCritFail()
    if not bCritFail then
        SoundPlayMissionEndMusic(false, 8)
        MissionFail(true, true, "3_G3_FAILHIT")
        bCritFail = true
    end
end

function cbCritPlayer()
    shared.gPlayerIncapacitated = true
    TextPrintString("", 1, 1)
end
