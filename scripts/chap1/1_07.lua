ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibSchool.lua")
local idAlgernon, Peanut
local Peanut = {}
local Nemesis, idHitMan, id2ndMan, idPopDropper
local bPopDropper = false
local bGateLoaded = false
local bMovedBucky = false
local bDoorZoneOccupied = false
local bDoorOpen = false
local tblGreaserModels01 = {
    102,
    99,
    85
}
local tblGreaserModels02 = {
    145,
    146,
    147
}
local Uniqueness
local tblWeapons = {}
local Peanut = {
    spawn = POINTLIST._1_07_PEANUT_SPAWN,
    model = 21,
    path1 = PATH._1_07_PEANUT_COMES,
    path2 = PATH._1_07_PEANUT_GOES
}
local REACH_BUCKY_TIME = 90000
local BUCKY_DEFAULT_HEALTH = 300
local Bucky_Current_Health = 1000
local Time_To_Get_To_Bucky, Start_Timer_Time, Current_Timer_Time, Last_Timer_Time
local TotalSpawn = 0
local x1, y1, x1, idBucky, idBuckyBlip
local nSpawner, nSpawner2, nSpawner3 = 0, 0, 0
local timer_running = false
local mission_started = false
local intro_finished = false
local debug_finished = false
local bGateCreated = false
local bGateOpen = false
local gGuysBeat = false
local bBulliesAttack = false
local group1 = "greaserOne"
local group2 = "greaserTwo"
local group3 = "greaserTwo"
local gObjectives = {}
local gObjectiveBlip, gLastPath
local gDebugging = false
local bBuckyCower = false
local bSendBuckyOffAgain = false
local gBuckysPreviousHealth = 0
local bMissionSuccess = false
local bBullyDialogue = false
local nWaveBeat = 0
local bDoorOpened = false
local bDoorsMade = false
local gGateBully01, gGateBully02
local bSecondBulliesAttacked = false
local bBuckyHiding = false
local bPlayerReachedGate = false
local gCurrentBully01, gCurrentBully02
local bGatesClosed = false
local gMonitorThread
local bBuckyDied = false
local bGroup1Created = false
local bGroup2Created = false
local bGroup3Created = false
local gSktModl, gSktGeo

function F_SetupNISOne()
    gDebugging = true
    AreaTransitionPoint(0, POINTLIST._1_07_PEND, 1)
    idBucky = PedCreatePoint(8, POINTLIST._1_07_BUCKY_PEANUTCUT, 2)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    F_Peanut_Confontation()
    F_BuckyThanksThePlayer()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_FailMission()
    if timer_running then
        timer_running = false
    end
    SoundPlayMissionEndMusic(false, 10)
    if idBucky and PedIsValid(idBucky) and (PedGetHealth(idBucky) <= 0 or Bucky_Current_Health <= 0) then
        bBuckyDied = true
        if bGatesClosed then
            F_BuckWasKnockedOutNIS()
            CameraReturnToPlayer()
        else
            PedSetActionNode(idBucky, "/Global/1_07/KO_COLLAPSE", "Act/Conv/1_07.act")
            CameraSetWidescreen(true)
            MinigameSetCompletion("M_FAIL", false, 0, "1_07_BUCKYKO")
            SoundPlayMissionEndMusic(false, 10)
        end
        MissionFail(true, false)
    end
end

function F_CompleteMission()
    local skip = false
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    SoundDisableSpeech_ActionTree()
    AreaClearAllPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    F_Peanut_Confontation()
    F_BuckyThanksThePlayer()
    CameraFade(500, 0)
    Wait(501)
    PedDelete(Bum)
    PedSetActionNode(gPlayer, "/Global/1_07/Idle", "Act/Conv/1_07.act")
    Wait(100)
    if bGateCreated then
        PAnimDelete(TRIGGER._1_07_GATE_T)
        bGateCreated = false
    end
    PedSetStationary(idBucky, false)
    SoundRemoveAllQueuedSpeech(idBucky)
    PlayerSetPosSimple(157, 6.6, 6.4)
    PedLockTarget(gPlayer, idBucky, 3)
    PedFaceHeading(gPlayer, 180, 0)
    PedStop(idBucky)
    PedSetActionNode(gPlayer, "/Global/Give1_07/Give_Attempt", "Act/Gifts/Give107.act")
    CameraSetFOV(70)
    CameraSetXYZ(157.37164, 2.227986, 7.2235, 156.39996, 1.993942, 7.198375)
    CameraFade(500, 1)
    Wait(501)
    SoundPlayScriptedSpeechEvent(idBucky, "THANKS_JIMMY", 0, "xtralarge")
    while PedIsPlaying(gPlayer, "/Global/Give1_07/Give_Attempt", true) do
        Wait(0)
    end
    AreaSetDoorPathableToPeds(TRIGGER._1_07_GATE_T, true)
    SetFactionRespect(11, 0)
    SetFactionRespect(1, 65)
    PedSetActionNode(idBucky, "/Global/1_07/Blank", "Act/Conv/1_07.act")
    PedStop(idBucky)
    PedStop(gPlayer)
    PedClearObjectives(idBucky)
    PedClearObjectives(gPlayer)
    PedStopSocializing(idBucky)
    PedStopSocializing(gPlayer)
    PedMoveToPoint(idBucky, 0, POINTLIST._1_07_BULLYENDDEST, 2)
    bMissionSuccess = true
    PedSetWeaponNow(gPlayer, 437, -1, false)
    CameraSetFOV(30)
    PlayerFaceHeadingNow(270)
    CameraSetXYZ(160.10028, 7.250284, 7.124797, 159.12938, 7.059014, 7.268433)
    PedSetActionNode(gPlayer, "/Global/1_07/SK8_Examine", "Act/Conv/1_07.act")
    SoundStopInteractiveStream()
    MinigameSetCompletion("M_PASS", true, 0, "1_07_UNLOCK")
    SoundPlayMissionEndMusic(true, 10)
    MinigameAddCompletionMsg("MRESPECT_NP5", 2)
    MinigameAddCompletionMsg("MRESPECT_BM10", 1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(501)
    PedSetActionNode(gPlayer, "/Global/1_07/Blank", "Act/Conv/1_07.act")
    CameraReset()
    CameraReturnToPlayer()
    if idBucky ~= nil then
        PedDelete(idBucky)
        idBucky = nil
    end
    SoundEnableSpeech_ActionTree()
    MissionSucceed(false, false, false)
    Wait(500)
    CameraFade(500, 1)
    Wait(101)
    PlayerSetControl(1)
end

function T_ManageDoors()
    while true do
        if AreaGetVisible() == 0 then
            if not bGateOpen then
                PAnimSetActionNode(TRIGGER._1_07_GATE_T, "/Global/1_07/OpenGate", "Act/Conv/1_07.act")
                bGateOpen = true
            end
        elseif bGateOpen then
            bGateOpen = false
        end
        Wait(0)
    end
end

function F_AskForHelp()
    if idHitMan and not PedIsDead(idHitMan) then
        PedFaceObject(idHitMan, idBucky, 2, 1)
    end
    if id2ndMan and not PedIsDead(id2ndMan) then
        PedFaceObject(id2ndMan, idBucky, 2, 1)
        PedSetActionNode(id2ndMan, "/Global/1_07/DontMess", "Act/Conv/1_07.act")
        SoundPlayScriptedSpeechEvent(id2ndMan, "M_1_07", 3, "xtralarge")
        while PedIsPlaying(id2ndMan, "/Global/1_07/DontMess", false) do
            Wait(0)
        end
    end
    if idHitMan and not PedIsDead(idHitMan) and id2ndMan and not PedIsDead(id2ndMan) then
        L_PedExec(group1, PedClearObjectives, "id")
        L_PedExec(group1, PedStopSocializing, "id")
        L_PedExec(group1, PedLockTarget, "id", idBucky, 1)
        L_PedExec(group1, PedSetAsleep, "id", false)
        L_PedExec(group1, PedAttack, "id", idBucky, 1)
        L_PedExec(group1, PedAttack, "id", gPlayer, 1)
    end
    PedSetStationary(idBucky, false)
    if idHitMan and not PedIsDead(idHitMan) then
        PedFaceObject(idHitMan, gPlayer, 3, 1)
        Wait(100)
    end
    if id2ndMan and not PedIsDead(id2ndMan) then
        while SoundSpeechPlaying(id2ndMan) do
            Wait(0)
        end
    end
    if idHitMan and not PedIsDead(idHitMan) then
        PedSetActionNode(idHitMan, "/Global/1_07/GoingDown", "Act/Conv/1_07.act")
        SoundPlayScriptedSpeechEvent(idHitMan, "M_1_07", 17, "large")
    end
    gMonitorThread = CreateThread("T_MonitorGreasers")
    gBuckysPreviousHealth = PedGetHealth(idBucky)
end

function F_Peanut_Confontation()
    CameraFade(500, 0)
    Wait(501)
    LoadAnimationGroup("NIS_1_07")
    GiveWeaponToPlayer(437, false)
    TextPrintString("", 1, 1)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    if PedIsOnVehicle(gPlayer) then
        PlayerDetachFromVehicle()
    end
    AreaClearAllPeds()
    AreaClearAllVehicles()
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PedDismissAlly(gPlayer, idBucky)
    PedClearTether(idBucky)
    PedClearObjectives(idBucky)
    PedSetActionNode(idBucky, "/Global/1_07/Break", "Act/Conv/1_07.act")
    PlayerSetPosPoint(POINTLIST._1_07_PLYRDOOR, 1)
    PedStop(idBucky)
    PedSetPosPoint(idBucky, POINTLIST._1_07_PLYRDOOR, 2)
    while not PedIsPlaying(gPlayer, "/Global/1_07/FakeTry/startOpen", true) do
        Wait(1)
        PedSetActionNode(gPlayer, "/Global/1_07/FakeTry/startOpen", "Act/Conv/1_07.act")
    end
    PedSetActionNode(idBucky, "/Global/1_07/Idle", "Act/Conv/1_07.act")
    if gSktModl ~= nil and gSktGeo ~= nil then
        DeletePersistentEntity(gSktModl, gSktGeo)
        gSktModl = nil
        gSktGeo = nil
    end
    CameraSetFOV(30)
    CameraSetXYZ(155.2142, 4.66866, 7.610484, 156.08488, 5.150542, 7.707921)
    CameraFade(500, 1)
    peanuttimer = GetTimer() + 5000
    PedFaceObject(idBucky, gPlayer, 3, 1)
    Bum = PedCreatePoint(87, POINTLIST._1_07_BUM)
    SoundPlayScriptedSpeechEvent(Bum, "M_1_07", 28, "large")
    Wait(3500)
end

function F_BuckyThanksThePlayer()
    AreaClearAllPeds()
    shared.gCheckHoboDoors = false
    AreaSetDoorPathableToPeds(TRIGGER._1_07_GATE_T, true)
    AreaSetDoorPathableToPeds(TRIGGER._BUSDOORS, true)
    PAnimOpenDoor(TRIGGER._BUSDOORS)
    PedSetActionNode(Bum, "/Global/1_07/POpenSide/PedPropActions/startOpen", "Act/Conv/1_07.act")
    PAnimSetActionNode(TRIGGER._1_07_GATE_T, "/Global/1_07/POpenSide/Gate/startOpen", "Act/Conv/1_07.act")
    PedFaceObject(gPlayer, Bum, 2, 0)
    PedFaceObject(idBucky, Bum, 2, 0)
    bSkip = Wait(50)
    PedSetActionNode(gPlayer, "/Global/1_07/BackUp", "Act/Conv/1_07.act")
    PedSetActionNode(idBucky, "/Global/1_07/CowerOneFrame", "Act/Conv/1_07.act")
    while SoundSpeechPlaying(Bum) do
        Wait(1)
    end
    PedSetActionNode(Bum, "/Global/1_07/HoboOpenGate", "Act/Conv/1_07.act")
    Wait(2900)
    PedFollowPath(Bum, PATH._1_07_TOBUSPATH, 0, 0)
    Wait(500)
    CameraSetFOV(30)
    PedSetActionNode(gPlayer, "/Global/1_07/JimmyTalk02", "Act/Conv/1_07.act")
    SoundPlayScriptedSpeechEvent(gPlayer, "M_1_07", 26, "large")
    Wait(2000)
    PedMoveToPoint(idBucky, 0, POINTLIST._1_07_NIS_SK8PASS, 2)
    PedFollowPath(Bum, PATH._1_07_TOBUSPATH, 0, 0)
    while SoundSpeechPlaying(gPlayer) do
        Wait(1)
    end
    UnLoadAnimationGroup("NIS_1_07")
end

function F_ReachedBucky()
    if gDebugging then
        return false
    end
    if not bBulliesAttack and PlayerIsInTrigger(TRIGGER._1_07_GATE_T) then
        PedAttack(idHitMan, idBucky, 1)
        PedAttack(id2ndMan, idBucky, 1)
        bBulliesAttack = true
    end
    if PlayerIsInTrigger(TRIGGER._1_07_GATETRIG) or PlayerIsInTrigger(TRIGGER._1_07_FIGHTTRIGGER) then
        --print("PLAYER IS IN THE TRIGGERS!!")
        --print("CREATE THE BULLIES!!!")
        bGatesClosed = true
        return true
    end
    return false
end

function F_RunningToBucky()
    Current_Timer_Time = GetTimer()
    if not bBulliesAttack then
        if Current_Timer_Time >= Start_Timer_Time + Last_Timer_Time + 5000 then
            Bucky_Current_Health = PedGetHealth(idBucky)
            if Bucky_Current_Health <= 0 and not gDebugging then
                BuckyKOMessage()
                F_FailMission()
            else
                local Half_Time_Health = 400 / 2
                local Half_Time_Health_Tick = Half_Time_Health / 8
                if gDebugging then
                    PedSetHealth(idBucky, 1000)
                else
                    PedSetHealth(idBucky, Bucky_Current_Health - Half_Time_Health_Tick)
                    Last_Timer_Time = Last_Timer_Time + 5000
                end
            end
        end
    else
        Bucky_Current_Health = PedGetHealth(idBucky)
        if Bucky_Current_Health <= 0 and not gDebugging then
            BuckyKOMessage()
            F_FailMission()
        end
    end
    return false
end

function F_StopTimer()
end

function F_MissionSpawnerFinished()
    if not bSecondBulliesAttacked and PlayerIsInTrigger(TRIGGER._1_07_FIGHTTRIGGER) then
        if PedIsValid(gGateBully01) then
            F_SpawnerCallback(gGateBully01)
        end
        if PedIsValid(gGateBully02) then
            F_SpawnerCallback(gGateBully02)
        end
        gCurrentBully01 = gGateBully01
        gCurrentBully02 = gGateBully02
        bSecondBulliesAttacked = true
    end
    if nWaveBeat == 0 then
    elseif nWaveBeat == 1 then
        if not bBuckyHiding and (PedIsValid(gGateBully01) and PedCanSeeObject(idBucky, gGateBully01, 2) or PedIsValid(gGateBully02) and PedCanSeeObject(idBucky, gGateBully02, 2)) then
            F_BuckyGoCowerRandomly()
            bBuckyHiding = true
        end
    elseif nWaveBeat == 2 then
    elseif nWaveBeat == 3 then
        if not bBuckyHiding and (PedIsValid(gGateBully01) and PedCanSeeObject(idBucky, gGateBully01, 2) or PedIsValid(gGateBully02) and PedCanSeeObject(idBucky, gGateBully02, 2)) then
            F_BuckyGoCowerRandomly()
            bBuckyHiding = true
        end
        if not bSecondBulliesAttacked and PlayerIsInTrigger(TRIGGER._1_07_FIGHTTRIGGER) then
            if PedIsValid(gGateBully01) then
                F_SpawnerCallback(gGateBully01)
            end
            if PedIsValid(gGateBully02) then
                F_SpawnerCallback(gGateBully02)
            end
            bSecondBulliesAttacked = true
        end
    elseif nWaveBeat == 4 then
        local x, y, z = GetPointFromPointList(POINTLIST._1_07_PLYRDOOR, 1)
        if PlayerIsInAreaXYZ(x, y, z, 0.8, 7) then
            PlayerSetControl(0)
            bPlayerReachedGate = true
            return true
        end
    end
    return false
end

function F_MonitorHealth()
    if gDebugging then
        return false
    end
    if PlayerGetHealth() <= 0 then
        PlayerKOMessage()
        return true
    else
        if idBucky == nil then
            BuckyKOMessage()
            return true
        end
        if 0 >= PedGetHealth(idBucky) then
            BuckyKOMessage()
            return true
        end
    end
    if PedIsValid(idBucky) then
        if not bBuckyCower and PedGetHealth(idBucky) < gBuckysPreviousHealth and PedGetWhoHitMeLast(idBucky) then
            gBuckysPreviousHealth = PedGetHealth(idBucky)
            PedClearHitRecord(idBucky)
            PedClearObjectives(idBucky)
            pathNode = 0
            F_BuckyGoCowerWithPrecedent()
        elseif idBucky and PedIsValid(idBucky) and not bBuckyCower then
            local peds, id1, id2, id3, id4 = PedFindInAreaObject(idBucky, 2)
            if id1 ~= idBucky and id1 ~= gPlayer and id1 ~= nil or id2 ~= idBucky and id2 ~= gPlayer and id2 ~= nil or id3 ~= idBucky and id3 ~= gPlayer and id3 ~= nil then
                PedClearHitRecord(idBucky)
                if PedIsPlaying(idBucky, "/Global/1_07/Cower", false) then
                    PedSetActionNode(idBucky, "/Global/1_07/EndCower", "Act/Conv/1_07.act")
                    while PedIsPlaying(idBucky, "/Global/1_07/EndCower", false) do
                        Wait(0)
                    end
                end
                PedSetActionNode(idBucky, "/Global/1_07/Idle", "Act/Conv/1_07.act")
                F_BuckyGoCowerWithPrecedent()
            end
        end
    end
    if bSendBuckyOffAgain then
        --print("BUCKY GO COWER AGAIN!")
        F_BuckyGoCowerWithPrecedent()
        bSendBuckyOffAgain = false
    end
    return false
end

function F_BuckyGoCowerRandomly()
    local pickPath = math.random(1, 100)
    if nWaveBeat == 0 then
        if 66 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_BUCKY_COWERS, 0, 1, cbBuckyCower, 2)
            gLastPath = PATH._1_07_BUCKY_COWERS
        elseif 33 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_PATH2, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_PATH2
        elseif 0 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_PATH3, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_PATH3
        end
    elseif nWaveBeat == 1 then
        if 50 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_SCNDPATH1, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_SCNDPATH1
        elseif 0 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_SCNDPATH2, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_SCNDPATH2
        end
    elseif nWaveBeat == 3 then
        if 66 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_THRDPATH1, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_THRDPATH1
        elseif 33 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_THRDPATH2, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_THRDPATH2
        elseif 0 < pickPath then
            PedFollowPath(idBucky, PATH._1_07_THRDPATH3, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_THRDPATH3
        end
    end
    if PedHasAlly(idBucky) then
        PedDismissAlly(gPlayer, idBucky)
        PedShowHealthBar(idBucky, true, "1_07_12", false)
    end
    bBuckyHiding = true
    bBuckyCower = true
end

function F_BuckyGoCowerWithPrecedent()
    if nWaveBeat == 0 then
        if gLastPath == PATH._1_07_BUCKY_COWERS then
            if math.random(1, 100) > 50 then
                PedFollowPath(idBucky, PATH._1_07_PATH2, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_PATH2
            else
                PedFollowPath(idBucky, PATH._1_07_PATH3, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_PATH3
            end
        elseif gLastPath == PATH._1_07_PATH2 then
            if math.random(1, 100) > 50 then
                PedFollowPath(idBucky, PATH._1_07_BUCKY_COWERS, 0, 1, cbBuckyCower, 2)
                gLastPath = PATH._1_07_BUCKY_COWERS
            else
                PedFollowPath(idBucky, PATH._1_07_PATH3, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_PATH3
            end
        elseif gLastPath == PATH._1_07_PATH3 then
            if math.random(1, 100) > 50 then
                PedFollowPath(idBucky, PATH._1_07_BUCKY_COWERS, 0, 1, cbBuckyCower, 2)
                gLastPath = PATH._1_07_BUCKY_COWERS
            else
                PedFollowPath(idBucky, PATH._1_07_PATH2, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_PATH2
            end
        end
    elseif nWaveBeat == 1 then
        if gLastPath == PATH._1_07_SCNDPATH1 then
            PedFollowPath(idBucky, PATH._1_07_SCNDPATH2, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_SCNDPATH2
        elseif gLastPath == PATH._1_07_SCNDPATH2 then
            PedFollowPath(idBucky, PATH._1_07_SCNDPATH1, 0, 1, cbBuckyCower, 1)
            gLastPath = PATH._1_07_SCNDPATH1
        end
    elseif nWaveBeat == 3 then
        if gLastPath == PATH._1_07_THRDPATH1 then
            if math.random(1, 100) > 50 then
                PedFollowPath(idBucky, PATH._1_07_THRDPATH2, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_THRDPATH2
            else
                PedFollowPath(idBucky, PATH._1_07_THRDPATH3, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_THRDPATH3
            end
        elseif gLastPath == PATH._1_07_THRDPATH2 then
            if math.random(1, 100) > 50 then
                PedFollowPath(idBucky, PATH._1_07_THRDPATH1, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_THRDPATH1
            else
                PedFollowPath(idBucky, PATH._1_07_THRDPATH3, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_THRDPATH3
            end
        elseif gLastPath == PATH._1_07_THRDPATH3 then
            if math.random(1, 100) > 50 then
                PedFollowPath(idBucky, PATH._1_07_THRDPATH1, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_THRDPATH1
            else
                PedFollowPath(idBucky, PATH._1_07_THRDPATH2, 0, 1, cbBuckyCower, 1)
                gLastPath = PATH._1_07_THRDPATH2
            end
        end
    end
    bBuckyCower = true
end

function BuckyKOMessage()
end

function PlayerKOMessage()
end

function F_OpenGate()
    if not bGateOpen and (PlayerIsInTrigger(TRIGGER._1_07_GATETRIG) or PlayerIsInTrigger(TRIGGER._1_07_FIGHTTRIGGER)) then
        PAnimSetActionNode(TRIGGER._1_07_GATE_T, "/Global/1_07/OpenGate", "Act/Conv/1_07.act")
        AreaSetDoorPathableToPeds(TRIGGER._1_07_GATE_T, false)
        bGateOpen = true
    end
end

function F_FocusOnGate()
    BlipRemove(idBuckyBlip)
    idBuckyBlip = AddBlipForChar(idBucky, 1, 27, 1)
    TextPrint("1_07_Objective1", 4, 1)
    MissionObjectiveComplete(gObjectives[1])
    table.insert(gObjectives, MissionObjectiveAdd("1_07_Objective1"))
    PAnimSetActionNode(TRIGGER._1_07_GATE_T, "/Global/1_07/CloseGate/PropClosed", "Act/Conv/1_07.act")
    AreaSetDoorPathableToPeds(TRIGGER._1_07_GATE_T, false)
    DoorsInit()
end

function F_CreateAnim()
    bGateCreated = true
end

local bBullySelected = false

function F_CreateBullies()
    L_PedLoadPoint(group2, {
        {
            model = 85,
            point = POINTLIST._1_07_SPAWNPOINT01,
            target = "none",
            KO = false,
            middle = true
        },
        {
            model = 102,
            point = POINTLIST._1_07_SPAWNPOINT03,
            target = "none",
            KO = false,
            middle = false
        }
    })
    bGroup2Created = true
    gGateBully01 = L_PedGetID("middle", true)
    gGateBully02 = L_PedGetID("middle", false)
    PedSetWeapon(gGateBully01, 300, 1)
end

function F_GateBully()
    if idHitMan and PedIsValid(idHitMan) and not PedIsDead(idHitMan) then
        PedFaceObject(idHitMan, gPlayer, 2, 0)
        AddBlipForChar(idHitMan, 11, 26, 1)
        PedSetAsleep(idHitMan, true)
        PedSetEmotionTowardsPed(idHitMan, idBucky, 2)
        PedSetEmotionTowardsPed(idHitMan, gPlayer, 0)
        PedSetPedToTypeAttitude(idHitMan, 13, 0)
        PedSetWantsToSocializeWithPed(idHitMan, idBucky)
        PedSetEmotionTowardsPed(idBucky, idHitMan, 5)
        PedFaceObject(idHitMan, idBucky, 2, 0)
    end
    if id2ndMan and PedIsValid(id2ndMan) and not PedIsDead(id2ndMan) then
        PedFaceObject(id2ndMan, gPlayer, 2, 0)
        AddBlipForChar(id2ndMan, 11, 26, 1)
        PedSetAsleep(id2ndMan, true)
        PedSetEmotionTowardsPed(id2ndMan, idBucky, 2)
        PedSetEmotionTowardsPed(id2ndMan, gPlayer, 0)
        PedSetPedToTypeAttitude(id2ndMan, 13, 0)
        PedSetWantsToSocializeWithPed(id2ndMan, idBucky)
        PedSetEmotionTowardsPed(idBucky, id2ndMan, 5)
        PedFaceObject(id2ndMan, idBucky, 2, 0)
    end
end

function F_GreaserAI(idGreaser)
    if not L_PedGetData(idGreaser, "KO") and PedIsValid(idGreaser) and PedGetHealth(idGreaser) <= 0 then
        L_PedSetData(idGreaser, "KO", true)
        if bPopDropper and idGreaser == idPopDropper then
            --print("POP CREATED!!!!")
            PickupCreateFromPed(502, idPopDropper, "HealthBute")
            bPopDropper = false
        end
    end
end

function CB_GrabWhatever(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) then
        PedSetActionNode(idBucky, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
    end
end

function T_MonitorGreasers()
    while not L_PedAllDead(group1) do
        L_PedExec(group1, F_GreaserAI, "id")
        Wait(100)
    end
    nWaveBeat = 1
    bPopDropper = true
    if bBuckyHiding then
        if bBuckyDied then
            return
        end
        PedStop(idBucky)
        if PedIsPlaying(idBucky, "/Global/1_07/Cower", false) then
            PedSetActionNode(idBucky, "/Global/1_07/EndCower", "Act/Conv/1_07.act")
        else
            PedSetActionNode(idBucky, "/Global/1_07/Idle", "Act/Conv/1_07.act")
        end
        bBuckyHiding = false
    end
    PedHideHealthBar()
    PedRecruitAlly(gPlayer, idBucky)
    PedSetTypeToTypeAttitude(11, 1, 0)
    PAnimSetActionNode(TRIGGER._SCGRDOOR02, "/Global/1_07/ParametricDoor/POpenUp/Close/Closing/NotUseable/propClosed/ClosedIdle", "Act/Conv/1_07.act")
    F_AddObjectiveBlip("POINT", POINTLIST._1_07_BUCKYOBJ, 1, 1)
    TextPrint("1_07_Objective2", 4, 1)
    MissionObjectiveComplete(gObjectives[2])
    table.insert(gObjectives, MissionObjectiveAdd("1_07_Objective2"))
    while not L_PedAllDead(group2) do
        L_PedExec(group2, F_GreaserAI, "id")
        Wait(100)
        if bBuckyDied then
            return
        end
    end
    nWaveBeat = 2
    PAnimSetActionNode(TRIGGER._SCGRDOOR02, "/Global/1_07/ParametricDoor/POpenUp/Closed", "Act/Conv/1_07.act")
    CreateThread("T_DoorMonitor")
    TextPrint("1_07_Objective2", 4, 1)
    if bBuckyHiding then
        if bBuckyDied then
            return
        end
        PedDismissAlly(gPlayer, idBucky)
        PedShowHealthBar(idBucky, true, "1_07_12", false)
        PedStop(idBucky)
        if PedIsPlaying(idBucky, "/Global/1_07/Cower", false) then
            PedSetActionNode(idBucky, "/Global/1_07/EndCower", "Act/Conv/1_07.act")
        else
            PedSetActionNode(idBucky, "/Global/1_07/Idle", "Act/Conv/1_07.act")
        end
        bBuckyHiding = false
    end
    PedFollowPath(idBucky, PATH._1_07_TOGATEWAIT, 0, 1)
    while not bDoorOpened do
        if bBuckyDied then
            return
        end
        Wait(0)
    end
    AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR01, true)
    L_PedLoadPoint(group3, {
        {
            model = 145,
            point = POINTLIST._1_07_SPAWNPOINT04,
            target = "none",
            KO = false,
            final = true
        },
        {
            model = 102,
            point = POINTLIST._1_07_SPAWNPOINT05,
            target = "none",
            KO = false,
            final = false
        }
    })
    bGroup3Created = true
    gGateBully01 = L_PedGetID("final", true)
    gGateBully02 = L_PedGetID("final", false)
    PedSetWeapon(gGateBully01, 300, 1)
    gCurrentBully01 = gGateBully01
    gCurrentBully02 = gGateBully02
    nWaveBeat = 3
    bSecondBulliesAttacked = false
    PedStop(idBucky)
    PedClearObjectives(idBucky)
    PlayerSetControl(0)
    PedFollowPath(idBucky, PATH._1_07_TOTOOLBOX, 0, 1, CB_GrabWhatever, 1)
    Wait(1000)
    F_DoBuckyGrabbingNIS()
    F_AddObjectiveBlip("POINT", POINTLIST._1_07_PLYRDOOR, 1, 1)
    MissionObjectiveComplete(gObjectives[3])
    TextPrint("1_07_Objective3", 4, 1)
    table.insert(gObjectives, MissionObjectiveAdd("1_07_Objective3"))
    PedClearObjectives(idBucky)
    PedHideHealthBar()
    PedRecruitAlly(gPlayer, idBucky)
    gGuysBeat = true
    while not L_PedAllDead(group3) do
        L_PedExec(group3, F_GreaserAI, "id")
        Wait(100)
        if bBuckyDied then
            return
        end
    end
    nWaveBeat = 4
    TextPrint("1_07_Objective4", 4, 1)
    if bBuckyHiding then
        if bBuckyDied then
            return
        end
        PedHideHealthBar()
        PedRecruitAlly(gPlayer, idBucky)
        PedStop(idBucky)
        if PedIsPlaying(idBucky, "/Global/1_07/Cower", false) then
            PedSetActionNode(idBucky, "/Global/1_07/EndCower", "Act/Conv/1_07.act")
        else
            PedSetActionNode(idBucky, "/Global/1_07/Idle", "Act/Conv/1_07.act")
        end
        bBuckyHiding = false
    end
    while not bPlayerReachedGate do
        if bBuckyDied then
            return
        end
        Wait(0)
    end
    collectgarbage()
end

function cbOnTriggerContainsPed(TriggerID, PedID)
    if PedIsValid(PedID) then
        if TriggerID == TRIGGER._1_07_GATE_T and PedID ~= 0 and PedID ~= nil and not bDoorZoneOccupied then
            bDoorZoneOccupied = true
        else
            bDoorZoneOccupied = false
        end
    end
end

function cbOnTriggerEnteredByPed(TriggerID, PedID)
    if PedIsValid(PedID) and TriggerID == TRIGGER._1_07_GATE_T and PedID ~= 0 and PedID ~= nil and not bDoorOpen then
        PAnimSetActionNode(TRIGGER._1_07_GATE_T, "/Global/1_07/OpenGate/PropOpened", "Act/Conv/1_07.act")
        bDoorOpen = true
    end
end

function cbOnTriggerExitedByPed(TriggerID, PedID)
    if PedIsValid(PedID) and TriggerID == TRIGGER._1_07_GATE_T and PedID ~= 0 and PedID ~= nil and not bDoorZoneOccupied and bDoorOpen then
        PAnimSetActionNode(TRIGGER._1_07_GATE_T, "/Global/1_07/CloseGate/PropClosed", "Act/Conv/1_07.act")
        bDoorOpen = false
    end
end

function cbBuckyCower(pedId, pathId, pathNode)
    if pedId == idBucky and pathNode == PathGetLastNode(pathId) then
        --print("GETTING CALLED MULTIPLE TIMES??")
        bBuckyCower = false
        local peds, id1, id2, id3, id4 = PedFindInAreaObject(idBucky, 1)
        --print("peds: ", peds)
        --print("id1: ", id1)
        --print("id2: ", id2)
        --print("id3: ", id3)
        --print("id4: ", id4)
        --print("idBucky: ", idBucky)
        --print("gPlayer: ", gPlayer)
        if id1 ~= idBucky and id1 ~= gPlayer and id1 ~= nil or id2 ~= idBucky and id2 ~= gPlayer and id2 ~= nil or id3 ~= idBucky and id3 ~= gPlayer and id3 ~= nil then
            --print("SOMEONE IS AROUND BUCKY SUPPOSEDLY!")
            PedClearHitRecord(idBucky)
            bSendBuckyOffAgain = true
        else
            --print("CRASHING HERE!??!?!?!")
            PedStop(idBucky)
            PedFaceHeading(idBucky, 39, 1)
            PedOverrideStat(idBucky, 8, 15)
            PedOverrideStat(idBucky, 11, 85)
            PedOverrideStat(idBucky, 10, 50)
            PedOverrideStat(idBucky, 14, 25)
            PedOverrideStat(idBucky, 3, 30)
            PedOverrideStat(idBucky, 7, 65)
            PedOverrideStat(idBucky, 6, 65)
            PedSetActionNode(idBucky, "/Global/1_07/Cower", "Act/Conv/1_07.act")
        end
    end
end

function F_CreateBucky()
    idBucky = PedCreatePoint(8, POINTLIST._1_07_BUCKY, 1)
    GameSetPedStat(idBucky, 15, 0)
    PlayerSocialDisableActionAgainstPed(idBucky, 28, true)
    PlayerSocialDisableActionAgainstPed(idBucky, 29, true)
    PlayerSocialDisableActionAgainstPed(idBucky, 24, true)
    PlayerSocialDisableActionAgainstPed(idBucky, 35, true)
    PlayerSocialDisableActionAgainstPed(idBucky, 25, true)
    PlayerSocialDisableActionAgainstPed(idBucky, 23, true)
    idBuckyBlip = BlipAddPoint(POINTLIST._1_07_BUCKY, 0, 1)
    L_PedLoadPoint(group1, {
        {
            model = 146,
            point = POINTLIST._1_07_G1,
            target = "none",
            KO = false,
            leader = true
        },
        {
            model = 99,
            point = POINTLIST._1_07_G2,
            target = "none",
            KO = false,
            leader = false
        }
    })
    bGroup1Created = true
    idHitMan = L_PedGetID("leader", true)
    id2ndMan = L_PedGetID("leader", false)
    PedSetWeapon(id2ndMan, 300, 1)
    gCurrentBully01 = idHitMan
    gCurrentBully02 = id2ndMan
    PedSetPedToTypeAttitude(idBucky, 13, 4)
    PedStop(idBucky)
    PedSetStationary(idBucky, true)
    PedOverrideStat(idBucky, 8, 25)
    PedOverrideStat(idBucky, 11, 25)
    PedOverrideStat(idBucky, 10, 50)
    PedOverrideStat(idBucky, 14, 35)
    PedOverrideStat(idBucky, 3, 30)
    PedSetMinEngage(idBucky, 7)
    PedOverrideStat(idBucky, 7, 100)
    PedOverrideStat(idBucky, 6, 10)
    PedSetHealth(idBucky, BUCKY_DEFAULT_HEALTH)
    PedShowHealthBar(idBucky, true, "1_07_12", false)
    PedClearAllWeapons(idBucky)
end

function F_SpawnerCallback(idPed)
    local index
    PedMakeMissionChar(idPed)
    TotalSpawn = TotalSpawn + 1
    PedRestrictToTrigger(idPed, TRIGGER._1_07_NOAMBIENTPEDS)
    PedSetPedToTypeAttitude(idPed, 13, 0)
    PedSetPedToTypeAttitude(idPed, 1, 0)
    PedOverrideStat(idPed, 14, 100)
    PedOverrideStat(idPed, 3, 50)
    PedOverrideStat(idPed, 2, 360)
    if not bBullyDialogue then
        if PedIsModel(idPed, 99) then
            SoundPlayScriptedSpeechEvent(idPed, "M_1_07", 3, "xtralarge")
            bBullyDialogue = true
        elseif PedIsModel(idPed, 85) then
            SoundPlayScriptedSpeechEvent(idPed, "M_1_07", 4, "xtralarge")
            bBullyDialogue = true
        elseif PedIsModel(idPed, 146) then
            SoundPlayScriptedSpeechEvent(idPed, "M_1_07", 6, "xtralarge")
            bBullyDialogue = true
        end
    end
    if math.random(1, 100) > 40 then
        PedAttack(idPed, gPlayer, 1)
        PedAttack(idPed, idBucky, 1)
    else
        PedAttack(idPed, idBucky, 1)
        PedAttack(idPed, gPlayer, 1)
    end
    AddBlipForChar(idPed, 11, 26, 1)
    if TotalSpawn == 2 then
        idPopDropper = idPed
        bPopDropper = true
    end
end

function TimerPassed(time)
    if time <= GetTimer() then
        return true
    else
        return false
    end
end

function TimerCheck(timer, atime)
    local min, max = 0, 0
    min = atime
    max = atime + __timerDelta
    if timer >= min and timer < max then
        return true
    end
    return false
end

function cbNone()
end

function MissionSetup()
    MissionDontFadeIn()
    SoundPlayInteractiveStream("MS_ActionLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_ActionMid.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_ActionHigh.rsm", MUSIC_DEFAULT_VOLUME)
    PlayCutsceneWithLoad("1-07", true)
    DATLoad("1_07.DAT", 2)
    DATLoad("tschool_garagedoors.DAT", 2)
    DATInit()
    LoadWeaponModels({ 319, 437 })
end

function F_MissionSetup()
    LoadAnimationGroup("1_03The Setup")
    LoadAnimationGroup("1_07_SaveBucky")
    LoadAnimationGroup("TSGate")
    LoadAnimationGroup("F_Nerds")
    LoadAnimationGroup("Hang_Jock")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadAnimationGroup("Hang_Talking")
    LoadAnimationGroup("1_07_Sk8Board")
    Load("Act/Conv/1_07.act")
    Load("Act/Gifts/Give107.act")
    WeaponRequestModel(300)
    WeaponRequestModel(301)
    WeaponRequestModel(437)
    PedSetTypeToTypeAttitude(11, 13, 0)
    Uniqueness = PedGetUniqueModelStatus(102)
    PedRequestModel(102)
    PedRequestModel(99)
    PedRequestModel(85)
    PedRequestModel(145)
    PedRequestModel(146)
    PedRequestModel(147)
    PedRequestModel(8)
    PedRequestModel(87)
    PedSetUniqueModelStatus(102, -1)
    PedSetUniqueModelStatus(99, -1)
    PedSetUniqueModelStatus(85, -1)
    PedSetUniqueModelStatus(145, -1)
    PedSetUniqueModelStatus(146, -1)
    PedSetUniqueModelStatus(147, -1)
    LoadAnimationGroup("TSGate")
    LoadPAnims({
        TRIGGER._1_07_TOOLBOX01
    })
    PAnimCreate(TRIGGER._1_07_TOOLBOX01)
    PAnimCreate(TRIGGER._1_07_GATE_T)
    DoorsInit()
    gSktModl, gSktGeo = CreatePersistentEntity("SC_SK8Board", 154.684, 1.29007, 6.77178, 0, 0)
end

function MissionCleanup()
    AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR01, true)
    AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR02, true)
    if bGroup1Created then
        L_PedExec(group1, PedMakeAmbient, "id")
    end
    if bGroup2Created then
        L_PedExec(group2, PedMakeAmbient, "id")
    end
    if bGroup3Created then
        L_PedExec(group3, PedMakeAmbient, "id")
    end
    CameraSetWidescreen(false)
    if Bum and PedIsValid(Bum) then
        PedSetInvulnerable(Bum, true)
        PedStop(Bum)
        PedClearObjectives(Bum)
        PedDelete(Bum)
    end
    F_MakePlayerSafeForNIS(false)
    PAnimCloseDoor(TRIGGER._BUSDOORS)
    shared.gCheckHoboDoors = true
    AreaSetDoorPathableToPeds(TRIGGER._BUSDOORS, false)
    SoundStopInteractiveStream()
    SoundEnableSpeech_ActionTree()
    if idBuckyBlip ~= nil then
        BlipRemove(idBuckyBlip)
        idBuckyBlip = nil
    end
    AreaSetDoorPathableToPeds(TRIGGER._1_07_GATE_T, true)
    shared.gCheckHoboDoors = true
    if bGateCreated then
        PAnimDelete(TRIGGER._1_07_GATE_T)
        bGateCreated = false
    end
    AreaRevertToDefaultPopulation()
    if bMissionSuccess then
        PedSetActionNode(gPlayer, "/Global/Weapons/SelectActions/WeaponSelect/Select/Default", "Act/Weapons.act")
        --print("EXECUTING!")
        if IsMissionCompleated("1_08") then
            AreaLoadSpecialEntities("Halloween1", true)
        end
    end
    if idBucky and PedIsValid(idBucky) then
        PedDismissAlly(gPlayer, idBucky)
    end
    PedHideHealthBar()
    EnablePOI()
    PedSetUniqueModelStatus(102, Uniqueness)
    PedSetUniqueModelStatus(99, Uniqueness)
    PedSetUniqueModelStatus(85, Uniqueness)
    PedSetUniqueModelStatus(145, Uniqueness)
    PedSetUniqueModelStatus(146, Uniqueness)
    PedSetUniqueModelStatus(147, Uniqueness)
    F_RemoveObjectiveBlip()
    UnLoadBranch("/Global/1_07")
    UnLoadAnimationGroup("1_03The Setup")
    UnLoadAnimationGroup("1_07_SaveBucky")
    UnLoadAnimationGroup("TSGate")
    UnLoadAnimationGroup("F_Nerds")
    UnLoadAnimationGroup("Hang_Jock")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("Hang_Talking")
    mission_started = false
    if idBucky then
        PedMakeAmbient(idBucky)
    end
    if gSktModl ~= nil and gSktGeo ~= nil then
        DeletePersistentEntity(gSktModl, gSktGeo)
        gSktModl = nil
        gSktGeo = nil
    end
    PlayerSetControl(1)
end

function main()
    F_MissionSetup()
    F_CreateBucky()
    L_ObjectiveSetParam({
        objReachBucky = {
            successConditions = { F_ReachedBucky },
            failureConditions = { F_RunningToBucky },
            stopOnFailed = true,
            stopOnCompleted = false,
            failActions = { F_FailMission },
            completeActions = {
                F_GateBully,
                F_FocusOnGate,
                F_CreateAnim,
                F_CreateBullies,
                F_AskForHelp,
                F_BuckyGoCowerRandomly
            }
        },
        objDefeatEnemies = {
            successConditions = { F_MissionSpawnerFinished },
            failureConditions = { F_MonitorHealth },
            stopOnFailed = true,
            stopOnCompleted = true,
            failActions = { F_FailMission },
            completeActions = { F_CompleteMission }
        }
    })
    POISetSystemEnabled(false)
    mission_started = true
    PlayerSetControl(0)
    local i = 1
    CreateThread("T_ManageDoors")
    AreaTransitionPoint(0, POINTLIST._1_07_PSTART, 1, true)
    CameraReturnToPlayer()
    CameraReset()
    CameraFade(1000, 1)
    Wait(1000)
    if mission_started then
        CameraReturnToPlayer()
        TextPrint("1_07_command", 3, 1)
        table.insert(gObjectives, MissionObjectiveAdd("1_07_command"))
        timer_running = true
        Start_Timer_Time = GetTimer()
        Time_To_Get_To_Bucky = Start_Timer_Time + REACH_BUCKY_TIME
        Last_Timer_Time = 0
        CreateThread("T_ObjectiveMonitor")
        PlayerSetControl(1)
        while not L_ObjectiveProcessingDone() do
            Wait(5)
        end
    end
end

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

function T_DoorMonitor()
    --print(">>>[RUI]", "++T_DoorMonitor")
    bCoronaActive = true
    while mission_running or bCoronaActive do
        local x, y, z = GetPointFromPointList(POINTLIST._1_07_GARAGECORONA, 1)
        while bCoronaActive do
            PlayerIsInAreaXYZ(x, y, z, 0.75, 7)
            if bDoorOpened then
                AreaSetDoorLockedToPeds(TRIGGER._SCGRDOOR02, false)
                AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR02, true)
                bCoronaActive = false
                break
            else
                bCoronaActive = true
            end
            bCoronaActive = not bDoorOpened
            Wait(0)
        end
        Wait(0)
    end
    --print(">>>[RUI]", "!!T_DoorMonitor:    opened")
    collectgarbage()
end

function DoorsInit()
    --print("Create doors")
    if not bDoorsMade then
        PAnimCreate(TRIGGER._SCGRDOOR01)
        --print("First door created!")
        PAnimSetActionNode(TRIGGER._SCGRDOOR01, "/Global/1_07/ParametricDoor/POpenUp/Closed/NotUseable/BeingLifted/HandleSoundCalls/DoorOnGround", "Act/Conv/1_07.act")
        AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR01, false)
        --print("First door locked!")
        PAnimCreate(TRIGGER._SCGRDOOR02)
        --print("Second door created!")
        PAnimSetActionNode(TRIGGER._SCGRDOOR02, "/Global/1_07/ParametricDoor/POpenUp/Closed/NotUseable/BeingLifted/HandleSoundCalls/DoorOnGround", "Act/Conv/1_07.act")
        AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR02, false)
        --print("Second door locked!")
    end
    bDoorOpened = false
    bDoorsMade = true
end

function cbDoorOpened()
    bDoorOpened = true
    --print(">>>[RUI]", "!!cbDoorOpened")
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    local skip = false
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while not (not SoundSpeechPlaying() or skip) do
            skip = WaitSkippable(1)
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while not (not SoundSpeechPlaying() or skip) do
            skip = WaitSkippable(1)
        end
    end
    return skip
end

function T_AddBuckyAllyBlip()
end

function F_DoBuckyGrabbingNIS()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    DoublePedShadowDistance(true)
    PAnimSetActionNode(TRIGGER._1_07_TOOLBOX01, "/Global/ToolBox/Useable", "Act/Props/ToolBox.act")
    CameraSetWidescreen(true)
    CameraSetFOV(40)
    CameraSetXYZ(127.331924, 11.508741, 7.602786, 126.3382, 11.605961, 7.548733)
    PedSetPosPoint(idBucky, POINTLIST._1_07_BYTHETOOLBOX, 1)
    PedDismissAlly(gPlayer, idBucky)
    PedClearTether(idBucky)
    PedStop(idBucky)
    PedClearObjectives(idBucky)
    PedStopSocializing(idBucky)
    PedSetActionNode(idBucky, "/Global/1_07/Idle", "Act/Conv/1_07.act")
    PedStop(idBucky)
    PedClearObjectives(idBucky)
    PedStopSocializing(idBucky)
    PedSetActionNode(idBucky, "/Global/1_07/Idle", "Act/Conv/1_07.act")
    Wait(10)
    PedFollowPath(idBucky, PATH._1_07_TOTOOLBOXF, 0, 1, CB_GrabWhatever, 1)
    CameraFade(500, 1)
    Wait(500)
    while not PedIsPlaying(idBucky, "/Global/ToolBox/PedPropsActions/Interact/StartUsing", false) do
        Wait(0)
    end
    while PedIsPlaying(idBucky, "/Global/ToolBox/PedPropsActions/Interact/StartUsing", false) do
        Wait(0)
    end
    Wait(500)
    PAnimSetActionNode(TRIGGER._1_07_TOOLBOX01, "/Global/ToolBox/NotUseable", "Act/Props/ToolBox.act")
    PedSetActionNode(idBucky, "/Global/1_07/PutAway", "Act/Conv/1_07.act")
    CameraSetWidescreen(false)
    CameraReset()
    CameraReturnToPlayer()
    PlayerSetControl(1)
    DoublePedShadowDistance(false)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_BuckWasKnockedOutNIS()
    CameraFade(500, 0)
    Wait(501)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    PlayerSetInvulnerable(true)
    CameraSetXYZ(164.18665, 10.706492, 9.229423, 163.35844, 10.172656, 9.058949)
    CameraAllowChange(false)
    PedDelete(idBucky)
    local bEveryoneDead = true
    PedSetTypeToTypeAttitude(11, 13, 2)
    if gCurrentBully01 and PedIsValid(gCurrentBully01) and not PedIsDead(gCurrentBully01) then
        bEveryoneDead = false
        PedSetAsleep(gCurrentBully01, true)
        PedClearObjectives(gCurrentBully01)
        PedIgnoreStimuli(gCurrentBully01, true)
        Wait(10)
        PedSetPosPoint(gCurrentBully01, POINTLIST._1_07_BULLYENDNIS, 1)
        Wait(10)
        PedFaceHeading(gCurrentBully01, 270, 0)
    end
    if gCurrentBully02 and PedIsValid(gCurrentBully02) and not PedIsDead(gCurrentBully02) then
        bEveryoneDead = false
        PedSetAsleep(gCurrentBully02, true)
        PedClearObjectives(gCurrentBully02)
        PedIgnoreStimuli(gCurrentBully02, true)
        Wait(10)
        PedSetPosPoint(gCurrentBully02, POINTLIST._1_07_BULLYENDNIS, 2)
        Wait(10)
        PedFaceHeading(gCurrentBully02, 270, 0)
    end
    if bEveryoneDead then
        gCurrentBully01 = PedCreatePoint(145, POINTLIST._1_07_BULLYENDNIS, 1)
        gCurrentBully02 = PedCreatePoint(102, POINTLIST._1_07_BULLYENDNIS, 2)
    end
    PlayerSetPosPoint(POINTLIST._1_07_BULLYENDNIS, 3)
    AreaClearAllPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    CameraFade(500, 1)
    Wait(501)
    MinigameSetCompletion("M_FAIL", false, 0, "1_07_BUCKYKO")
    SoundPlayMissionEndMusic(false, 10)
    AreaSetDoorLocked(TRIGGER._1_07_GATE_T, false)
    AreaSetDoorPathableToPeds(TRIGGER._1_07_GATE_T, true)
    PAnimSetActionNode(TRIGGER._1_07_GATE_T, "/Global/1_07/OpenTSGate", "Act/Conv/1_07.act")
    Wait(2500)
    if gCurrentBully01 and PedIsValid(gCurrentBully01) then
        PedMakeAmbient(gCurrentBully01)
        PedClearObjectives(gCurrentBully01)
        PedIgnoreStimuli(gCurrentBully01, true)
        PedSetAsleep(gCurrentBully01, false)
        Wait(10)
        PedFollowPath(gCurrentBully01, PATH._1_07_JIMMYPATH, 0, 1)
    end
    if gCurrentBully02 and PedIsValid(gCurrentBully02) then
        PedMakeAmbient(gCurrentBully02)
        PedClearObjectives(gCurrentBully02)
        PedIgnoreStimuli(gCurrentBully02, true)
        PedSetAsleep(gCurrentBully02, false)
        Wait(10)
        PedFollowPath(gCurrentBully02, PATH._1_07_BUCKYPATH, 0, 1)
    end
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    PlayerSetInvulnerable(false)
    F_MakePlayerSafeForNIS(false)
    CameraAllowChange(true)
    CameraFade(500, 0)
    Wait(501)
    if gCurrentBully01 and PedIsValid(gCurrentBully01) then
        PedDelete(gCurrentBully01)
        gCurrentBully01 = nil
    end
    if gCurrentBully02 and PedIsValid(gCurrentBully02) then
        PedDelete(gCurrentBully02)
        gCurrentBully02 = nil
    end
end
