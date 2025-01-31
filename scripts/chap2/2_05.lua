--[[ Changes to this file:
    * Modified function F_RussellCleanup, may require testing
    * Modified function MissionInit, may require testing
    * Modified function TadsGateOpened, may require testing
    * Modified function F_TadHasEmptyQs, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPlayer.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibTriggerNew.lua")
local MISSION_RUNNING = 0
local MISSION_PASS = 1
local MISSION_FAIL = 2
local MAX_RUSSELL_DISTANCE = 80
local gMissionState = MISSION_RUNNING
local tblPedModels = {
    31,
    30,
    35,
    32,
    34,
    40,
    33,
    75
}
local tblPickupModels = { 362 }
local tblVehicleModels = { 273 }
local tblWeaponModels = { 312 }
local gFailMessage
local RUSSELL_NONE = -1
local TAD_NONE = -1
local TAD_WAIT = 0
local TAD_CLOSEWINDOW = 1
local TAD_CLOSINGWINDOW = 2
local TAD_REINFORCEPHASE1 = 5
local TAD_REINFORCEPHASE2 = 6
local prepToPlayerAttitude, tblSpawnPatrol, bike01, rider01, bike02, rider02, gObjectiveBlip, gObjective
local gTadTauntInterval = 35000
local gTadReinforcementDelay = 1500
local bYardAccessed = false
local bShuttersCloseDone = false
local bTadReachedWindow = false
local bTadMonitorOn = false
local bBikesHandled = false
local bEnteredTadsYard = false
local bNewRoom = false
local bFirstWindowEgged = false
local bRussellCanInteract = true
local bPopHandled = false
local bStealthBreakHandle = false
local bEggCheckInterrupt = false
gRussell = {}
local tblTad = {}
local tblOutsidePatrol = {}
local tblRoom = {}
local gLiftCorona = {}
local gEggReserveCount = 2
local gEggPickup
local bRussellAllyEngage = false
local bManAimTutorial = true

function F_TableInit()
    local ax, ay, az = GetPointList(POINTLIST._2_05_LIFTSPOT)
    gLiftCorona = {
        x = ax,
        y = ay,
        z = az
    }
    tblTad = {
        model = 31,
        point = POINTLIST._2_05_TADSTART,
        wPoints = POINTLIST._2_05_TADWINDOWLOC,
        behavior = 0,
        roomsToInvestigate = {},
        patrolsToSend = {},
        shutWindow = "/Global/2_05/Animations/TadCloseShutters",
        mode = TAD_NONE
    }
    gRussell = {
        model = 75,
        point = POINTLIST._2_05_RUSSELL,
        mode = RUSSELL_NONE
    }
    tblOutsidePatrol = {
        {
            model = 34,
            point = POINTLIST._2_05_PATROLA,
            path = PATH._2_05_PATROLA,
            behavior = 1,
            followType = 2,
            pedSpeed = 0,
            gravity = true,
            patrolType = "initial",
            stealthCB = F_BreakStealth
        }
    }
    tblSpawnPatrol = {
        patrol1 = {
            model = 30,
            point = POINTLIST._2_05_FRONTDOOR,
            path = PATH._2_05_PATROL1,
            behavior = 1,
            followType = 2,
            pedSpeed = 1,
            gravity = true,
            stealthCB = F_BreakStealth,
            patrolType = "reinforcement",
            name = "Parker, PATH._2_05_PATROL1"
        },
        patrol2 = {
            model = 32,
            point = POINTLIST._2_05_FRONTDOOR,
            path = PATH._2_05_PATROL2,
            behavior = 1,
            followType = 2,
            pedSpeed = 1,
            gravity = true,
            stealthCB = F_BreakStealth,
            patrolType = "reinforcement",
            name = "Justin, PATH._2_05_PATROL2"
        },
        patrol3 = {
            model = 40,
            point = POINTLIST._2_05_FRONTDOOR,
            path = PATH._2_05_PATROL3,
            behavior = 1,
            followType = 2,
            pedSpeed = 1,
            gravity = true,
            stealthCB = F_BreakStealth,
            patrolType = "reinforcement",
            name = "Parker, PATH._2_05_PATROL3"
        },
        patrol4 = {
            model = 30,
            point = POINTLIST._2_05_BACKDOOR,
            path = PATH._2_05_PATROL4,
            behavior = 1,
            followType = 2,
            pedSpeed = 1,
            gravity = true,
            stealthCB = F_BreakStealth,
            patrolType = "reinforcement",
            name = "Chad, PATH._2_05_PATROL4"
        }
    }
    tblRoom = {
        {
            trigger = TRIGGER._2_05_ROOM1,
            window = {
                shutter = TRIGGER._TADSHUD,
                pathTo = PATH._2_05_TOWINDOW1,
                i = 1
            },
            projectile = 312,
            OnImpact = F_RoomEgged,
            sound = "Chrybmb_Exp",
            patrol = tblSpawnPatrol.patrol1,
            name = "TRIGGER._2_05_ROOM1"
        },
        {
            trigger = TRIGGER._2_05_ROOM2,
            window = {
                shutter = TRIGGER._TADSHUD01,
                pathTo = PATH._2_05_TOWINDOW2,
                i = 2
            },
            projectile = 312,
            OnImpact = F_RoomEgged,
            sound = "Chrybmb_Exp",
            patrol = tblSpawnPatrol.patrol2,
            name = "TRIGGER._2_05_ROOM2"
        },
        {
            trigger = TRIGGER._2_05_ROOM3,
            window = {
                shutter = TRIGGER._TADSHUD02,
                pathTo = PATH._2_05_TOWINDOW3,
                i = 3
            },
            projectile = 312,
            OnImpact = F_RoomEgged,
            sound = "Chrybmb_Exp",
            name = "TRIGGER._2_05_ROOM3"
        },
        {
            trigger = TRIGGER._2_05_ROOM4,
            window = {
                shutter = TRIGGER._TADSHUD03,
                pathTo = PATH._2_05_TOWINDOW4,
                i = 4
            },
            projectile = 312,
            OnImpact = F_RoomEgged,
            sound = "Chrybmb_Exp",
            patrol = tblSpawnPatrol.patrol3,
            name = "TRIGGER._2_05_ROOM4"
        },
        {
            trigger = TRIGGER._2_05_ROOM5,
            window = {
                shutter = TRIGGER._TADSHUD04,
                pathTo = PATH._2_05_TOWINDOW5,
                i = 5
            },
            projectile = 312,
            OnImpact = F_RoomEgged,
            sound = "Chrybmb_Exp",
            patrol = tblSpawnPatrol.patrol4,
            name = "TRIGGER._2_05_ROOM5"
        },
        {
            trigger = TRIGGER._2_05_ROOM6,
            window = {
                shutter = TRIGGER._TADSHUD05,
                pathTo = PATH._2_05_TOWINDOW6,
                i = 6
            },
            projectile = 312,
            OnImpact = F_RoomEgged,
            sound = "Chrybmb_Exp",
            name = "TRIGGER._2_05_ROOM6"
        }
    }
    MAX_ROOMS = table.getn(tblRoom)
    LoadModels(tblPedModels)
    LoadModels(tblPickupModels)
    LoadVehicleModels(tblVehicleModels)
    LoadWeaponModels(tblWeaponModels)
end

function F_UpdateObjectiveBlip(newBlip)
    if newBlip then
        F_CleanBlip(gObjectiveBlip)
        gObjectiveBlip = newBlip
    elseif gObjectiveBlip then
        gObjectiveBlip = F_CleanBlip(gObjectiveBlip)
    end
end

function F_CleanBlip(blip)
    if blip then
        BlipRemove(blip)
    end
    return nil
end

function F_TadShuttersBlipAll(roomTable, bBlip)
    if not roomTable then
        return
    end
    if bBlip then
        for _, room in roomTable do
            if not room.egged then
                room.window.shutterBlip = AddBlipForProp(room.window.shutter, 0, 1)
            end
        end
    else
        for _, room in roomTable do
            room.window.shutterBlip = F_CleanBlip(room.window.shutterBlip)
        end
    end
end

function F_BreakStealth(prep)
    local event = StealthLineForPrepModel(prep)
    if event then
        --print(">>>[RUI]", "!!F_BreakStealth custom speech")
        SoundPlayScriptedSpeechEvent(prep, "M_2_05", event, "large")
    else
        --print(">>>[RUI]", "!!F_BreakStealth standard speech")
        SoundPlayScriptedSpeechEvent(prep, "FIGHT_INITIATE", 0, "large")
    end
    --print(">>>[RUI]", "!!F_BreakStealth")
end

function StealthLineForPrepModel(prep)
    if PedIsModel(prep, 34) then
        return nil
    elseif PedIsModel(prep, 32) then
        return 21
    elseif PedIsModel(prep, 40) then
        return 19
    elseif PedIsModel(prep, 35) then
        return 600
    elseif PedIsModel(prep, 30) then
        return 18
    end
    return nil
end

function F_TadCloseWindow(window)
    --print(">>>[RUI]", "!!F_TadCloseWindow")
    PedStop(tblTad.id)
    Wait(250)
    if CounterGetCurrent() == MAX_ROOMS then
    else
        --print(">>>[RUI]", "Tad Speech M_2_05, 13")
        SoundPlayScriptedSpeechEvent(tblTad.id, "M_2_05", 13, "supersize")
    end
    PedSetActionNode(tblTad.id, tblTad.shutWindow, "Act/Conv/2_05.act")
    local startTime = GetTimer()
    while not bShuttersCloseDone do
        Wait(50)
        if GetTimer() - startTime > 1900 then
            F_ShuttersForceClosed(window.shutter)
            break
        end
    end
    bShuttersCloseDone = false
    --print(">>>[RUI]", "bShuttersCloseDone")
    Wait(200)
    PedSetPosPoint(tblTad.id, tblTad.point)
    PedStop(tblTad.id)
    PedClearObjectives(tblTad.id)
    window.shut = true
    --print(">>>[RUI]", "--F_TadCloseWindow")
end

function T_TadBehaviorMonitor()
    --print(">>>[RUI]", "++T_TadBehaviorMonitor")
    gTauntTimer = GetTimer()
    while gMissionState == MISSION_RUNNING and bTadMonitorOn do
        if tblTad then
            tblTad.roomToInvestigate = F_TadGetNextRoomToInvestigate()
            if tblTad.roomToInvestigate then
                --print(">>>[RUI]", "Investigating: " .. tblTad.roomToInvestigate.name)
                bNewRoom = false
                F_TadProcessRoom()
            else
                tblTad.patrolToSend = F_TadGetNextPatrolToSend()
                if tblTad.patrolToSend and not bNewRoom then
                    F_TadProcessReinforcement()
                else
                    F_TadProcessTaunts()
                end
            end
        end
        Wait(10)
    end
    --print(">>>[RUI]", "--T_TadBehaviorMonitor")
    collectgarbage()
end

function F_TadProcessRoom()
    --print(">>>[RUI]", "++F_TadProcessRoom")
    tblTad.mode = TAD_CLOSEWINDOW
    while tblTad.roomToInvestigate do
        if tblTad.mode == TAD_CLOSEWINDOW then
            if tblTad.roomToInvestigate then
                --print(">>>[RUI]", "Tad Speech M_2_05 11")
                SoundPlayScriptedSpeechEvent(tblTad.id, "M_2_05", 11, "supersize")
                CounterIncrementCurrent(1)
                tblTad.roomToInvestigate.window.shutterBlip = F_CleanBlip(tblTad.roomToInvestigate.window.shutterBlip)
                bTadReachedWindow = false
                PedSetPosPoint(tblTad.id, tblTad.wPoints, tblTad.roomToInvestigate.window.i)
                PedFollowPath(tblTad.id, tblTad.roomToInvestigate.window.pathTo, 0, 1, cbWindowEndPath)
                tblTad.mode = TAD_CLOSINGWINDOW
                --print(">>>[RUI]", "T_TadBehaviorMonitor: run to window")
            end
            Wait(1)
        elseif tblTad.mode == TAD_CLOSINGWINDOW then
            if bTadReachedWindow then
                bTadReachedWindow = false
                F_TadCloseWindow(tblTad.roomToInvestigate.window)
                tblTad.roomToInvestigate.egged = true
                tblTad.mode = TAD_NONE
                tblTad.roomToInvestigate = nil
                --print(">>>[RUI]", "T_TadBehaviorMonitor: closed shutter")
                Wait(1)
            end
            Wait(10)
        end
    end
    --print(">>>[RUI]", "--F_TadProcessRoom")
end

function F_TadProcessReinforcement()
    --print(">>>[RUI]", "++F_TadProcessReinforcement")
    tblTad.mode = TAD_REINFORCEPHASE1
    tblTad.reinforcementTime = GetTimer()
    while tblTad.patrolToSend do
        if tblTad.mode == TAD_REINFORCEPHASE1 then
            if GetTimer() - tblTad.reinforcementTime > gTadReinforcementDelay then
                --print(">>>[RUI]", "TAD yells for reinforcement")
                if table.getn(tblTad.patrolsToSend) == 0 then
                    --print(">>>[RUI]", "Tad speech M_2_05 12")
                    SoundPlayScriptedSpeechEvent(tblTad.id, "M_2_05", 12, "supersize")
                end
                tblTad.reinforcementTime = GetTimer()
                tblTad.mode = TAD_REINFORCEPHASE2
            end
        elseif tblTad.mode == TAD_REINFORCEPHASE2 and GetTimer() - tblTad.reinforcementTime > 1500 then
            tblTad.patrolToSend.id = PedCreatePoint(tblTad.patrolToSend.model, tblTad.patrolToSend.point)
            table.insert(tblOutsidePatrol, tblTad.patrolToSend)
            F_PatrolStart(tblTad.patrolToSend)
            tblTad.reinforcementTime = nil
            tblTad.mode = TAD_NONE
            tblTad.patrolToSend = nil
        end
        Wait(0)
    end
    --print(">>>[RUI]", "--F_TadProcessReinforcement")
end

function F_TadProcessTaunts()
    if not bFirstWindowEgged then
        return
    end
    gTauntTimer = GetTimer()
    while F_TadHasEmptyQs() do
        if GetTimer() - gTauntTimer > gTadTauntInterval then
            --print(">>>[RUI]", "TAd SpeechM_2_05 13")
            if F_PedExists(tblTad.id) then
                SoundPlayScriptedSpeechEvent(tblTad.id, "M_2_05", 13, "supersize")
            end
            gTauntTimer = GetTimer()
            tblTad.mode = TAD_WAIT
            Wait(1)
        end
        Wait(1)
    end
    --print(">>>[RUI]", "--F_TadProcessTaunts")
end

function F_ShuttersForceClosed(shutter)
    PedSetActionNode(tblTad.id, "/Global/2_05/Animations/TadCloseShutters/resetTad", "Act/Conv/2_05.act")
    PAnimSetActionNode(shutter, "/Global/TadShutters/Close_StayClosed", "Act/Props/tadshud.act")
    bShuttersCloseDone = true
    --print(">>>[RUI]", "!!F_ShuttersForceClosed!: " .. shutter)
end

function F_TadInvestigateRoom(newRoom)
    if newRoom then
        --print(">>>[JASON]", "F_TadInvestigateRoom queueing: " .. tostring(newRoom))
    else
        --print(">>>[JASON]", "F_TadInvestigateRoom *** NEW ROOM IS FALSE *** ")
    end
    table.insert(tblTad.roomsToInvestigate, newRoom)
    if tblTad.patrolsToSend then
        table.insert(tblTad.patrolsToSend, newRoom.patrol)
    end
    bNewRoom = true
end

function F_TadGetNextRoomToInvestigate()
    if table.getn(tblTad.roomsToInvestigate) == 0 then
        return nil
    end
    return table.remove(tblTad.roomsToInvestigate)
end

function F_TadGetNextPatrolToSend()
    if not tblTad.patrolsToSend then
        return nil
    end
    if table.getn(tblTad.patrolsToSend) == 0 then
        return nil
    end
    if bNewRoom then
        if tblTad.patrolToSend then
            return tblTad.patrolToSend
        else
            return nil
        end
    end
    if tblTad.patrolToSend then
        return tblTad.patrolToSend
    end
    return table.remove(tblTad.patrolsToSend)
end

function F_RoomEgged(room)
    if not room.egged and not room.hit then
        --print(">>>[RUI]", "!!F_RoomEgged for room: " .. tostring(room), "not egged")
        if not bFirstWindowEgged then
            bFirstWindowEgged = true
        end
        room.hit = true
        F_PlaySoundPoint(room.window.shutter, room.sound)
        F_TadInvestigateRoom(room)
    else
        --print(">>>[RUI]", "!!F_RoomEgged for room: " .. tostring(room), "previously egged: " .. tostring(room.egged) .. "  SKIPPED")
    end
end

function F_TadCreate()
    tblTad.id = PedCreatePoint(tblTad.model, tblTad.point)
    PedSetInvulnerable(tblTad.id, true)
    PedMakeTargetable(tblTad.id, false)
end

function F_RussellCreate()
    --print(">>>[RUI]", "++F_RussellCreate")
    gRussell.id = PedCreatePoint(gRussell.model, gRussell.point)
    PedSetHealth(gRussell.id, 800)
    PedFaceObject(gPlayer, gRussell.id, 2, 0)
    gRussellBike = VehicleCreatePoint(274, POINTLIST._2_05_RUSSELLBIKE)
    PedSetMissionCritical(gRussell.id, true, cbRussellAttacked, true)
    --print("RUSSEL NEW HEALTH", PedGetHealth(gRussell.id))
end

function F_RussellCleanup() -- ! Modified
    if F_PedExists(gRussell.id) then
        PedStop(gRussell.id)
        if VehicleIsValid(gRussellBike) then
            VehicleMakeAmbient(gRussellBike)
        end
        PedMakeAmbient(gRussell.id)
        --[[
        PedDismissAlly(gPlayer, gRussell.id)
        ]] -- Removed this
        F_CleanBlip(gRussell.blip)
    end
    --print(">>>[RUI]", "--F_RussellCleanup")
end

function F_HouseAllEgged()
    if not tblRoom then
        return nil
    end
    for i, room in tblRoom do
        if not room.egged then
            return false
        end
    end
    --print(">>>[RUI]", "!!F_HouseAllEgged true")
    return true
end

function cbRussellAttacked()
    --print(">>>[RUI]", "!!cbRussellAttacked")
    if bRussellHitMonitor then
        if PedGetWhoHitMeLast(gRussell.id) == gPlayer then
            --print(">>>[RUI]", "cbRussellAttacked hit by player")
            PedStop(gRussell.id)
            if PedIsInAnyVehicle(gRussell.id) then
                --print(">>>[RUI]", "get russell off bike")
                PedSetActionNode(gRussell.id, "/Global/2_05/Animations/RusellFallOffBike", "Act/Conv/2_05.act")
            end
            F_CleanBlip(gRussell.blip)
            gMissionState = MISSION_FAIL
            MissionStageRun = nil
            gFailMessage = "2_05_FAIL01"
        end
    elseif F_PedIsDead(gRussell.id) then
        gMissionState = MISSION_FAIL
        MissionStageRun = nil
        gFailMessage = "2_05_FAIL01"
    end
end

function F_PatrolStart(patrol)
    --print(">>>[RUI]", "!!F_PatrolStart  " .. patrol.patrolType .. " init")
    PedSetStealthBehavior(patrol.id, patrol.behavior, patrol.stealthCB, patrol.stealthCB)
    PedFollowPath(patrol.id, patrol.path, patrol.followType, patrol.pedSpeed)
    F_PedSetDropItem(patrol.id, 362, 40, 1)
    --print(">>>[RUI]", "!!F_PatrolStart  RAND: 40")
end

function F_EnemiesAllAggro()
    --print(">>>[RUI]", "!!F_EnemiesAllAggro")
    for _, guy in tblOutsidePatrol do
        if F_PedExists(guy.id) then
            PedSetIsStealthMissionPed(guy.id, false)
            PedClearObjectives(guy.id)
            PedClearTether(guy.id)
            PedSetStationary(guy.id, false)
            Wait(100)
            PedAttackPlayer(guy.id, 3)
            --print(">>>[RUI]", "++F_EnemiesAllAggro " .. _)
        else
            --print(">>>[RUI]", "--F_EnemiesAllAggro bad ped")
        end
    end
end

function F_BikeAttackCheck()
    if not bBikesHandled and not PlayerIsInTrigger(TRIGGER._2_05_TADSYARD) then
        --print(">>>[RUI]", "!!F_BikeAttackCheck")
        if PlayerIsInTrigger(TRIGGER._2_05_REAREXIT) then
            F_CreateRearAttack()
            bBikesHandled = true
        elseif PlayerIsInTrigger(TRIGGER._2_05_FRONTEXIT) then
            F_CreateFrontAttack()
            bBikesHandled = true
        elseif PlayerIsInTrigger(TRIGGER._2_05_TREE01) then
            F_CreateFrontAttack()
            bBikesHandled = true
        elseif PlayerIsInTrigger(TRIGGER._2_05_TREE02) then
            F_CreateFrontAttack()
            bBikesHandled = true
        elseif PlayerIsInTrigger(TRIGGER._2_05_WALLBREAK01) then
            F_CreateGardenAttack()
            bBikesHandled = true
        elseif PlayerIsInTrigger(TRIGGER._2_05_WALLBREAK02) then
            F_CreateGardenAttack()
            bBikesHandled = true
        end
    end
end

function F_CreateBikeAttacker(bikePt, model)
    local bike = VehicleCreatePoint(273, bikePt, 1)
    local rider = PedCreatePoint(model, bikePt, 2)
    local blip = AddBlipForChar(rider, 2, 26, 1)
    PedStop(rider)
    PedEnterVehicle(rider, bike)
    PedSetFocus(rider, gPlayer)
    --print(">>>[RUI]", "++F_CreateBikeAttacker")
    return bike, rider, blip
end

function F_CreateFrontAttack()
    bike01, rider01 = F_CreateBikeAttacker(POINTLIST._2_03_BIKE01, 35)
    bike02, rider02 = F_CreateBikeAttacker(POINTLIST._2_03_BIKE02, 33)
    Wait(500)
    PedAttackPlayer(rider01, 3)
    Wait(200)
    PedAttackPlayer(rider02, 3)
    --print(">>>[RUI]", "++F_CreateFrontAttack ]]")
end

function F_CreateRearAttack()
    bike01, rider01 = F_CreateBikeAttacker(POINTLIST._2_03_BIKEA01, 35)
    bike02, rider02 = F_CreateBikeAttacker(POINTLIST._2_03_BIKEA02, 33)
    Wait(500)
    PedAttackPlayer(rider01, 3)
    Wait(200)
    PedAttackPlayer(rider02, 3)
    --print(">>>[RUI]", "++F_CreateRearAttack ]]")
end

function F_CreateGardenAttack()
    bike01, rider01 = F_CreateBikeAttacker(POINTLIST._2_03_BIKEB01, 35)
    bike02, rider02 = F_CreateBikeAttacker(POINTLIST._2_03_BIKEB01, 33)
    Wait(500)
    PedAttackPlayer(rider01, 3)
    Wait(200)
    PedAttackPlayer(rider02, 3)
    --print(">>>[RUI]", "++F_CreateGardenAttack ]]")
end

function F_BikeAttackCleanup()
    if F_PedExists(rider01) then
        PedMakeAmbient(rider01)
        if bike01 and VehicleIsValid(bike01) then
            VehicleMakeAmbient(bike01)
        end
    end
    if F_PedExists(rider02) then
        PedMakeAmbient(rider02)
        if bike02 and VehicleIsValid(bike02) then
            VehicleMakeAmbient(bike02)
        end
    end
end

function F_CSInstructionNIS2()
    --print(">>>[RUI]", "!!F_CSInstructionNIS2")
    PlayerSetControl(0)
    CameraSetPath(PATH._2_05_INTRO, true)
    local x, y, z = GetPointList(POINTLIST._2_05_WINDOW1)
    CameraSetSpeed(3, 2, 2)
    CameraSetWidescreen(true)
    CameraLookAtXYZ(x, y, z - 3, true)
    gObjective = UpdateObjectiveLog("2_05_09", gObjective)
    Wait(1000)
    WaitSkippable(5000)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    PlayerSetControl(1)
    CreateThread("T_ManAimLoop")
end

local guy

function T_SpawnFinalGuys()
    --print(">>>[RUI]", "++T_SpawnFinalGuys")
    local finalSpawnModels = {
        { model = 33 },
        { model = 35 },
        { model = 30 }
    }
    for _, spawn in finalSpawnModels do
        guy = PedCreatePoint(spawn.model, POINTLIST._2_05_FRONTDOOR)
        table.insert(tblOutsidePatrol, { id = guy })
        PedFollowPath(guy, PATH._2_05_FIGHTPATH, 0, 1)
        while PedIsInTrigger(guy, TRIGGER._TADFRONTDOORR) do
            Wait(0)
        end
        Wait(80)
        if F_PedExists(guy) then
            PedAttackPlayer(guy, 3)
        end
        Wait(50)
    end
    --print(">>>[RUI]", "--T_SpawnFinalGuys")
    collectgarbage()
end

function F_RegisterTriggers(bOn)
    if bOn then
        CreateThread("T_TriggerMonitor")
        bThreadMonitoring = true
    else
        bThreadMonitoring = false
    end
end

local bYardTriggerHit = false

function T_TriggerMonitor()
    --print(">>>[RUI]", "++T_TriggerMonitor")
    while bThreadMonitoring do
        if not bThreadMonitoring then
            break
        end
        Wait(50)
        if bYardTriggerHit then
            if not PlayerIsInTrigger(TRIGGER._2_05_TADSYARD) then
                cbExitedTadsYard(TRIGGER._2_05_TADSYARD, gPlayer)
                bYardTriggerHit = false
            end
        elseif PlayerIsInTrigger(TRIGGER._2_05_TADSYARD) then
            cbEnteredTadsYard(TRIGGER._2_05_TADSYARD, gPlayer)
            bYardTriggerHit = true
        end
        if not bThreadMonitoring then
            break
        end
        Wait(50)
        if not bThreadMonitoring then
            break
        end
        Wait(50)
        if bEnteredTadsGates then
            if not PlayerIsInTrigger(TRIGGER._2_05_FRONTGATE) or not PlayerIsInTrigger(TRIGGER._2_05_BACKGATE) then
                cbExitTadsGates(TRIGGER._2_05_FRONTGATE, gPlayer)
            end
        elseif PlayerIsInTrigger(TRIGGER._2_05_FRONTGATE) or PlayerIsInTrigger(TRIGGER._2_05_BACKGATE) then
            cbEnterTadsGates(TRIGGER._2_05_FRONTGATE, gPlayer)
        end
        if not bThreadMonitoring then
            break
        end
        Wait(50)
    end
    --print(">>>[RUI]", "--T_TriggerMonitor")
    collectgarbage()
end

function T_StayInYard()
    Wait(5000)
    while gMissionState ~= MISSION_PASS do
        if ItemGetCurrentNum(312) > 0 and bEggStashMode and not PlayerIsInTrigger(TRIGGER._2_05_EGGSTASHAREA) then
            bEggStashMode = false
        end
        if not PlayerIsInTrigger(TRIGGER._2_05_TADSYARD) and CounterGetCurrent() ~= CounterGetMax() then
            if PlayerIsInTrigger(TRIGGER._2_05_EGGSTASHAREA) then
                if not bEggStashMode then
                    TextPrint("2_05_61", 0.5, 1)
                end
            elseif bEggStashMode then
                TextPrint("2_05_64", 0.5, 1)
            else
                TextPrint("2_05_61", 0.5, 1)
            end
            if not PlayerIsInTrigger(TRIGGER._2_05_TADSBLOCK) or PlayerIsInTrigger(TRIGGER._2_05_TREE02) or PlayerIsInTrigger(TRIGGER._2_05_TREE01) then
                gFailMessage = "2_05_62"
                Wait(3000)
                gMissionState = MISSION_FAIL
            end
        end
        Wait(0)
    end
end

function F_CleanupEnemies()
    for _, guy in tblOutsidePatrol do
        if F_PedExists(guy.id) then
            PedMakeAmbient(guy.id)
        end
    end
    --print(">>>[RUI]", "--F_CleanupEnemies")
end

function F_PlaySoundPoint(trigger, szSound)
    local x, y, z = GetAnchorPosition(trigger)
    SoundPlay3D(x, y, z, szSound)
    SoundPlay3D(x, y, z, "ToiletExp")
end

function cbEnterTadsGates(trigger, ped)
    if ped == gPlayer then
        bEnteredTadsGates = true
    end
end

function cbExitTadsGates(trigger, ped)
    if ped == gPlayer then
        bEnteredTadsGates = false
    end
end

function cbEnteredTadsYard(trigger, ped)
    if ped == gPlayer then
        bEnteredTadsYard = true
        --print(">>>[RUI]", "cbEnteredTadsYard")
    end
end

function cbExitedTadsYard(trigger, ped)
    if ped == gPlayer then
        bEnteredTadsYard = false
        --print(">>>[RUI]", "cbExitedTadsYard")
    end
end

function cbWindowEndPath(pedId, pathId, pathNode)
    if not tblTad.roomToInvestigate then
        return
    end
    if pedId == tblTad.id and pathNode == PathGetLastNode(tblTad.roomToInvestigate.window.pathTo) then
        bTadReachedWindow = true
        --print(">>>[RUI]", "!!cbWindowEndPath")
    end
end

function F_ShuttersCloseDone()
    bShuttersCloseDone = true
end

function F_PlayerAtGates()
    return bEnteredTadsGates
end

function MissionInit() -- ! Modified
    PlayerSetControl(0)
    PlayCutsceneWithLoad("2-05", true, true)
    WeaponRequestModel(312)
    --PlayerSetWeapon(312, 12)
    PlayerSetPosPoint(POINTLIST._2_05_PLAYERSTART, 1)
    F_TableInit()
    F_RussellCreate()
    CreateThread("T_RussellBikeMonitor")
    PlayerSetControl(0)
    F_RussellGetOnBike()
    bRussellHitMonitor = true
    LoadModels({
        31,
        75,
        34,
        274,
        362,
        273,
        35,
        33,
        30
    })
    prepToPlayerAttitude = PedGetTypeToTypeAttitude(5, 13)
    CameraFade(FADE_IN_TIME, 1)
    Wait(FADE_IN_TIME)
end

function MissionSetup()
    MissionDontFadeIn()
    SoundStopInteractiveStream()
    DATLoad("2_05_new.DAT", 2)
    DATInit()
    LoadAnimationGroup("2_05TadsHouse")
    LoadActionTree("Act/Conv/2_05.act")
end

function F_RussellGetOnBike()
    --print(">>>[RUI]", "!!F_RussellGetOnBike")
    gRussell.blip = AddBlipForChar(gRussell.id, 0, 27, 4)
    PedStop(gRussell.id)
    PedPutOnBike(gRussell.id, gRussellBike)
    while not PedIsInAnyVehicle(gRussell.id) do
        Wait(0)
    end
    --print(">>>[RUI]", "--F_RussellGetOnBike")
end

function T_RussellBikeMonitor()
    --print(">>>[RUI]", "++T_RussellBikeMonitor")
    while not bRussellHitMonitor do
        if not MissionActive() then
            break
        end
        Wait(0)
    end
    while gMissionState == MISSION_RUNNING do
        if DistanceBetweenPeds3D(gPlayer, gRussell.id) >= MAX_RUSSELL_DISTANCE then
            PedStop(gRussell.id)
            if PedIsInAnyVehicle(gRussell.id) then
                local aBike = VehicleFromDriver(gRussell.id)
                PedWarpOutOfCar(gRussell.id)
                if aBike == gRussellBike and not PlayerIsInVehicle(gRussellBike) then
                    VehicleDelete(gRussellBike)
                    gRussellBike = VehicleCreatePoint(274, POINTLIST._2_05_RUSSELLBIKE, 2)
                end
                VehicleSetPosPoint(gRussellBike, POINTLIST._2_05_RUSSELLBIKE, 2)
            end
            PedSetPosPoint(gRussell.id, POINTLIST._2_05_RUSSELLWAITSPOT, 1)
            bRussellDoneOffBike = true
            --print(">>>[RUI]", "T_RussellBikeMonitor WARP RUSSELL")
            break
        elseif not PedIsInVehicle(gRussell.id, gRussellBike) or PedIsInVehicle(gPlayer, gRussellBike) then
            gMissionState = MISSION_FAIL
            MissionStageRun = nil
            gFailMessage = "2_05_FAIL01"
            --print(">>>[RUI]", "T_RussellBikeMonitor russell attacked")
            break
        elseif PedIsInTrigger(gRussell.id, TRIGGER._2_05_RUSSELLOFFBIKE) or bRussellMakeAlly then
            VehicleStop(gRussellBike)
            PedClearFocus(gRussell.id)
            PedStop(gRussell.id)
            PedExitVehicle(gRussell.id)
            --print(">>>[RUI]", "TRussellBikeMonitor take him off bike")
            while PedIsInAnyVehicle(gRussell.id) do
                PedExitVehicle(gRussell.id)
                Wait(10)
            end
            PedMoveToPoint(gRussell.id, 1, POINTLIST._2_05_RUSSELLWAITSPOT, 1)
            --print(">>>[RUI]", "TRussellBikeMonitor OFF BIKE")
            bRussellDoneOffBike = true
            break
        end
        Wait(100)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_RussellBikeMonitor")
end

function T_MakeRussellAlly()
    --print(">>>[RUI]", "++T_MakeRusselAlly")
    while gMissionState == MISSION_RUNNING do
        if PlayerIsInTrigger(TRIGGER._2_05_RECRUITRUSSELL) or PlayerIsInTrigger(TRIGGER._2_05_TADSYARD) then
            --print(">>>[RUI]", "!!RussellMakeAlly")
            bRussellMakeAlly = true
            --print(">>>[RUI]", "T_MakeRusselAlly wait for Russell off the bike")
            while not bRussellDoneOffBike do
                Wait(10)
            end
            PedStop(gRussell.id)
            Wait(250)
            --print(">>>[RUI]", "T_MakeRusselAlly OFF BIKE")
            PedRecruitAlly(gPlayer, gRussell.id)
            BlipRemove(gRussell.blip)
            gRussell.blip = AddBlipForChar(gRussell.id, 0, 27, 1)
            PedSetAllyJump(gRussell.id, true)
            break
        end
        Wait(100)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_MakeRusselAlly")
end

function main()
    MissionInit()
    gMissionState = MISSION_RUNNING
    MissionStageRun = Stage_01GoToHouseInit
    while gMissionState == MISSION_RUNNING do
        if MissionStageRun then
            MissionStageRun()
        end
        Wait(10)
    end
    if gMissionState == MISSION_PASS then
        CameraSetWidescreen(true)
        SetFactionRespect(5, 0)
        TextPrintString("", 1, 1)
        MinigameSetCompletion("M_PASS", true, 1500)
        MinigameAddCompletionMsg("MRESPECT_PM15", 1)
        SoundPlayMissionEndMusic(true, 10)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        bManAimTutorial = false
        MissionSucceed(false, false, false)
    else
        SoundPlayMissionEndMusic(false, 10)
        bManAimTutorial = false
        if gFailMessage then
            MissionFail(false, true, gFailMessage)
        else
            MissionFail(false)
        end
    end
end

function MissionCleanup()
    CameraSetWidescreen(false)
    SoundStopInteractiveStream()
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    PedResetTypeAttitudesToDefault()
    RadarRestoreMinMax()
    CounterSetup(false)
    ToggleHUDComponentVisibility(8, false)
    POIGroupsEnabled(true)
    POISetSystemEnabled(true)
    F_RussellCleanup()
    F_UpdateObjectiveBlip(nil)
    F_RegisterTriggers(false)
    F_CleanupEnemies()
    F_BikeAttackCleanup()
    F_TadShuttersBlipAll(tblRoom, false)
    F_TadCleanup()
    if gMissionState == MISSION_PASS then
        --print("IS IT STARTING TO SNOW???")
        F_RainBeGone()
    end
    UnLoadAnimationGroup("2_05TadsHouse")
    DATUnload(2)
    --print(">>>[RUI]", "--MissionCleanup")
end

function Stage_01GoToHouseInit()
    --print(">>>[RUI]", "Stage_01GoToHouseInit")
    F_RussellRideBike()
    PlayerSetControl(1)
    CreateThread("T_MakeRussellAlly")
    GiveWeaponToPlayer(312)
    GiveAmmoToPlayer(312, 24)
    gObjective = UpdateObjectiveLog("2_05_29", gObjective)
    local blip = BlipAddPoint(POINTLIST._2_05_GATECORONA, 0, 2)
    F_UpdateObjectiveBlip(blip)
    --print(">>>[RUI]", "Goto Stage_01GoToHouseLoop")
    MissionStageRun = Stage_01GoToHouseLoop
end

function F_RussellRideBike()
    --print(">>>[RUI]", "!!F_RussellRideBike")
    PedOverrideStat(gRussell.id, 37, 100)
    PedOverrideStat(gRussell.id, 24, 60)
    PedOverrideStat(gRussell.id, 35, 63)
    PedOverrideStat(gRussell.id, 26, 55)
    PedOverrideStat(gRussell.id, 28, 1.0E-4)
    PedOverrideStat(gRussell.id, 27, 10)
    PedOverrideStat(gRussell.id, 29, 20)
    PedSetFocus(gRussell.id, gPlayer)
    PedFleeOnPathOnBike(gRussell.id, PATH._2_05_RUSSELBIKEPATH, 0)
end

function Stage_01GoToHouseLoop()
    if PlayerIsInTrigger(TRIGGER._AMB_RICH_AREA) then
        --print(">>>[RUI]", "goto Stage_02GetInYardInit")
        MissionStageRun = Stage_02GetInYardInit
    end
    Wait(100)
end

function T_ManAimLoop()
    local bTutorialStarted = false
    while bManAimTutorial do
        if PlayerIsInTrigger(TRIGGER._2_05_TADSYARD) then
            --print("Player is in trigger.")
            if not bTutorialStarted then
                --print("Start the tutorial")
                TutorialStart("MANAIMREMX")
                bTutorialStarted = true
            end
        else
            --print("Player left the trigger.")
            if bTutorialStarted then
                --print("Tutorial reset")
                bTutorialStarted = false
            end
        end
        Wait(100)
    end
    collectgarbage()
end

function Stage_02GetInYardInit()
    --print(">>>[RUI]", "Stage_02GetInYardInit")
    F_RegisterTriggers(true)
    AreaOverridePopulation(2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0)
    POIGroupsEnabled(false)
    POISetSystemEnabled(false)
    VehicleOverrideAmbient(3, 0, 2, 1)
    bPopHandled = true
    --print(">>>[RUI]", "Drop Population")
    --print(">>>[RUI]", "Goto Stage_02GetInYardLoop")
    MissionStageRun = Stage_02GetInYardLoop
end

function Stage_02GetInYardLoop()
    local x, y, z = GetPointList(POINTLIST._2_05_GATECORONA)
    if TadsGateOpened() then
        --print(">>>[RUI]", "goto Stage_03EggHouseInit")
        MissionStageRun = Stage_03EggHouseInit
    end
    Wait(1)
end

function TadsGateOpened() -- ! Modified
    --[[
    return not (PlayerIsInTrigger(TRIGGER._2_05_FRONTGATE) or PlayerIsInTrigger(TRIGGER._2_05_BACKGATE)) or PAnimIsOpen(TRIGGER._TRICH_TADGATES) or PAnimIsOpen(TRIGGER._TRICH_TADGATES01)
    ]] -- Changed to:
    return (PlayerIsInTrigger(TRIGGER._2_05_FRONTGATE) or PlayerIsInTrigger(TRIGGER._2_05_BACKGATE)) and (PAnimIsOpen(TRIGGER._TRICH_TADGATES) or PAnimIsOpen(TRIGGER._TRICH_TADGATES01))
end

function CounterSetup(bOn, countMax)
    if bOn then
        CounterSetIcon("WindowEgg", "WindowEgg_x")
        CounterSetCurrent(0)
        CounterSetMax(countMax)
        CounterMakeHUDVisible(true)
        --print(">>>[RUI]", "CounterSetup ON")
    else
        CounterMakeHUDVisible(false)
        CounterSetMax(0)
        CounterSetCurrent(0)
        CounterClearIcon()
        --print(">>>[RUI]", "CounterSetup OFF")
    end
end

function Stage_03EggHouseInit()
    --print(">>>[RUI]", "Stage_03EggHouseInit")
    bRussellHitMonitor = false
    if not F_PedIsDead(gRussell.id) then
        --print(">>>[RUI]", "Turn Russell Tether off, set him to 1st class Ally")
        PedSetMissionCritical(gRussell.id, false)
    else
        gMissionState = MISSION_FAIL
        MissionStageRun = nil
        gFailMessage = "2_05_FAIL01"
    end
    SoundStopInteractiveStream()
    SoundPlayInteractiveStream("MS_FightingPrepsLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_FightingPreps.rsm", MUSIC_DEFAULT_VOLUME)
    bRussellCanInteract = false
    bYardTriggerHit = true
    Wait(250)
    F_CSInstructionNIS2()
    CreateThread("T_StayInYard")
    CreateThread("T_MonitorEggCount")
    L_PedLoadPoint("outsidePatrol", tblOutsidePatrol)
    L_PedExec("outsidePatrol", F_PatrolStart, "element")
    F_TadShuttersBlipAll(tblRoom, true)
    F_TadCreate()
    bTadMonitorOn = true
    CreateThread("T_TadBehaviorMonitor")
    RadarSetMinMax(30, 30, 30)
    L_AddTrigger("room", tblRoom)
    CounterSetup(true, MAX_ROOMS)
    bYardAccessed = true
    F_UpdateObjectiveBlip(nil)
    bEggCheckReset = true
    --print("-->>>[RUI]", "goto Stage_03EggHouseLoop")
    MissionStageRun = Stage_03EggHouseLoop
end

function Stage_03EggHouseLoop()
    if F_HouseAllEgged() then
        --print(">>>[RUI]", "Goto Stage_04LeaveYardInit")
        bEggCheckInterrupt = true
        gMissionState = MISSION_RUNNING
        MissionStageRun = Stage_04LeaveYardInit
        return
    end
    F_MonitorTriggers()
    if gMissionState == MISSION_FAIL then
        MissionStageRun = nil
    end
end

function T_MonitorEggCount()
    local eggsBlip = -1
    local eggsCreated = false
    while not bEggCheckInterrupt and gMissionState == MISSION_RUNNING do
        if CounterGetCurrent() == CounterGetMax() - 1 and ItemGetCurrentNum(312) == 1 then
            Wait(6500)
        end
        if ItemGetCurrentNum(312) == 0 and not eggsCreated then
            if gEggReserveCount == 0 and not eggsCreated then
                gFailMessage = "2_05_02"
                bEggCheckReset = false
                gMissionState = MISSION_FAIL
            elseif not eggsCreated then
                gEggPickup = PickupCreatePoint(312, POINTLIST._2_05_LIFTSPOT, 1, 0, "EggsBute")
                F_TadShuttersBlipAll(tblRoom, false)
                eggsBlip = BlipAddPoint(POINTLIST._2_05_LIFTSPOT, 0, 1)
                MissionObjectiveRemove(gObjective)
                gObjective = UpdateObjectiveLog("2_05_64", nil)
                gEggReserveCount = gEggReserveCount - 1
                --print(">>>[JASON]", "Created Eggs. Stash Remaining: " .. gEggReserveCount)
                eggsCreated = true
                bEggStashMode = true
            end
        elseif eggsCreated and (PickupIsPickedUp(gEggPickup) or ItemGetCurrentNum(312) > 0) then
            --print(">>>[JASON]", "Eggs are picked...")
            BlipRemove(eggsBlip)
            eggsBlip = nil
            gEggPickup = nil
            MissionObjectiveRemove(gObjective)
            gObjective = UpdateObjectiveLog("2_05_09", nil)
            F_TadShuttersBlipAll(tblRoom, false)
            F_TadShuttersBlipAll(tblRoom, true)
            eggsCreated = false
        end
        Wait(0)
    end
    collectgarbage()
    --print("EXITING T_MONITOREGGCOUNT")
end

function F_TadCleanup()
    if F_PedExists(tblTad.id) then
        PedDelete(tblTad.id)
    end
    bTadMonitorOn = false
end

function Stage_04LeaveYardInit()
    --print(">>>[RUI]", "Stage_04LeaveYardInit")
    CounterSetup(false)
    PedSetTypeToTypeAttitude(5, 13, 0)
    Wait(2000)
    PedSetPedToTypeAttitude(gRussell.id, 5, 0)
    PedMoveToPoint(gRussell.id, 2, POINTLIST._2_05_PATROL_B, 1)
    bRussellAllyEngage = true
    --print(">>>[RUI]", "Tad Speech M_2_05 22")
    SoundPlayScriptedSpeechEvent(tblTad.id, "M_2_05", 22, "supersize")
    Wait(1000)
    gObjective = UpdateObjectiveLog("2_05_56", gObjective)
    CreateThread("T_SpawnFinalGuys")
    F_TadCleanup()
    F_EnemiesAllAggro()
    F_UpdateObjectiveBlip(blip)
    --print(">>>[RUI]", "Goto Stage_04LeaveYardLoop")
    MissionStageRun = Stage_04LeaveYardLoop
end

function Stage_04LeaveYardLoop()
    F_MonitorTriggers()
    if not PlayerIsInTrigger(TRIGGER._2_05_TADSYARD) then
        --print(">>>[RUI]", "GAME OVER")
        gMissionState = MISSION_PASS
    end
    Wait(100)
end

function F_TadHasEmptyQs() -- ! Modified
    --return table.getn(tblTad.roomsToInvestigate) == 0 and table.getn(tblTad.patrolsToSend) == 0
    return table.getn(tblTad.roomsToInvestigate) == 0
end

function UpdateObjectiveLog(newObjStr, oldObj)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr)
        TextPrint(newObjStr, 6, 1)
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end
