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
local peds = { 67, 70 }
local bActive = false
local px, py, pz = 456.692, -196.303, 3.2213
local dx, dy, dz = 446.703, -199.183, 3.33832
local bx, by, bz = 446.703, -199.183, 3.33832
local gBlipGirlsDorm = -1
local gBoyFriend = -1
local ObjFlag = false
local bTakeMeHome = false
local MissionScenarioComplete = false
local bChristyFollows = false
local bPlayerAtGirlsDorm = false
local gChristyChatterTimer = 0
local gChristyChatterBuffer = 20000

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
    DoSocialErrands(false, "AS_GE_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    ScenarioPed = PedFindAmbientPedOfModelID(67, 40)
    if ScenarioPed == -1 then
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(67, POIInfo)
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
    if bTakeMeHome then
        return false
    elseif DistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2) > AreaGetPopulationCullDistance() then
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 48, "generic", false, true)
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
        DoSocialErrands(true, "AS_GE_OBJECTIVE")
        bTakeMeHome = true
        bOnMission = true
        BlipRemove(ScenarioPedBlip)
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
    gBoyFriend = PedCreateXYZ(70, bx, by, bz)
    return true
end

function F_MissionSpecificCheck()
    if PedIsInAreaXYZ(ScenarioPed, px, py, pz, 5, 0, 1) then
        BlipRemove(gBlipGirlsDorm)
        BlipRemove(ScenarioPedBlip)
        PedStop(ScenarioPed)
        PedClearObjectives(ScenarioPed)
        PedMakeAmbient(ScenarioPed)
        PedDismissAlly(gPlayer, ScenarioPed)
        return true
    elseif not bPlayerAtGirlsDorm and PlayerIsInAreaXYZ(px, py, pz, 5, 0) then
        if not PedIsInAreaObject(gPlayer, ScenarioPed, 2, 8, 0) then
            DoSocialErrands(true, "AS_TH_WAIT")
            bPlayerAtGirlsDorm = true
            return false
        end
    else
        if GetTimer() > gChristyChatterTimer + gChristyChatterBuffer then
            SoundPlayAmbientSpeechEvent(ScenarioPed, "CONVERSATION_GOSSIP")
            gChristyChatterTimer = GetTimer()
        end
        if bChristyFollows and not PlayerIsInAreaObject(ScenarioPed, 2, 8, 0) then
            PedDismissAlly(gPlayer, ScenarioPed)
            PedStop(ScenarioPed)
            PedSetStationary(ScenarioPed, true)
            DoSocialErrands(true, "AS_TH_LOST")
            bChristyFollows = false
            BlipRemove(gBlipGirlsDorm)
            blipChristy = AddBlipForChar(ScenarioPed, 0, 1, 4, 0)
        elseif not bChristyFollows and PlayerIsInAreaObject(ScenarioPed, 2, 4, 0) then
            PedSetStationary(ScenarioPed, false)
            PedRecruitAlly(gPlayer, ScenarioPed, true)
            DoSocialErrands(true, "AS_GE_OBJECTIVE")
            bChristyFollows = true
            BlipRemove(blipChristy)
            gBlipGirlsDorm = BlipAddXYZ(px, py, pz, 1)
        end
        return false
    end
    return false
end

function F_ObjectiveMet()
    SoundPlayAmbientSpeechEvent(ScenarioPed, "THANKS_JIMMY")
    Wait(1000)
    PedMoveToXYZ(ScenarioPed, 1, dx, dy, 6, 0.3, true)
    DoSocialErrands(false)
    MinigameSetErrandCompletion(20, "AS_COMPLETE", true, 3000)
    PedSetScenarioObjFlag(ScenarioPed, true)
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
        if not bTakeMeHome and PedGetFlag(ScenarioPed, 110) == false then
            return false
        end
        if bActive and PedIsDead(ScenarioPed) and not F_PedIsDead(gPlayer) then
            MinigameSetErrandCompletion(20, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            return false
        end
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not bChristyFollows and not F_PedIsDead(gPlayer) then
            MinigameSetErrandCompletion(20, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(20, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ================ Girl Escort")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        if not ObjectiveMet then
            if PedHasAllyFollower(gPlayer) then
                local ped = PedGetAllyFollower(gPlayer)
                PedDismissAlly(gPlayer, ped)
            end
            PedWander(ScenarioPed, 0)
        end
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if PedIsValid(gBoyFriend) == true then
        PedMakeAmbient(gBoyFriend)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
