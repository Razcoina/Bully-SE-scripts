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
local peds = { 157 }
local bActive = false
local TrashDestroyed = false
local T_TrashCans = {}
local NumDestroyedCans = 0
local gPills = 0
local CashPerPillBottle = 100

function main()
    while SetupComplete == false do
        if OutOfRange == true or POIInfo == nil then
            SetupComplete = true
        else
            SetupComplete = F_ScenarioSetup()
            --print("=======SetupComplete====", tostring(SetupComplete))
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
        elseif TrashDestroyed == false then
            TrashDestroyed = F_CheckTrashDamage()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_ED_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(157, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(157, POIInfo)
        if PedIsValid(ScenarioPed) then
            PedMakeAmbient(ScenarioPed, false)
        end
    else
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
        PedEnableGiftRequirement(ScenarioPed, false)
    end
    if PedIsValid(ScenarioPed) and AreaGetVisible() == 0 then
        PedEnableGiftRequirement(ScenarioPed, false)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 3, "generic", false, true)
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
        BlipRemove(ScenarioPedBlip)
        DoSocialErrands(true, "AS_ED_OBJECTIVE")
        PedSetRequiredGift(ScenarioPed, 8, false, true)
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
    T_TrashCans = {
        {
            blip = 0,
            trigger = TRIGGER._EASYDRUGS_TRASH01,
            destroyed = false,
            drugs = false,
            created = false
        },
        {
            blip = 0,
            trigger = TRIGGER._EASYDRUGS_TRASH02,
            destroyed = false,
            drugs = false,
            created = false
        },
        {
            blip = 0,
            trigger = TRIGGER._EASYDRUGS_TRASH03,
            destroyed = false,
            drugs = false,
            created = false
        },
        {
            blip = 0,
            trigger = TRIGGER._EASYDRUGS_TRASH04,
            destroyed = false,
            drugs = false,
            created = false
        },
        {
            blip = 0,
            trigger = TRIGGER._EASYDRUGS_TRASH05,
            destroyed = false,
            drugs = false,
            created = false
        },
        {
            blip = 0,
            trigger = TRIGGER._EASYDRUGS_TRASH06,
            destroyed = false,
            drugs = false,
            created = false
        }
    }
    while AreaIsLoading() do
        Wait(0)
    end
    if AreaGetVisible() ~= 0 then
        return false
    end
    for t, trash in T_TrashCans do
        if AreaTriggerIsValid(trash.trigger) then
            while not (AreaGetVisible() ~= 0 or PAnimRequest(trash.trigger)) do
                Wait(0)
                if AreaGetVisible() ~= 0 then
                    return false
                end
                if not AreaTriggerIsValid(trash.trigger) then
                    return false
                end
            end
            trash.created = true
        else
            bTimedOut = true
            return false
        end
    end
    for i, trashCan in T_TrashCans do
        trashCan.id = PAnimCreate(trashCan.trigger, true)
        local x, y, z = GetAnchorPosition(trashCan.trigger)
        trashCan.blip = BlipAddXYZ(x, y, z, 1, 1)
    end
    return true
end

function F_CheckTrashDamage()
    for i, trashCan in T_TrashCans do
        if PAnimIsDestroyed(trashCan.trigger) == true and trashCan.destroyed == false then
            trashCan.destroyed = true
            NumDestroyedCans = NumDestroyedCans + 1
            BlipRemove(trashCan.blip)
            local yes = math.random(1, 2)
            if yes == 1 or i == table.getn(T_TrashCans) then
                local x, y, z = GetAnchorPosition(trashCan.trigger)
                gPills = PickupCreateXYZ(522, x, y, z + 0.5, "PermanentMission")
            end
            Wait(100)
        end
    end
    if gPills ~= 0 then
        if PickupIsPickedUp(gPills) then
            for t, trashCan in T_TrashCans do
                BlipRemove(trashCan.blip)
            end
            DoSocialErrands(true, "AS_ED_RETURN")
            ScenarioPedBlip = AddBlipForChar(ScenarioPed, 9, 1, 1)
            return true
        else
            return false
        end
    else
        return false
    end
end

function F_ObjectiveMet()
    if PedIsInAreaObject(gPlayer, ScenarioPed, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_BUS_Drugs", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_BUS_Drugs", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        ItemSetCurrentNum(522, 0)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(12, "AS_COMPLETE", true, 1500)
        shared.gCurrentAmbientScenarioObject.completed = true
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 480000
        PedSetScenarioObjFlag(ScenarioPed, true)
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(ScenarioPed)
        bActive = false
        return true
    else
        return false
    end
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
        end
    end
    if PedIsValid(ScenarioPed) == true and AreaGetVisible() == 0 and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(12, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup ========= Easy Drugs")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    ItemSetCurrentNum(522, 0)
    if AreaGetVisible() == 0 then
        for i, trashCan in T_TrashCans do
            if trashCan.destroyed == false and trashCan.created == true then
                PAnimDelete(trashCan.trigger)
            end
        end
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    DATUnload(2)
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
