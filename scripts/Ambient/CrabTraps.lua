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
local spawnX, spawnY, spawnZ = 0, 0, 0
local peds = { 144 }
local bActive = false
local T_Crabs = {}
local GotCrabs = false
local NumCrabsReceived = 0
local timeLimit = 180
local bTimeNotSet = true
local bNotEnoughCrabs = false
local somecrabs = 6
local CashPerCrab = 50

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
        elseif GotCrabs == false then
            GotCrabs = F_CheckGotCrabs()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_CT_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    ScenarioPed = PedFindAmbientPedOfModelID(144, 40)
    if ScenarioPed == -1 then
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(144, POIInfo)
        if PedIsValid(ScenarioPed) then
            PedMakeAmbient(ScenarioPed, false)
        end
    else
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
        PedEnableGiftRequirement(ScenarioPed, false)
    end
    if PedIsValid(ScenarioPed) then
        spawnX, spawnY, spawnZ = PedGetPosXYZ(ScenarioPed)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 2)
        PedSetFlag(ScenarioPed, 110, true)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 2, "generic", false, true)
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
        DoSocialErrands(true, "AS_CT_OBJCOUNT", 6)
        BlipRemove(ScenarioPedBlip)
        PedSetRequiredGift(ScenarioPed, 7, false, true)
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
    T_Crabs = {
        {
            id = 0,
            blip = 0,
            x_coord = 211.617,
            y_coord = 194.986,
            z_coord = -0.25,
            received = false
        },
        {
            id = 0,
            blip = 0,
            x_coord = 172.067,
            y_coord = 236.336,
            z_coord = -0.25,
            received = false
        },
        {
            id = 0,
            blip = 0,
            x_coord = 164.729,
            y_coord = 193.971,
            z_coord = -0.25,
            received = false
        },
        {
            id = 0,
            blip = 0,
            x_coord = 183.855,
            y_coord = 170.736,
            z_coord = -0.25,
            received = false
        },
        {
            id = 0,
            blip = 0,
            x_coord = 189.164,
            y_coord = 274.544,
            z_coord = -0.25,
            received = false
        },
        {
            id = 0,
            blip = 0,
            x_coord = 220.95,
            y_coord = 151.8,
            z_coord = -0.25,
            received = false
        }
    }
    for i, crab in T_Crabs do
        crab.id = PickupCreateXYZ(523, crab.x_coord, crab.y_coord, crab.z_coord, "PermanentMission")
        crab.blip = BlipAddXYZ(crab.x_coord, crab.y_coord, crab.z_coord, 1, 1)
    end
    if bTimeNotSet then
        MissionTimerStart(timeLimit)
        bTimeNotSet = false
    end
    return true
end

function F_CheckGotCrabs()
    if not MissionTimerHasFinished() then
        for i, crab in T_Crabs do
            if crab.received == false and PickupIsPickedUp(crab.id) == true then
                crab.received = true
                NumCrabsReceived = NumCrabsReceived + 1
                somecrabs = somecrabs - 1
                if somecrabs ~= 1 then
                    DoSocialErrands(true, "AS_CT_OBJCOUNT", somecrabs)
                else
                    DoSocialErrands(true, "AS_CT_OBJCOUNT1", somecrabs)
                end
                if crab.blip ~= 0 then
                    BlipRemove(crab.blip)
                    crab.blip = 0
                end
            end
        end
        if NumCrabsReceived == table.getn(T_Crabs) then
            DoSocialErrands(true, "AS_CT_RETURN")
            ScenarioPedBlip = AddBlipForChar(ScenarioPed, 9, 1, 1)
            bNotEnoughCrabs = false
            return true
        else
            bNotEnoughCrabs = true
        end
        return false
    elseif MissionTimerHasFinished() then
        return true
    end
end

function F_ObjectiveMet()
    if not MissionTimerHasFinished() then
        if PedIsInAreaObject(gPlayer, ScenarioPed, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
            F_MakePlayerSafeForNIS(true)
            CameraSetWidescreen(true)
            PlayerSetControl(0)
            F_PlayerDismountBike()
            PedLockTarget(gPlayer, ScenarioPed, 3)
            PedLockTarget(ScenarioPed, gPlayer, 3)
            PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_RIC_Crab", "Act/Player.act")
            while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_RIC_Crab", true) do
                Wait(0)
            end
            CameraSetWidescreen(false)
            PedLockTarget(gPlayer, -1)
            PedLockTarget(ScenarioPed, -1)
            CameraReturnToPlayer()
            PlayerSetControl(1)
            F_MakePlayerSafeForNIS(false)
            local cash = CashPerCrab * NumCrabsReceived
            DoSocialErrands(false)
            MinigameSetErrandCompletion(9, "AS_COMPLETE", true, 2000)
            ItemSetCurrentNum(523, 0)
            shared.gCurrentAmbientScenarioObject.completed = true
            shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
            bNotEnoughCrabs = false
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
            PedClearPOI(ScenarioPed)
            bActive = false
            return true
        else
            bNotEnoughCrabs = true
            return false
        end
    elseif MissionTimerHasFinished() then
        if bNotEnoughCrabs and not shared.gCurrentAmbientScenarioObject.completed and not F_PedIsDead(gPlayer) then
            DoSocialErrands(false)
            MinigameSetErrandCompletion(9, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
            PedClearPOI(ScenarioPed)
        end
        return true
    end
    return false
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
            MinigameSetErrandCompletion(9, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup   ========= Crab Traps")
    MissionTimerStop()
    if not shared.gCurrentAmbientScenarioObject.completed then
        ItemSetCurrentNum(523, 0)
    end
    if PedIsValid(ScenarioPed) == true then
        PedClearPOI(ScenarioPed)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
        PedSetFlag(ScenarioPed, 110, false)
    end
    for i, crab in T_Crabs do
        if crab.received == false then
            PickupDelete(crab.id)
        end
        BlipRemove(crab.blip)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
