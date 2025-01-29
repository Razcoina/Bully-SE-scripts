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
local peds = { 49 }
local bActive = false
local pX, pY, pZ = -586.9, -332.2, 0
local TPx, TPy, TPz = -766, -60.5, 12.4
local tpX, tpY, tpZ = -586.938, -334.375, 0
local TP = 0
local TPBlip = 0
local bOnMission = false
local ObjFlag = false
local MissionScenarioComplete1 = false
local MissionScenarioComplete2 = false
local bGiveHint = false
local bPlayerHasRoll = false
local gTPTimer = 0
local bTPTimerStarted = false
local bFailDueToLackOfRoll = false
local bShowedPickUpMessage = false

function main()
    --print("()xxxxx[:::::::::::::::> BOG ROLL 2 [start] main()")
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
        elseif MissionScenarioComplete1 == false then
            MissionScenarioComplete1 = F_MissionSpecificCheck1()
        elseif MissionScenarioComplete2 == false then
            MissionScenarioComplete2 = F_MissionSpecificCheck2()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
    --print("()xxxxx[:::::::::::::::> BOG ROLL 2 [finish] main()")
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_BR_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    ScenarioPed = PedCreatePOIPoint(49, POIInfo)
    if PedIsValid(ScenarioPed) then
        PedSetFlag(ScenarioPed, 110, true)
        PedSetPedToTypeAttitude(ScenarioPed, 13, 2)
        PedMoveToObject(ScenarioPed, gPlayer, 2, 1, nil, 2.5)
        PedMakeMissionChar(ScenarioPed)
        PedEnableGiftRequirement(ScenarioPed, false)
        PedSetStationary(ScenarioPed, true)
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        --print("()xxxxx[:::::::::::::::> BOG ROLL 2 - Create Ped")
        return true
    else
        return false
    end
    --print("()xxxxx[:::::::::::::::> BOG ROLL 2 [finish] F_ScenarioSetup()")
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

local bLockThePed = false

function F_OnDialog()
    if PedIsDoingTask(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 8, "generic", false, true)
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
        DoSocialErrands(true, "AS_BR_OBJECTIVE")
        PedSetStationary(ScenarioPed, true)
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
    AreaSetDoorLocked(TRIGGER._DT_ISCHOOL_JANITOR, false)
    AreaSetDoorLockedToPeds(TRIGGER._DT_ISCHOOL_JANITOR, true)
    TP = PickupCreateXYZ(403, TPx, TPy, TPz, "PermanentMission")
    TPBlip = BlipAddXYZ(TPx, TPy, TPz, 1, 1)
    return true
end

function F_MissionSpecificCheck1()
    if PlayerHasWeapon(403) then
        DoSocialErrands(true, "AS_BR_ACTION")
        BlipRemove(TPBlip)
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 1)
        bPlayerHasRoll = true
        return true
    else
        return false
    end
    return false
end

function F_MissionSpecificCheck2()
    if bPlayerHasRoll then
        if not PlayerHasWeapon(403) then
            BlipRemove(ScenarioPedBlip)
            MissionTimerStart(15)
            gTPTimer = GetTimer()
            bShowedPickUpMessage = false
            bTPTimerStarted = true
            bPlayerHasRoll = false
        end
    elseif PlayerHasWeapon(403) then
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 1)
        MissionTimerStop()
        if bGiveHint then
            DoSocialErrands(true, "AS_BR_HINT")
        else
            DoSocialErrands(true, "AS_BR_ACTION")
        end
        bTPTimerStarted = false
        bPlayerHasRoll = true
    end
    if bTPTimerStarted then
        if gTPTimer + 1000 < GetTimer() and not bShowedPickUpMessage then
            DoSocialErrands(true, "AS_BR_PICKUP")
            bShowedPickUpMessage = true
        end
        if gTPTimer + 15000 < GetTimer() then
            SoundPlayAmbientSpeechEvent(ScenarioPed, "DISGUST")
            MinigameSetErrandCompletion(3, "AS_BR_FAIL", false)
            bFailDueToLackOfRoll = true
        end
    end
    if PedIsInAreaObject(gPlayer, ScenarioPed, 2, 5, 0) and not bGiveHint then
        DoSocialErrands(true, "AS_BR_HINT")
        bGiveHint = true
    end
    if ObjectFindInArea(tpX, tpY, tpZ, 1.75) then
        return true
    else
        return false
    end
    return false
end

function F_ObjectiveMet()
    SoundPlayAmbientSpeechEvent(ScenarioPed, "THANKS_JIMMY")
    Wait(1000)
    DoSocialErrands(false)
    MinigameSetErrandCompletion(3, "AS_COMPLETE", true, 1500)
    shared.gCurrentAmbientScenarioObject.completed = true
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    PedSetScenarioObjFlag(ScenarioPed, true)
    bOnMission = false
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    return true
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
        end
    end
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and (AreaGetVisible() == 2 or AreaGetVisible() == 8) and OutOfRange == false and bFailDueToLackOfRoll == false then
        if PlayerIsInAreaXYZ(pX, pY, pZ, 1, 0) and PedIsFacingObject(gPlayer, ScenarioPed, 2, 60) and not bLockThePed then
            --print("==== Locking On Bog Ped ====")
            PedLockTarget(gPlayer, ScenarioPed, 3)
            bLockThePed = true
        elseif (not PlayerIsInAreaXYZ(pX, pY, pZ, 1, 0) or not PedIsFacingObject(gPlayer, ScenarioPed, 2, 60)) and bLockThePed then
            --print("==== UnLocking Bog Ped ====")
            PedLockTarget(gPlayer, -1)
            bLockThePed = false
        end
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(3, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    --print("()xxxxx[:::::::::::::::> BOGROLL 2 [start] F_ScenarioCleanup()")
    MissionTimerStop()
    DoSocialErrands(false)
    BlipRemove(TPBlip)
    if AreaGetVisible() == 2 then
        AreaSetDoorLocked(TRIGGER._DT_ISCHOOL_JANITOR, true)
    end
    if PedIsValid(ScenarioPed) == true then
        BlipRemoveFromChar(ScenarioPed)
        PedLockTarget(gPlayer, -1)
        PedMakeAmbient(ScenarioPed, false)
        PedSetFlag(ScenarioPed, 110, false)
        PedClearPOI(ScenarioPed)
    end
    if PlayerHasWeapon(403) then
        PedDestroyWeapon(gPlayer, 403)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
    PickupRemoveAll(403)
    AreaClearAllProjectiles(403)
    --print("()xxxxx[:::::::::::::::>  BOGROLL 2 [finish] F_ScenarioCleanup()")
end
