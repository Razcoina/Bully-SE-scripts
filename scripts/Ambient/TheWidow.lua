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
local peds = { 185 }
local bActive = false
local FlowersBlip = 0
local GraveBlip = 0
local flowerPickup = 0
local gTotalFlowersBroken = 0
local GotFlowers = false
local FlowersOnGrave = false
local bFlowerDrop = false
local gTotalFlowersRequired = 6
local Flowers = 0
local gFlowersLeft = gTotalFlowersRequired
local flowers_x, flowers_y, flowers_z = 555.69, 382.21, 17.12
local grave_x, grave_y, grave_z = 651.58, 181.62, 18.72

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
        elseif GotFlowers == false then
            GotFlowers = F_FlowerPickup()
        elseif FlowersOnGrave == false then
            FlowersOnGrave = F_CheckFlowersNearGrave()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_TW_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    if ScenarioPed == -1 then
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(185, POIInfo)
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
        Flowers = ItemGetCurrentNum(475)
        gFlowersLeft = gTotalFlowersRequired - Flowers
        if gFlowersLeft < 0 then
            gFlowersLeft = 0
        end
        if gFlowersLeft == 1 then
            DoSocialErrands(true, "AS_TW_OBJCOUNT1", gFlowersLeft)
        else
            DoSocialErrands(true, "AS_TW_OBJCOUNT", gFlowersLeft)
        end
        SoundStopCurrentSpeechEvent(gPlayer)
        SoundPlayScriptedSpeechEvent(gPlayer, "M_2_G2", 8, "speech")
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
    F_CreateFlowers()
    Wait(4000)
    return true
end

function F_CreateFlowers()
    while not WeaponRequestModel(359) do
        Wait(0)
    end
    tblFlowers = {
        {
            hash = 0,
            blip = 0,
            x = 553.728,
            y = 381.58,
            z = 17.0988,
            object = "trich_DPE_FlowersA39",
            destroyed = false
        },
        {
            hash = 0,
            blip = 0,
            x = 553.677,
            y = 383.847,
            z = 17.2397,
            object = "trich_DPE_FlowersA41",
            destroyed = false
        },
        {
            hash = 0,
            blip = 0,
            x = 556.434,
            y = 386.373,
            z = 17.3288,
            object = "trich_DPE_FlowersA42",
            destroyed = false
        },
        {
            hash = 0,
            blip = 0,
            x = 556.387,
            y = 388.642,
            z = 17.1797,
            object = "trich_DPE_FlowersA43",
            destroyed = false
        },
        {
            hash = 0,
            blip = 0,
            x = 556.391,
            y = 394.387,
            z = 16.8339,
            object = "trich_DPE_FlowersA44",
            destroyed = false
        },
        {
            hash = 0,
            blip = 0,
            x = 556.342,
            y = 396.652,
            z = 16.9281,
            object = "trich_DPE_FlowersA45",
            destroyed = false
        }
    }
    for i, entry in tblFlowers do
        entry.blip = BlipAddXYZ(entry.x, entry.y, entry.z, 1)
    end
end

function OnObjectBrokenCallback(HashID, ModelPoolIndex)
    for i, entry in tblFlowers do
        if entry.hash == HashID and not entry.destroyed then
            entry.destroyed = true
            gTotalFlowersBroken = gTotalFlowersBroken + 1
            entry.hash = PickupCreateXYZ(475, entry.x, entry.y, entry.z)
            DoSocialErrands(true, "AS_TW_ACTION")
            BlipRemove(entry.blip)
            break
        end
    end
end

function F_FlowerPickup()
    if ItemGetCurrentNum(475) >= gTotalFlowersRequired then
        for i, entry in tblFlowers do
            BlipRemove(entry.blip)
        end
        DoSocialErrands(true, "AS_TW_GRAVE")
        GraveBlip = BlipAddXYZ(grave_x, grave_y, grave_z, 1, 4)
        return true
    else
        Flowers = ItemGetCurrentNum(475)
        gFlowersLeft = gTotalFlowersRequired - Flowers
        if gFlowersLeft < 0 then
            gFlowersLeft = 0
        end
        if gFlowersLeft == 1 then
            DoSocialErrands(true, "AS_TW_OBJCOUNT1", gFlowersLeft)
        else
            DoSocialErrands(true, "AS_TW_OBJCOUNT", gFlowersLeft)
        end
        return false
    end
end

function F_CheckFlowersNearGrave()
    if PlayerIsInAreaXYZ(grave_x, grave_y, grave_z, 1.5, 7) then
        TextPrint("AS_TW_BUTDISPL", 0.5, 3)
        if IsButtonPressed(9, 0) then
            local flowersLeft = ItemGetCurrentNum(475) - 6
            if flowersLeft < 0 then
                flowersLeft = 0
            end
            ItemSetCurrentNum(475, flowersLeft)
            BlipRemove(GraveBlip)
            GraveBlip = 0
            PickupDestroyTypeInAreaXYZ(grave_x, grave_y, grave_z, 2, 359)
            PickupCreateXYZ(359, grave_x, grave_y, grave_z, "PermanentMission")
            return true
        end
        return false
    elseif not bFlowerDrop and PlayerIsInAreaXYZ(grave_x, grave_y, grave_z, 1.5, 7) then
        bFlowerDrop = true
        DoSocialErrands(true, "AS_TW_DROP")
        return false
    else
        return false
    end
end

function F_ObjectiveMet()
    DoSocialErrands(false)
    MinigameSetErrandCompletion(49, "AS_COMPLETE", true, 1500)
    shared.gCurrentAmbientScenarioObject.completed = true
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
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(49, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ========= The Widow")
    CounterMakeHUDVisible(false)
    CounterSetCurrent(0)
    CounterSetMax(0)
    CounterClearText()
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    PickupDestroyTypeInAreaXYZ(flowers_x, flowers_y, flowers_z, 20, MODELENUM._STEMROSE)
    PickupDestroyTypeInAreaXYZ(grave_x, grave_y, grave_z, 20, 359)
    if FlowersBlip ~= 0 then
        BlipRemove(FlowersBlip)
    end
    if GraveBlip ~= 0 then
        BlipRemove(GraveBlip)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
