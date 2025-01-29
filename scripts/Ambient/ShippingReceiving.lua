POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local AcceptScenario = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = {
    236,
    195,
    132,
    144
}
local bActive = false
local Receiver1 = -1
local Receiver1Blip = 0
local Receiver1Created = false
local Receiver1GotPackage = false
local Receiver2 = -1
local Receiver2Blip = 0
local Receiver2Created = false
local Receiver2GotPackage = false
local Receiver3 = -1
local Receiver3Blip = 0
local Receiver3Created = false
local Receiver3GotPackage = false
local r1x, r1y, r1z = 219.966, -446.661, 2.89284
local r2x, r2y, r2z = 196.198, -342.434, 2.27184
local r3x, r3y, r3z = 133.801, -299.202, 1.0947

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
        elseif Receiver1Created == false then
            Receiver1Created = F_SetupReceiver1()
        elseif Receiver1GotPackage == false then
            Receiver1GotPackage = F_CheckGotPackage1()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_SR_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(195, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(195, POIInfo)
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
        PlayerSetControl(0)
        PedSetActionNode(ScenarioPed, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        GiveItemToPlayer(521, 1)
        PlayerSetControl(1)
        DoSocialErrands(true, "AS_SR_OBJECTIVE")
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

function F_SetupReceiver1()
    --print("F_SetupReceiver1")
    Receiver1 = PedCreateXYZ(236, r1x, r1y, r1z)
    if PedIsValid(Receiver1) then
        PedMakeMissionChar(Receiver1)
        PedSetPedToTypeAttitude(Receiver1, 13, 2)
        PedSetEmotionTowardsPed(Receiver1, gPlayer, 8)
        Receiver1Blip = AddBlipForChar(Receiver1, 9, 1, 4)
        --print("F_SetupReceiver1 END")
        return true
    else
        --print("F_SetupReceiver1 END")
        return false
    end
    --print("F_SetupReceiver1 END")
    return true
end

function F_CheckGotPackage1()
    --print("F_CheckGotPackage1 CHECKING")
    if PedIsInAreaObject(gPlayer, Receiver1, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, Receiver1, 3)
        PedLockTarget(Receiver1, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_IND_Package", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_IND_Package", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(Receiver1, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        DoSocialErrands(true, "AS_SR_ACTION")
        PedWander(Receiver1, 0)
        PedMakeAmbient(Receiver1)
        if PedHasAlly(gPlayer) and PedGetAllyFollower(gPlayer) == Receiver1 then
            PedDismissAlly(gPlayer, Receiver1)
        end
        if Receiver1Blip ~= 0 then
            BlipRemove(Receiver1Blip)
            Receiver1Blip = 0
        end
        return true
    else
        return false
    end
end

function F_SetupReceiver2()
    LoadPedModels({ 132 })
    if PedIsValid(Receiver2) then
        PedMakeMissionChar(Receiver2)
        PedSetPedToTypeAttitude(Receiver2, 13, 2)
        PedSetEmotionTowardsPed(Receiver2, gPlayer, 8)
        GiveItemToPlayer(521)
        PedSetRequiredGift(Receiver2, 10)
        Receiver2Blip = AddBlipForChar(Receiver2, 9, 1, 4)
        Wait(2000)
        DoSocialErrands(true, "AS_SR_OBJECTIVE")
        return true
    else
        return false
    end
    return true
end

function F_CheckGotPackage2()
    if PedIsInAreaObject(gPlayer, Receiver2, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, Receiver2, 3)
        PedLockTarget(Receiver2, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_IND_Package", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_IND_Package", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(Receiver2, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        DoSocialErrands(true, "AS_SR_ACTION")
        PedWander(Receiver2, 0)
        PedMakeAmbient(Receiver2)
        if Receiver2Blip ~= 0 then
            BlipRemove(Receiver2Blip)
            Receiver2Blip = 0
        end
        return true
    else
        return false
    end
end

function F_SetupReceiver3()
    local x, y, z = 79.84, -307.72, 0.93
    Receiver3 = PedCreateXYZ(144, r3x, r3y, r3z)
    if PedIsValid(Receiver3) then
        PedMakeMissionChar(Receiver3)
        PedSetPedToTypeAttitude(Receiver3, 13, 2)
        PedSetEmotionTowardsPed(Receiver3, gPlayer, 8)
        GiveItemToPlayer(521)
        PedSetRequiredGift(Receiver3, 10)
        Receiver3Blip = AddBlipForChar(Receiver3, 9, 1, 4)
        Wait(2000)
        DoSocialErrands(true, "AS_SR_OBJECTIVE")
        return true
    else
        return false
    end
    return true
end

function F_CheckGotPackage3()
    if PedIsInAreaObject(gPlayer, Receiver3, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, Receiver3, 3)
        PedLockTarget(Receiver3, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_IND_Package", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_IND_Package", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(Receiver3, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        DoSocialErrands(true, "AS_SR_ACTION")
        PedWander(Receiver3, 0)
        PedMakeAmbient(Receiver3)
        if Receiver3Blip ~= 0 then
            BlipRemove(Receiver3Blip)
            Receiver3Blip = 0
        end
        return true
    else
        return false
    end
end

function F_ObjectiveMet()
    --print("F_ObjectiveMet")
    DoSocialErrands(false)
    MinigameSetErrandCompletion(35, "AS_COMPLETE", true, 3000)
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
            MinigameSetErrandCompletion(35, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ========= Shipping and Receiving")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    ItemSetCurrentNum(521, 0)
    if PedIsValid(Receiver1) == true then
        PedWander(Receiver1, 0)
        PedMakeAmbient(Receiver1)
        BlipRemove(Receiver1Blip)
        Receiver1Blip = 0
    end
    if PedIsValid(Receiver2) == true then
        PedWander(Receiver2, 0)
        PedMakeAmbient(Receiver2)
        BlipRemove(Receiver2Blip)
    end
    if PedIsValid(Receiver3) == true then
        PedWander(Receiver3, 0)
        PedMakeAmbient(Receiver3)
        BlipRemove(Receiver3Blip)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
