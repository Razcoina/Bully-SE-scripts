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
local peds = { 127, 141 }
local bActive = false
local p1x, p1y, p1z = 367.129, 450.287, 22.785
local p2x, p2y, p2z = 440.01, 546.968, 26.5469
local p3x, p3y, p3z = 538.323, 448.387, 18.0158
local thePackage = 0
local bGotAPackage = false
local MailDelivered = false
local tblPackage = {
    {
        id = 0,
        blip = 0,
        x = 367.129,
        y = 450.287,
        z = 22.785,
        bGotten = false
    }
}
local CurrentPackage = 3
local gMailmanModelStatus = 0

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
        elseif MailDelivered == false then
            MailDelivered = F_CheckPackagesDelivered()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_MM_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    gMailmanModelStatus = PedGetUniqueModelStatus(127)
    PedSetUniqueModelStatus(127, 0)
    LoadPedModels(peds)
    ScenarioPed = PedFindAmbientPedOfModelID(127, 40)
    if ScenarioPed == -1 then
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(127, POIInfo)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 5, "generic", false, true)
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
        DoSocialErrands(true, "AS_MM_OBJECTIVE")
        BlipRemove(ScenarioPedBlip)
        PedSetRequiredGift(ScenarioPed, 10, false, true)
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
    for p, package in tblPackage do
        package.id = PickupCreateXYZ(521, package.x, package.y, package.z, "PermanentMission")
        Wait(100)
        package.blip = BlipAddXYZ(package.x, package.y, package.z, 1, 4)
        thePackage = package.id
    end
    return true
end

function F_CheckPackagesDelivered()
    if not bGotAPackage then
        for p, package in tblPackage do
            if PickupIsPickedUp(package.id) then
                package.bGotten = true
                CurrentPackage = CurrentPackage - 1
                BlipRemove(package.blip)
                DoSocialErrands(true, "AS_MM_OBJCOUNT", CurrentPackage)
                break
            end
        end
        if CurrentPackage == 0 then
            bGotAPackage = true
            ScenarioPedBlip = AddBlipForChar(ScenarioPed, 9, 1)
            DoSocialErrands(true, "AS_MM_RETURN")
            return true
        end
        return false
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
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_RIC_Mailman", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_RIC_Mailman", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        bActive = false
        DoSocialErrands(false)
        MinigameSetErrandCompletion(48, "AS_COMPLETE", true, 2000)
        ItemSetCurrentNum(521, 0)
        shared.gCurrentAmbientScenarioObject.completed = true
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(ScenarioPed)
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
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and shared.gBusTransition == nil and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(48, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ========= The Mailman")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    ItemSetCurrentNum(521, 0)
    PedSetUniqueModelStatus(127, gMailmanModelStatus)
    for i, package in tblPackage do
        if package.id ~= 0 and not package.bGotten then
            PickupDelete(package.id)
        end
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
