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
local peds = {
    42,
    26,
    28
}
local bActive = false
local Greaser1 = -1
local Greaser2 = -1
local GreaserBlip1 = 0
local GreaserBlip2 = 0
local Greaser1Egged = false
local Greaser2Egged = false
local bEgged = false
local EggingComplete = false
local bPranking = false
local bOutOfAmmo = false
local nOutOfAmmoGracePeriod
local ObjFlag = false
local bKilledGreasers = false

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
        elseif EggingComplete == false then
            EggingComplete = F_EggCheck()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_EI_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    ScenarioPed = PedFindAmbientPedOfModelID(42, 40)
    if ScenarioPed == -1 then
        LoadWeaponModels({ 312 })
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(42, POIInfo)
    else
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
        PedEnableGiftRequirement(ScenarioPed, false)
    end
    if PedIsValid(ScenarioPed) then
        PedMakeAmbient(ScenarioPed, false)
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
    if bPranking then
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 78, "generic", false, true)
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
        PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PlayerSetWeapon(312, 6)
        DoSocialErrands(true, "AS_EI_OBJECTIVE")
        bPranking = true
        BlipRemove(ScenarioPedBlip)
        ScenarioPedBlip = 0
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
    Greaser1 = PedCreateXYZ(26, 214.743, -371.495, 2.63845)
    Greaser2 = PedCreateXYZ(28, 215.078, -373.027, 2.64038)
    if PedIsValid(Greaser1) and PedIsValid(Greaser2) then
        PedMakeMissionChar(Greaser1)
        PedMakeMissionChar(Greaser2)
        PedSetHealth(Greaser1, PedGetHealth(Greaser1) * 2)
        PedSetHealth(Greaser2, PedGetHealth(Greaser2) * 2)
        GreaserBlip1 = AddBlipForChar(Greaser1, 4, 1, 4)
        GreaserBlip2 = AddBlipForChar(Greaser2, 4, 1, 4)
        BlipSetFlashing(GreaserBlip1)
        BlipSetFlashing(GreaserBlip2)
        PedSetEmotionTowardsPed(Greaser2, Greaser1, 7, true)
        PedSetEmotionTowardsPed(Greaser1, Greaser2, 7, true)
        PedSetWantsToSocializeWithPed(Greaser2, Greaser1)
        PedSetWantsToSocializeWithPed(Greaser1, Greaser2)
        return true
    else
        return false
    end
end

function F_EggCheck()
    --print("F_EggCheck")
    if PedIsValid(Greaser1) == true and PedGetLastHitWeapon(Greaser1) == 312 then
        Greaser1Egged = true
        PedMakeAmbient(Greaser1)
        if GreaserBlip1 ~= 0 then
            BlipRemove(GreaserBlip1)
            GreaserBlip1 = 0
        end
    end
    if Greaser1 and PedIsValid(Greaser1) and PedIsDead(Greaser1) or Greaser2 and PedIsValid(Greaser2) and PedIsDead(Greaser2) then
        bKilledGreasers = true
        return true
    end
    if PedIsValid(Greaser2) == true and PedGetLastHitWeapon(Greaser2) == 312 then
        Greaser2Egged = true
        PedMakeAmbient(Greaser2)
        if GreaserBlip2 ~= 0 then
            BlipRemove(GreaserBlip2)
            GreaserBlip2 = 0
        end
    end
    if Greaser1Egged == true and Greaser2Egged == true then
        bEgged = true
        return true
    elseif not Greaser1Egged or not Greaser2Egged then
        if PedGetAmmoCount(gPlayer, 312) == 0 then
            if not nOutOfAmmoGracePeriod then
                nOutOfAmmoGracePeriod = GetTimer()
            elseif GetTimer() - nOutOfAmmoGracePeriod > 2500 then
                bOutOfAmmo = true
                return true
            end
            return false
        end
        return false
    else
        return false
    end
end

function F_ObjectiveMet()
    if bEgged then
        Wait(2000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(15, "AS_COMPLETE", true, 3000)
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 60000
        shared.gCurrentAmbientScenarioObject.completed = true
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(ScenarioPed)
        return true
    elseif bOutOfAmmo then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(15, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 15000
        shared.gCurrentAmbientScenarioObject.completed = false
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(ScenarioPed)
        return true
    elseif bKilledGreasers then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(15, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 15000
        shared.gCurrentAmbientScenarioObject.completed = false
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
            MinigameSetErrandCompletion(15, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ================ Egg Greasers")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if PedIsValid(Greaser1) == true then
        PedMakeAmbient(Greaser1)
        BlipRemove(GreaserBlip1)
    end
    if PedIsValid(Greaser2) == true then
        PedMakeAmbient(Greaser2)
        BlipRemove(GreaserBlip2)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
