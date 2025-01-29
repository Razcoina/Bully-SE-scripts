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
local AcceptScenario = false
local peds = { 107 }
local bActive = false
local ScenarioBlip
local oX, oY, oZ = 581.211, -457.705, 4.46429
local runX, runY, runZ = 584.498, -458.092, 5.447

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
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_HH_OBJECTIVE")
    --print("F_ScenarioSetup")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    ScenarioPed = PedFindAmbientPedOfModelID(107, 40)
    if ScenarioPed == -1 then
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(107, POIInfo)
        if PedIsValid(ScenarioPed) then
            PedMakeAmbient(ScenarioPed, false)
        end
    else
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
        PedEnableGiftRequirement(ScenarioPed, false)
    end
    if PedIsValid(ScenarioPed) then
        PedSetFlag(ScenarioPed, 110, true)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 2)
        PedSetStationary(ScenarioPed, true)
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        return true
    else
        return false
    end
end

function F_PlayerOutOfRange()
    local x1, y1, z1 = POIGetPosXYZ(POIInfo)
    local x2, y2, z2 = PlayerGetPosXYZ()
    if DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() then
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 1, "generic", false, true)
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
        PedMakeMissionChar(ScenarioPed)
        DoSocialErrands(true, "AS_HH_OBJECTIVE")
        PedSetStationary(ScenarioPed, false)
        BlipRemove(ScenarioPedBlip)
        ScenarioBlip = BlipAddXYZ(oX, oY, oZ, 1, 1)
        PedRecruitAlly(gPlayer, ScenarioPed, true)
        bLadyFollows = true
        bActive = true
        gLadyChatterTimer = GetTimer()
        return true
    else
        if GetTimer() >= TimeOutTimer + TimeOutTime then
            SoundPlayAmbientSpeechEvent(ScenarioPed, "BYE")
            bTimedOut = true
        end
        return false
    end
end

function F_ScenarioGoals()
    if GetTimer() > gLadyChatterTimer + 25000 then
        SoundPlayAmbientSpeechEvent(ScenarioPed, "CONVERSATION_GOSSIP")
        gLadyChatterTimer = GetTimer()
    end
    if bLadyFollows and not PlayerIsInAreaObject(ScenarioPed, 2, 8, 0) then
        PedDismissAlly(gPlayer, ScenarioPed)
        PedStop(ScenarioPed)
        PedSetStationary(ScenarioPed, true)
        DoSocialErrands(true, "AS_HH_TOFAR")
        bLadyFollows = false
        BlipRemove(ScenarioBlip)
        ScenarioBlip = nil
        blipOldLady = AddBlipForChar(ScenarioPed, 0, 1, 4, 0)
    elseif not bLadyFollows and PlayerIsInAreaObject(ScenarioPed, 2, 4, 0) then
        PedSetStationary(ScenarioPed, false)
        PedRecruitAlly(gPlayer, ScenarioPed, true)
        DoSocialErrands(true, "AS_HH_OBJECTIVE")
        bLadyFollows = true
        ScenarioBlip = BlipAddXYZ(oX, oY, oZ, 1, 1)
        BlipRemove(blipOldLady)
        blipOldLady = nil
    end
    if PedIsInAreaXYZ(ScenarioPed, oX, oY, oZ, 3, 7) then
        return true
    end
    return false
end

function F_ObjectiveMet()
    DoSocialErrands(false)
    MinigameSetErrandCompletion(21, "AS_COMPLETE", true, 4000)
    SoundPlayAmbientSpeechEvent(ScenarioPed, "THANKS_JIMMY")
    PedMoveToXYZ(ScenarioPed, 1, runX, runY)
    shared.gCurrentAmbientScenarioObject.completed = true
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    PedClearPOI(ScenarioPed)
    return true
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
        end
    end
    if PedIsValid(ScenarioPed) == true and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        if not bActive then
            if PedGetFlag(ScenarioPed, 110) == false then
                --print("RETURNED IN THE CRAZY ADDED PART ")
                return false
            end
        elseif PedIsDead(ScenarioPed) or PedGetWhoHitMeLast(ScenarioPed) == gPlayer and not F_PedIsDead(gPlayer) then
            MinigameSetErrandCompletion(21, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            return false
        end
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(21, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ========= Homeless Help")
    CounterMakeHUDVisible(false)
    CounterSetCurrent(0)
    CounterSetMax(0)
    CounterClearText()
    if PedHasAlly(gPlayer) then
        local ped = PedGetAllyFollower(gPlayer)
        PedDismissAlly(gPlayer, ped)
    end
    if PedIsValid(ScenarioPed) == true then
        PedSetStationary(ScenarioPed, false)
        PedSetFlag(ScenarioPed, 110, false)
        if not ObjectiveMet then
            PedWander(ScenarioPed, 0)
        end
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if blipOldLady then
        BlipRemove(blipOldLady)
    end
    if ScenarioBlip ~= 0 then
        BlipRemove(ScenarioBlip)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
