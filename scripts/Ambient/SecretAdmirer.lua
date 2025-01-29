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
local peds = { 70 }
local bActive = false
local Gloria = -1
local LockerBlip = 0
local ValentinePlanted = false
local LockPicked = false
local LockerUnlocked = false
local LockerOpened = false
local LockerOpen = false
local Locker_x, Locker_y, Locker_z = -659.578, -305.082, 0.0330002
local bPlayerWasGivenChocolates = false

function main()
    --print("()xxxxx[:::::::::::::::> SECRET ADMIRER [start] main()")
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
        elseif LockPicked == false then
            LockPicked = F_CheckLockerUnlocked()
        elseif ReturnComplete == false then
            ReturnComplete = F_ReturnCheck()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
    --print("()xxxxx[:::::::::::::::> SECRET ADMIRER [finish] main()")
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_SA_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(70, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(70, POIInfo)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 55, "generic", false, true)
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
        DoSocialErrands(true, "AS_SA_OBJECTIVE")
        PedSetStationary(ScenarioPed, true)
        bOnMission = true
        F_MakePlayerSafeForNIS(true)
        PlayerSetControl(0)
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_SCH_ADMIRE1", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_SCH_ADMIRE1", true) do
            Wait(0)
        end
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        GiveItemToPlayer(478)
        bPlayerWasGivenChocolates = true
        PlayerSetControl(1)
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
    if LockerBlip == 0 then
        PAnimSetActionNode(TRIGGER._NLOCK01B05, "/Global/NLockA/Locked", "Global/Props/NLockA.act")
        LockerBlip = BlipAddXYZ(Locker_x, Locker_y, Locker_z, 1, 1)
        BlipSetFlashing(LockerBlip)
    end
    if PlayerIsInAreaXYZ(Locker_x, Locker_y, Locker_z, 1, 0) and PAnimIsPlaying(TRIGGER._NLOCK01B05, "/Global/NLockA/Locked", false) then
        shared.gLockpickStartingFunction = F_PlayerStartedPicking()
        return true
    else
        if PlayerIsInAreaXYZ(Locker_x, Locker_y, Locker_z, 2, 0) and not PAnimIsPlaying(TRIGGER._NLOCK01B05, "/Global/NLockA/Locked", false) then
            PAnimSetActionNode(TRIGGER._NLOCK01B05, "/Global/NLockA/Locked", "Global/Props/NLockA.act")
        end
        return false
    end
    return false
end

function F_PlayerStartedPicking()
    while not (LockerUnlocked or F_PedIsDead(ScenarioPed)) do
        local x, y, z = PlayerGetPosXYZ()
        if DistanceBetweenCoords3d(x, y, z, Locker_x, Locker_y, Locker_z) < 1 then
            if MinigameIsReady() and shared.gLockpickSuccessFunction == nil then
                shared.gLockpickFailureFunction = F_PlayerFailedToPickLocker
                shared.gLockpickSuccessFunction = F_PlayerPickLocker
            end
        else
            shared.gLockpickFailureFunction = nil
            shared.gLockpickSuccessFunction = nil
        end
        if F_PedIsDead(gPlayer) then
            break
        end
        Wait(0)
    end
end

function F_PlayerFailedToPickLocker()
    LockerUnlocked = false
end

function F_PlayerPickLocker()
    LockerUnlocked = true
    PlayerClearRewardStore()
end

function F_LockpickingRewardPlayer()
end

function F_CheckLockerUnlocked()
    if LockerUnlocked == true then
        --print("Locker has been UNLOCKED!")
        PAnimSetActionNode(TRIGGER._NLOCK01B05, "/Global/NLockA/Unlocked", "Act/Props/NLockA.act")
        if LockerBlip ~= 0 then
            BlipRemove(LockerBlip)
            LockerBlip = 0
        end
        Wait(2000)
        bPlayerWasGivenChocolates = false
        if 0 < ItemGetCurrentNum(478) then
            ItemSetCurrentNum(478, ItemGetCurrentNum(478) - 1)
        end
        PedSetScenarioObjFlag(ScenarioPed, true)
        return true
    else
        return false
    end
    return false
end

function F_ReturnCheck()
    return true
end

function F_ObjectiveMet()
    --print("========================== F_ObjectiveMet")
    DoSocialErrands(false)
    MinigameSetErrandCompletion(33, "AS_COMPLETE", true, 1000)
    PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
    PedClearPOI(ScenarioPed)
    shared.gCurrentAmbientScenarioObject.completed = true
    shared.gCurrentAmbientScenarioObject.time = GetTimer() + 60000
    return true
end

function F_CheckConditions()
    if DialogComplete == false then
        OutOfRange = F_PlayerOutOfRange()
        if OutOfRange == true and PedIsValid(ScenarioPed) and PedIsOnScreen(ScenarioPed) == false then
            PedDelete(ScenarioPed)
        end
    end
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(ScenarioPed) == false and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and F_CheckIfPlayerHasChocolates() == true and shared.gBusTransition == nil and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(33, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ================ Secret Admirer")
    if PedIsValid(ScenarioPed) == true then
        PedWander(ScenarioPed, 0)
        PedSetFlag(ScenarioPed, 110, false)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    BlipRemove(LockerBlip)
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end

function F_CheckIfPlayerHasChocolates()
    if bPlayerWasGivenChocolates and not PlayerHasItem(478) and not F_PedIsDead(gPlayer) then
        --print("()xxxxx[:::::::::::::::> SECRET ADMIRER - PLAYER HAS 0 CHOCOLATES")
        MinigameSetErrandCompletion(33, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        return false
    end
    return true
end
