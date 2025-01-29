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
local peds = {
    69,
    34,
    40
}
local bActive = false
local Prep1 = -1
local Prep2 = -1
local PrepBlip1 = 0
local PrepBlip2 = 0
local counter = 999
local ObjFlag = false
local MissionScenarioComplete = false

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
    DoSocialErrands(false, "AS_AT_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    ScenarioPed = PedCreatePOIPoint(69, POIInfo)
    if PedIsValid(ScenarioPed) then
        PedMakeAmbient(ScenarioPed, false)
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
        PedMakeMissionChar(ScenarioPed)
        PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        BlipRemove(ScenarioPedBlip)
        DoSocialErrands(true, "AS_AT_OBJECTIVE")
        bActive = true
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
    Prep1 = PedCreateXYZ(34, 203.36, -40.4, 6.72)
    Prep2 = PedCreateXYZ(40, 202.26, -40.33, 6.72)
    if PedIsValid(Prep1) and PedIsValid(Prep2) then
        --print("Preps Created")
        PedMakeMissionChar(Prep1)
        PedMakeMissionChar(Prep2)
        PrepBlip1 = AddBlipForChar(Prep1, 5, 1, 4)
        PrepBlip2 = AddBlipForChar(Prep2, 5, 1, 4)
        BlipSetFlashing(PrepBlip1)
        BlipSetFlashing(PrepBlip2)
        PedSetEmotionTowardsPed(Prep2, Prep1, 7, true)
        PedSetEmotionTowardsPed(Prep1, Prep2, 7, true)
        PedSetWantsToSocializeWithPed(Prep2, Prep1)
        PedSetWantsToSocializeWithPed(Prep1, Prep2)
        return true
    else
        return false
    end
end

function F_MissionSpecificCheck()
    if not ObjFlag then
        PedSetScenarioObjFlag(ScenarioPed, true)
        ObjFlag = true
    elseif PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted", false) then
        return true
    else
        return false
    end
end

function F_ObjectiveMet()
    TextAddParamNum(counter)
    PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
    Wait(2000)
    DoSocialErrands(false)
    MinigameSetErrandCompletion(0, "AS_COMPLETE", true, 500)
    shared.gCurrentAmbientScenarioObject.completed = true
    return true
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
        end
    end
    if PedIsValid(ScenarioPed) == true and PedHasPOI(ScenarioPed) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(-1, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
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
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if PedIsValid(Prep1) == true then
        PedMakeAmbient(Prep1)
        BlipRemove(PrepBlip1)
    end
    if PedIsValid(Prep2) == true then
        PedMakeAmbient(Prep2)
        BlipRemove(PrepBlip2)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
