POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local GoalsCreated = false
local ObjectiveMet = false
local AcceptScenario = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = { 86, 47 }
local vehicles = { 273 }
local bActive = false
local Dropout1 = -1
local Dropout2 = -1
local DropoutBlip1 = 0
local DropoutBlip2 = 0
local d1x, d1y, d1z = 591.2, -18.1, 6.5
local d2x, d2y, d2z = 504.9, -161.9, 4.9
local b1x, b1y, b1z = 590.4, -20, 6.4
local b2x, b2y, b2z = 506.6, -162.2, 4.9
local r1x, r1y, r1z = 0, 0, 0
local Bike01 = 0
local Bike02 = 0
local bBike01Returned = false
local bBike02Returned = false
local bPlayerGotBike = false
local ObjFlag = false
local MissionScenarioComplete = false
local bDumped = false

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
    DoSocialErrands(false, "AS_BG_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadVehicleModels(vehicles)
    ScenarioPed = PedFindAmbientPedOfModelID(86, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(86, POIInfo)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 142, "generic", false, true)
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
        DoSocialErrands(true, "AS_BG_OBJECTIVE")
        r1x, r1y, r1z = PedGetPosXYZ(ScenarioPed)
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
    Dropout1 = PedCreateXYZ(47, d1x, d1y, d1z)
    Bike01 = VehicleCreateXYZ(273, b1x, b1y, b1z)
    if PedIsValid(Dropout1) then
        --print("Dropouts Created")
        PedMakeMissionChar(Dropout1)
        DropoutBlip1 = AddBlipForChar(Dropout1, 2, 1, 4)
        BlipSetFlashing(DropoutBlip1)
        VehicleSetOwner(Bike01, gPlayer)
        PedPutOnBike(Dropout1, Bike01)
        Wait(1000)
        PedWander(Dropout1, 1)
        return true
    else
        return false
    end
end

function F_MissionSpecificCheck()
    local x, y, z = PedGetOffsetInWorldCoords(ScenarioPed, 0, 1.25, 0)
    if bBike01Returned then
        return true
    else
        if not bBike01Returned then
            if VehicleIsValid(Bike01) then
                local bx, by, bz = VehicleGetPosXYZ(Bike01)
                if bz <= 0 then
                    bTimedOut = true
                    return
                end
            end
            if PlayerIsInVehicle(Bike01) then
                if PlayerIsInAreaXYZ(x, y, z, 3, 7) and PedIsInAreaObject(ScenarioPed, Bike01, 1, 4, 0) and not bToldToGetOff and PlayerIsInVehicle(Bike01) then
                    DoSocialErrands(true, "AS_BG_OFFBIKE")
                    bToldToGetOff = true
                end
            elseif bPlayerGotBike then
                if not PlayerIsInVehicle(Bike01) and PedIsInAreaObject(ScenarioPed, Bike01, 1, 4, 0) then
                    DoSocialErrands(true, "AS_BG_ACTION")
                    bBike01Returned = true
                    bToldToGetOff = false
                    VehicleSetOwner(Bike01, ScenarioPed)
                elseif not PlayerIsInVehicle(Bike01) and not PedIsInAreaObject(ScenarioPed, Bike01, 1, 4, 0) and bToldToGetOff then
                    DoSocialErrands(true, "AS_BG_OBJECTIVE")
                    bToldToGetOff = false
                end
            end
            if PlayerIsInVehicle(Bike01) and not bPlayerGotBike then
                bPlayerGotBike = true
            end
            if not PedIsInVehicle(Dropout1, Bike01) and not bDumped then
                bDumped = true
                BlipRemoveFromChar(Dropout1)
                ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
            end
        end
        return false
    end
end

function F_ObjectiveMet()
    VehicleSetOwner(Bike01, ScenarioPed)
    DoSocialErrands(false)
    MinigameSetErrandCompletion(4, "AS_COMPLETE", true, 1500)
    SoundPlayAmbientSpeechEvent(ScenarioPed, "THANKS_JIMMY")
    BlipRemove(ScenarioPedBlip)
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    PedClearPOI(ScenarioPed)
    shared.gCurrentAmbientScenarioObject.completed = true
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 480000
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
            MinigameSetErrandCompletion(4, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup   ========= Get Bikes")
    if PedIsValid(ScenarioPed) == true then
        PedLockTarget(ScenarioPed, -1)
        PedClearPOI(ScenarioPed)
        PedSetFlag(ScenarioPed, 110, false)
        if ObjectiveMet then
            VehicleMakeAmbient(Bike01)
            PedIgnoreStimuli(ScenarioPed, true)
            PedEnterVehicle(ScenarioPed, Bike01)
            while not PedIsInVehicle(ScenarioPed, Bike01) do
                --print("==== Waiting for Tobias to get on bike =====")
                Wait(0)
            end
            PedMakeAmbient(ScenarioPed)
        else
            PedMakeAmbient(ScenarioPed)
            PedWander(ScenarioPed, 0)
        end
        BlipRemove(ScenarioPedBlip)
    end
    if PedIsValid(Dropout1) == true then
        PedMakeAmbient(Dropout1)
        BlipRemove(DropoutBlip1)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
