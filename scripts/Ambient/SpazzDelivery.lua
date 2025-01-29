POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local GoalsCreated = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = { 236, 222 }
local bActive = false
local gSpazzMan = -1
local ObjFlag = false
local MissionScenarioComplete = false
local delX, delY, delZ = 165.299, -457.504, 2.57666
local gBlipSpazz = 0
local timeLimit = 90
local AcceptScenario = false
local Receiver1Blip

function main()
    while SetupComplete == false do
        if OutOfRange == true or POIInfo == nil then
            SetupComplete = true
        else
            SetupComplete = F_ScenarioSetup()
        end
        Wait(0)
    end
    while F_CheckConditions() == true do
        if GreetingComplete == false then
            GreetingComplete = F_OnGreeting()
        elseif DialogComplete == false then
            DialogComplete = F_OnDialog()
        elseif AcceptScenario == false then
            AcceptScenario = F_AcceptScenario()
        elseif GoalsCreated == false then
            GoalsCreated = F_ScenarioGoals()
        elseif MissionScenarioComplete == false then
            MissionScenarioComplete = F_MissionSpecificCheck()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_SD_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    local x, y, z = POIGetPosXYZ(POIInfo)
    ScenarioPed = PedCreatePOIPoint(236, POIInfo)
    if PedIsValid(ScenarioPed) then
        PedMakeAmbient(ScenarioPed, false)
        PedSetFlag(ScenarioPed, 110, true)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 2)
        PedMoveToObject(ScenarioPed, gPlayer, 2, 1, nil, 2)
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        return true
    else
        return false
    end
end

function F_PlayerOutOfRange()
    local x1, y1, z1 = POIGetPosXYZ(POIInfo)
    local x2, y2, z2 = PlayerGetPosXYZ()
    if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() == true then
        return true
    else
        return false
    end
end

function F_OnGreeting()
    if PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen", false) == true then
        TimeOutTimer = GetTimer()
        return true
    else
        return false
    end
end

function F_OnDialog()
    if PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 38, "generic", false, true)
        return true
    else
        if GetTimer() >= TimeOutTimer + TimeOutTime then
            SoundPlayAmbientSpeechEvent(ScenarioPed, "BYE")
            bTimedOut = true
        end
        return false
    end
end

function F_AcceptScenario()
    if PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        --print("SCENARIOACCEPTED")
        PedMakeMissionChar(ScenarioPed)
        DoSocialErrands(true, "AS_SD_OBJECTIVE")
        bOnMission = true
        F_MakePlayerSafeForNIS(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_IND_PACKGET", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_IND_PACKGET", true) do
            Wait(0)
        end
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        GiveItemToPlayer(521, 1)
        PedMakeMissionChar(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
        MissionTimerStart(timeLimit)
        gBlipSpazz = BlipAddXYZ(delX, delY, delZ, 1)
        bActive = true
        return true
    else
        if GetTimer() >= TimeOutTimer + TimeOutTime then
            --print("TIMED OUT!")
            SoundPlayAmbientSpeechEvent(ScenarioPed, "BYE")
            bTimedOut = true
        end
        --print("F_AcceptScenario FAILED!")
        return false
    end
end

function F_ScenarioGoals()
    if PlayerIsInAreaXYZ(delX, delY, delZ, 20, 0) then
        --print("WTF?!?!?")
        gSpazzMan = PedCreateXYZ(222, delX, delY, delZ)
        PedMakeMissionChar(gSpazzMan)
        PedSetPedToTypeAttitude(gSpazzMan, 13, 2)
        PedSetEmotionTowardsPed(gSpazzMan, gPlayer, 8)
        PedSetRequiredGift(gSpazzMan, 10, false, true)
        Receiver1Blip = AddBlipForChar(gSpazzMan, 9, 1, 4)
        return true
    elseif MissionTimerHasFinished() then
        bTimedOut = true
    else
        return false
    end
end

function F_MissionSpecificCheck()
    if PedIsValid(gSpazzMan) and not PedIsDead(gSpazzMan) then
        if PedIsInAreaObject(gPlayer, gSpazzMan, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
            BlipRemove(gBlipSpazz)
            --print("Ped has received gift!!")
            return true
        elseif MissionTimerHasFinished() then
            bTimedOut = true
        else
            return false
        end
    elseif PedIsValid(gSpazzMan) and PedIsDead(gSpazzMan) then
        bTimedOut = true
        return false
    else
        bTimedOut = true
        return false
    end
end

function F_ObjectiveMet()
    if PedIsInAreaObject(gPlayer, gSpazzMan, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        --print("OH WOW IT'S DONE!!")
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, gSpazzMan, 3)
        PedLockTarget(gSpazzMan, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_IND_PackMon", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_IND_PackMon", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(gSpazzMan, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        bActive = false
        DoSocialErrands(false)
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        MinigameSetErrandCompletion(40, "AS_COMPLETE", true, 2000)
        if Receiver1Blip ~= 0 then
            BlipRemove(Receiver1Blip)
            Receiver1Blip = 0
        end
        shared.gCurrentAmbientScenarioObject.completed = true
        return true
    else
        --print("Oh...no it's not...")
        return false
    end
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
            --print("WTF?!")
        end
    end
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        --print("THIS SHOULD BE RETURNING!")
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(40, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup    ========= Ambient Template")
    if PedIsValid(ScenarioPed) == true then
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedSetFlag(ScenarioPed, 110, false)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    ItemSetCurrentNum(521, 0)
    MissionTimerStop()
    if Receiver1Blip ~= 0 then
        BlipRemove(Receiver1Blip)
        Receiver1Blip = 0
    end
    if PedIsValid(gSpazzMan) == true then
        PedWander(gSpazzMan, 0)
        PedMakeAmbient(gSpazzMan)
    end
    BlipRemove(gBlipSpazz)
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
