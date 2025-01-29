POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local AcceptScenario = false
local GoalsCreated = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = { 66 }
local bActive = false
local bOnMission = false
local ObjFlag = false
local bReturn = false
local MissionScenarioComplete = false
local toiletX, toiletY, toiletZ = -583.6, -335.3, 0
local bToiletBlipped = false
local gFailureTimer = 0
local bStartedFailureTimer = false
local bPlayerWasGivenCherryBomb = false

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
    DoSocialErrands(false, "AS_CH_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(66, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(66, POIInfo)
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
    if bOnMission then
        if AreaGetVisible() ~= 2 then
            shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
            return true
        else
            return false
        end
    elseif DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() == true then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 82, "generic", false, true)
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
        DoSocialErrands(true, "AS_CH_OBJECTIVE")
        PedSetStationary(ScenarioPed, true)
        bOnMission = true
        PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PlayerSetWeapon(301, PedGetAmmoCount(gPlayer, 301) + 1)
        bPlayerWasGivenCherryBomb = true
        BlipRemove(ScenarioPedBlip)
        blipToilet = BlipAddXYZ(toiletX, toiletY, toiletZ, 1, 4, 0)
        bToiletBlipped = true
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
    return true
end

function F_MissionSpecificCheck()
    if PedIsPlaying(gPlayer, "/Global/Toilet/PedPropsActions/Use/CherryBomb/LightBomb/Drop/BombInToilet", false) and not bReturn then
        if not bReturn then
            if bToiletBlipped then
                BlipRemove(blipToilet)
                bToiletBlipped = false
            end
            bPlayerWasGivenCherryBomb = false
            Wait(2000)
            DoSocialErrands(false, "AS_CH_ACTION")
            Wait(2000)
            bReturn = true
            PedSetScenarioObjFlag(ScenarioPed, true)
            return true
        end
    else
        return false
    end
    return false
end

function cbReturn()
    bReturn = true
end

function F_ObjectiveMet()
    --print("F_ObjectiveMet ===================== Cherry Toilet")
    DoSocialErrands(false)
    MinigameSetErrandCompletion(8, "AS_COMPLETE", true, 1000)
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    shared.gCurrentAmbientScenarioObject.completed = true
    bOnMission = false
    PedSetScenarioObjFlag(ScenarioPed, true)
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    PedClearPOI(ScenarioPed)
    PedSetFlag(ScenarioPed, 110, false)
    return true
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
        end
    end
    if PedIsValid(ScenarioPed) == true and PedGetWhoHitMeLast(ScenarioPed) ~= gPlayer and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and F_CheckIfPlayerHasCherryBomb() == true and shared.gBusTransition == nil and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(8, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup ========= Cherry Toilet")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedSetStationary(ScenarioPed, false)
        PedClearObjectives(ScenarioPed)
        PedClearPOI(ScenarioPed)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if bToiletBlipped then
        BlipRemove(blipToilet)
        bToiletBlipped = false
    end
    if PedIsValid(Prep1) == true then
        PedMakeAmbient(Prep1)
        BlipRemove(PrepBlip1)
    end
    if PedIsValid(Prep2) == true then
        PedMakeAmbient(Prep2)
        BlipRemove(PrepBlip2)
    end
    if ObjectiveMet ~= false or shared.gCurrentAmbientScenarioObject ~= nil then
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end

function F_CheckIfPlayerHasCherryBomb()
    if bPlayerWasGivenCherryBomb and not PlayerHasItem(301) then
        if not bStartedFailureTimer then
            gFailureTimer = GetTimer()
            bStartedFailureTimer = true
        elseif gFailureTimer + 5000 < GetTimer() and not F_PedIsDead(gPlayer) then
            MinigameSetErrandCompletion(8, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            return false
        end
    end
    return true
end
