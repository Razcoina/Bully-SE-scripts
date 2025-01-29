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
local peds = { 4 }
local bActive = false
local ObjFlag = false
local MissionScenarioComplete = false
local bAlgieFollows = false
local bPlayerAtLibrary = false
local areax, areay, areaz = 187.075, -150.907, 7.76629
local libX, libY, libZ = 187.673, -158.085, 8.25457
local libraryBlip = 0
local bTakeMeHome = false
local AcceptScenario = false

function main()
    --print("()xxxxx[:::::::::::::::> ALGIE ESCORT [start] main()")
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
    --print("()xxxxx[:::::::::::::::> ALGIE ESCORT [finish] main()")
end

function F_ScenarioSetup()
    --print("()xxxxx[:::::::::::::::> ALGIE ESCORT [start] F_ScenarioSetup()")
    DoSocialErrands(false, "AS_AE_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(4, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(4, POIInfo)
        if PedIsValid(ScenarioPed) then
            PedMakeAmbient(ScenarioPed, false)
        end
    else
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
        PedEnableGiftRequirement(ScenarioPed, false)
    end
    if PedIsValid(ScenarioPed) then
        --print("========================== ScenarioPed is Valid")
        PedSetFlag(ScenarioPed, 110, true)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 2)
        PedMoveToObject(ScenarioPed, gPlayer, 2, 1, nil, 2)
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        return true
    else
        return false
    end
    --print("()xxxxx[:::::::::::::::> ALGIE ESCORT [finish] F_ScenarioSetup()")
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 37, "generic", false, true)
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
        DoSocialErrands(true, "AS_AE_OBJECTIVE")
        PedSetStationary(ScenarioPed, true)
        bOnMission = true
        BlipRemove(ScenarioPedBlip)
        bActive = true
        bTakeMeHome = true
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
    return true
end

function F_MissionSpecificCheck()
    if PedIsInAreaXYZ(ScenarioPed, areax, areay, areaz, 5, 0) then
        BlipRemove(libraryBlip)
        return true
    elseif not bPlayerAtLibrary and PlayerIsInAreaXYZ(areax, areay, areaz, 5, 0) then
        if not PedIsInAreaObject(gPlayer, ScenarioPed, 2, 8, 0) then
            DoSocialErrands(true, "AS_AE_WAIT")
            bPlayerAtLibrary = true
            return false
        end
    else
        if bAlgieFollows and not PlayerIsInAreaObject(ScenarioPed, 2, 8, 0) then
            PedDismissAlly(gPlayer, ScenarioPed)
            PedStop(ScenarioPed)
            PedSetStationary(ScenarioPed, true)
            DoSocialErrands(true, "AS_AE_LOST")
            bAlgieFollows = false
            BlipRemove(libraryBlip)
            blipAlgie = AddBlipForChar(ScenarioPed, 0, 1, 4, 0)
        elseif not bAlgieFollows and PlayerIsInAreaObject(ScenarioPed, 2, 4, 0) then
            PedSetStationary(ScenarioPed, false)
            PedRecruitAlly(gPlayer, ScenarioPed, false)
            DoSocialErrands(true, "AS_AE_OBJECTIVE")
            bAlgieFollows = true
            BlipRemove(blipAlgie)
            libraryBlip = BlipAddXYZ(186.9, -154.7, 8.2, 1, 1, 0)
        end
        return false
    end
    return false
end

function F_ObjectiveMet()
    SoundPlayAmbientSpeechEvent(ScenarioPed, "THANKS_JIMMY")
    if bAlgieFollows then
        PedDismissAlly(gPlayer, ScenarioPed)
    end
    DoSocialErrands(false)
    MinigameSetErrandCompletion(1, "AS_COMPLETE", true, 1500)
    PedMoveToXYZ(ScenarioPed, 1, libX, libY)
    PedMakeAmbient(ScenarioPed)
    BlipRemove(ScenarioPedBlip)
    bAlgieFollows = false
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    PedClearPOI(ScenarioPed)
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
    if PedIsValid(ScenarioPed) == true and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        if not bTakeMeHome and PedGetFlag(ScenarioPed, 110) == false then
            return false
        end
        if bActive and F_PedIsDead(ScenarioPed) then
            bTimedOut = true
        end
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(1, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    --print("()xxxxx[:::::::::::::::> ALGIE ESCORT [start] F_ScenarioCleanup()")
    DoSocialErrands(false)
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        PedSetStationary(ScenarioPed, false)
        BlipRemove(ScenarioPedBlip)
        PedWander(ScenarioPed, 0)
    end
    if bAlgieFollows and PedHasAlly(gPlayer) then
        PedDismissAlly(gPlayer, ScenarioPed)
    end
    BlipRemove(ScenarioPedBlip)
    BlipRemove(libraryBlip)
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
    --print("()xxxxx[:::::::::::::::> ALGIE ESCORT [finish] F_ScenarioCleanup()")
end
