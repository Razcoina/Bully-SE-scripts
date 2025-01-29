POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local AcceptScenario = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local GoalsCreated = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = { 138, 146 }
local bActive = false
local gBear = 0
local gBully = -1
local PrepBlip1 = 0
local gBlipBear = 0
local counter = 999
local ObjFlag = false
local MissionScenarioComplete = false
local bullyX, bullyY, bullyZ = 254.3, 241.5, 0.3

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
    DoSocialErrands(false, "AS_LB_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    while not RequestModel(363) do
        Wait(0)
    end
    ScenarioPed = PedFindAmbientPedOfModelID(138, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(138, POIInfo)
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

function F_PlayerLeftArea()
    if not PlayerIsInTrigger(TRIGGER._ZONERICH) then
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 44, "generic", false, true)
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
        DoSocialErrands(true, "AS_LB_OBJECTIVE")
        PedSetRequiredGift(ScenarioPed, 21, false, true)
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
    gBully = PedCreateXYZ(146, bullyX, bullyY, bullyZ)
    PedSetPedToTypeAttitude(gBully, 13, 0)
    if PedIsValid(gBully) then
        PedMakeMissionChar(gBully)
        gBlipBear = AddBlipForChar(gBully, 6, 1, 4)
        PedSetWeaponNow(gBully, 363, 1, false)
        BlipSetFlashing(gBlipBear)
        return true
    else
        return false
    end
end

function F_MissionSpecificCheck()
    if not ObjFlag and PlayerHasWeapon(363) then
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        BlipRemove(gBlipBear)
        DoSocialErrands(true, "AS_LB_RETURN")
        gPlayerHasBear = true
        ObjFlag = true
        return true
    else
        return false
    end
end

function F_ObjectiveMet()
    if gPlayerHasBear and not PlayerHasWeapon(363) then
        DoSocialErrands(true, "AS_LB_OBJECTIVE")
        gBearTimer = true
        gPlayerHasBear = false
        if ScenarioPedBlip then
            BlipRemove(ScenarioPedBlip)
            ScenarioPedBlip = nil
        end
        local x, y, z = PlayerGetPosXYZ()
        gBlipBear = BlipAddXYZ(x, y, z, 1, 4)
        MissionTimerStart(10)
    elseif not gPlayerHasBear and PlayerHasWeapon(363) then
        if gBlipBear then
            BlipRemove(gBlipBear)
            gBlipBear = nil
        end
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        gPlayerHasBear = true
        MissionTimerStop()
        gBearTimer = false
        DoSocialErrands(true, "AS_LB_RETURN")
    end
    if gBearTimer and MissionTimerHasFinished() then
        MissionTimerStop()
        gFailed = true
    end
    if PedIsInAreaObject(gPlayer, ScenarioPed, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_RIC_LostBear", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_RIC_LostBear", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(24, "AS_COMPLETE", true, 1500)
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        shared.gCurrentAmbientScenarioObject.completed = true
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
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
    leftArea = F_PlayerLeftArea()
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and leftArea == false and shared.gBusTransition == nil and OutOfRange == false then
        if gFailed then
            if bActive and not F_PedIsDead(gPlayer) then
                MinigameSetErrandCompletion(24, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            end
            return false
        end
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(24, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup    ========= Ambient Template")
    if PedIsValid(ScenarioPed) == true then
        PedWander(ScenarioPed, 0)
        PedSetFlag(ScenarioPed, 110, false)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if PedIsValid(gBully) == true then
        PedMakeAmbient(gBully)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 240000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
