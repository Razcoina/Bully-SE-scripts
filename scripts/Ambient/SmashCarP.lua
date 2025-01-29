POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local GoalsCreated = false
local ObjectiveMet = false
local ReturnComplete = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = { 27 }
local weapons = { 300 }
local bActive = false
local car_damaged = false
local c_damage01 = false
local c_damage02 = false
local c_damage03 = false
local c_damage04 = false
local c_damage05 = false
local c_damage06 = false
local c_damage07 = false
local c_damage08 = false
local c_damage09 = false
local c_damage10 = false
local c_damage11 = false
local c_damage12 = false
local c_damage13 = false
local c_damage14 = false
local c_damage15 = false
local bNoDamage = true
local damagePoint = 0
local car = {}
local timeLimit = 120
local bTimeNotSet = true
local ObjFlag = false
local MissionScenarioComplete = false
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
        elseif ReturnComplete == false then
            ReturnComplete = F_ReturnCheck()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_SC_OBJECTIVE")
    --print("F_ScenarioSetup ====== Smash Cars")
    OutOfRange = F_PlayerOutOfRange()
    while not VehicleRequestModel(286) do
        Wait(0)
    end
    ScenarioPed = PedFindAmbientPedOfModelID(27, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(27, POIInfo)
        if PedIsValid(ScenarioPed) then
            PedMakeAmbient(ScenarioPed, false)
        end
    else
        PedMakeAmbient(ScenarioPed, false)
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
    end
    LoadWeaponModels(weapons)
    while not VehicleRequestModel(286) do
        Wait(0)
    end
    car = {
        point = POINTLIST._PO_SMASHCAR,
        id = 0,
        blip = 0,
        model = 286
    }
    if PedIsValid(ScenarioPed) then
        PedMakeAmbient(ScenarioPed, false)
        PedSetFlag(ScenarioPed, 110, true)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 2)
        PedMoveToObject(ScenarioPed, gPlayer, 2, 1, nil, 2)
        local x, y, z = GetPointList(car.point)
        if not VehicleFindInAreaXYZ(x, y, z, 3, false) then
            car.id = VehicleCreatePoint(car.model, car.point)
        else
            local tblCars = {}
            tblCars = VehicleFindInAreaXYZ(x, y, z, 3, false)
            for c, carcar in tblCars do
                if VehicleIsValid(carcar) and VehicleIsModel(carcar, car.model) then
                    --print("================== Deleting Found Car")
                    VehicleDelete(carcar)
                    break
                end
            end
            --print("================== Creating New Car")
            car.id = VehicleCreatePoint(car.model, car.point)
        end
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 0, 1, 4)
        return true
    else
        return false
    end
end

function F_CheckCarForModel(carcar)
    if VehicleIsValid(carcar) then
        if VehicleIsModel(carcar, car.model) then
            return true
        else
            return false
        end
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 11, "generic", false, true)
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
        DoSocialErrands(true, "AS_SC_OBJECTIVE")
        bOnMission = true
        PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PlayerSetWeapon(300, 1, false)
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
    if car.id == 0 then
        return false
    else
        if bTimeNotSet then
            MissionTimerStart(timeLimit)
            bTimeNotSet = false
        end
        car.blip = AddBlipForCar(car.id, 1, 1)
        return true
    end
end

function F_MissionSpecificCheck()
    if not MissionTimerHasFinished() then
        if not car_damaged then
            F_DamageCar(car.id)
            return false
        else
            MissionTimerStop()
            if damagePoint == 0 then
                bNoDamage = true
            else
                bNoDamage = false
            end
            return true
        end
    else
        MissionTimerStop()
        if damagePoint < 11 then
            bNoDamage = true
        else
            bNoDamage = false
        end
        return true
    end
    return false
end

function F_ReturnCheck()
    return true
end

function F_ObjectiveMet()
    if not bNoDamage then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(38, "AS_COMPLETE", true, 2500)
        shared.gCurrentAmbientScenarioObject.completed = true
    elseif bNoDamage then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(38, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        shared.gCurrentAmbientScenarioObject.completed = false
    end
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    PedClearPOI(ScenarioPed)
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
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
            MinigameSetErrandCompletion(38, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup ======================  Smash Car P")
    MissionTimerStop()
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    BlipRemove(car.blip)
    if VehicleIsValid(car.id) then
        VehicleMakeAmbient(car.id, false)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end

function F_DamageCar(car)
    if CarGetDamageNumber(car) == 1 and not c_damage01 then
        c_damage01 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 2 and not c_damage02 then
        c_damage02 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 3 and not c_damage03 then
        c_damage03 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 4 and not c_damage04 then
        c_damage04 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 5 and not c_damage05 then
        c_damage05 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 6 and not c_damage06 then
        c_damage06 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 7 and not c_damage07 then
        c_damage07 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 8 and not c_damage08 then
        c_damage08 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 9 and not c_damage09 then
        c_damage09 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 10 and not c_damage10 then
        c_damage10 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 11 and not c_damage11 then
        c_damage11 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 12 and not c_damage12 then
        c_damage12 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 13 and not c_damage13 then
        c_damage13 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 14 and not c_damage14 then
        c_damage14 = true
        damagePoint = damagePoint + 1
    end
    if CarGetDamageNumber(car) == 15 and not c_damage15 then
        c_damage15 = true
        damagePoint = damagePoint + 1
    end
    if damagePoint == 11 then
        car_damaged = true
    end
    DoSocialErrands(true, "AS_SC_OBJCOUNT", damagePoint)
end
