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
local peds = { 42 }
local bActive = false
local ObjFlag = false
local MissionScenarioComplete = false
local bOnMission = false
local timeLimit = 120
local bTimeNotSet = true
local bNoneTagged = false
local totalTags = 0
local goalTags = 3
local downCount = goalTags
local tblTags = {}
local AcceptScenario = false

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
    DoSocialErrands(false, "AS_TP_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(42, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(42, POIInfo)
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
        tblTags = {
            {
                id = TRIGGER._POORAREA_MEDIUM_001,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_002,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_003,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_004,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_005,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_006,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_007,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_008,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_009,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_010,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_011,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_012,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_013,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_014,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_015,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_016,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_017,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_018,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_019,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_020,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_021,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_022,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_023,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_024,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_025,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_026,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_027,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_028,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_029,
                tagged = false
            },
            {
                id = TRIGGER._POORAREA_MEDIUM_030,
                tagged = false
            }
        }
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
        if AreaGetVisible() ~= 0 then
            return true
        else
            return false
        end
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 77, "generic", false, true)
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
        DoSocialErrands(true, "AS_TP_OBJCOUNT", downCount)
        bOnMission = true
        PlayerSetControl(0)
        PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PlayerSetWeapon(321, 100)
        PlayerSetControl(1)
        BlipRemove(ScenarioPedBlip)
        bActive = true
        shared.gMonitorTags = true
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

local bPlayerStartedTagging = false
local bPlayerAbortedTagging = false
local bPlayerFinishdTagging = false

function F_CheckForTagging()
    if shared.gMonitoredTag then
        for i, tag in tblTags do
            if not tag.tagged and tag.id == shared.gMonitoredTag then
                tag.tagged = true
                totalTags = totalTags + 1
                downCount = downCount - 1
                if downCount == 1 then
                    DoSocialErrands(true, "AS_TP_OBJCOUNT1", downCount)
                    break
                end
                DoSocialErrands(true, "AS_TP_OBJCOUNT", downCount)
                break
            end
        end
        shared.gMonitoredTag = false
    end
end

function F_PlayerTagged()
    return PedIsPlaying(gPlayer, "/Global/Tags/PedPropsActions/PerformTag/PedDrawMedTag/TagSuccess", false)
end

function F_GreaserTagged(tag)
    local x, y, z = GetAnchorPosition(tag)
    if PlayerIsInAreaXYZ(x, y, z, 2, 0) and PAnimIsPlaying(tag, "/Global/Tags/NotUseable/Tagged/", false) then
        return true
    else
        return false
    end
end

function F_MissionSpecificCheck()
    if totalTags == goalTags then
        return true
    else
        F_CheckForTagging()
        return false
    end
end

function F_ObjectiveMet()
    if totalTags == 0 then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(43, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
    else
        DoSocialErrands(false)
        MinigameSetErrandCompletion(43, "AS_COMPLETE", true, 2500)
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 240000
        shared.gCurrentAmbientScenarioObject.completed = true
    end
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
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and PedIsDead(ScenarioPed) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(43, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ================ Tag Poor")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    shared.gMonitorTags = false
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
