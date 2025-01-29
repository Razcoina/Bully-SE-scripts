POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local SetupComplete = false
local OutOfRange = false
local AcceptScenario = false
local GreetingComplete = false
local DialogComplete = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = {
    149,
    86,
    76,
    144
}
local bActive = false
local Receiver1 = -1
local Receiver1Blip = 0
local Receiver1Created = false
local Receiver1GotDelivery = false
local Receiver2 = -1
local Receiver2Blip = 0
local Receiver2Created = false
local Receiver2GotDelivery = false
local Receiver3 = -1
local Receiver3Blip = 0
local Receiver3Created = false
local Receiver3GotDelivery = false
local bPlayerPimped = false
local timeLimit = 45
local bTimesUp = false
local deliveryTotal = 3
local gFinishedTask = false
local playerDefault = {
    startPosition = nil,
    startOnBike = false,
    bike = { model = 273, location = nil },
    weapon = { model = nil, ammo = 0 },
    currentTarget = nil,
    clothing = {
        outfit_HashId = nil,
        head_model = 0,
        head_txd = 0,
        left_wrist_model = 0,
        left_wrist_txd = 0,
        right_wrist_model = 0,
        right_wrist_txd = 0,
        torso_model = 0,
        torso_txd = 0,
        legs_model = 0,
        legs_txd = 0,
        feet_model = 0,
        feet_txd = 0
    }
}

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
        elseif Receiver1GotDelivery == false then
            Receiver1GotDelivery = F_CheckGotDelivery1()
        elseif Receiver2Created == false then
            Receiver2Created = F_SetupReceiver2()
        elseif Receiver2GotDelivery == false then
            Receiver2GotDelivery = F_CheckGotDelivery2()
        elseif Receiver3Created == false then
            Receiver3Created = F_SetupReceiver3()
        elseif Receiver3GotDelivery == false then
            Receiver3GotDelivery = F_CheckGotDelivery3()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_FF_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    LoadPedModels(peds)
    ScenarioPed = PedFindAmbientPedOfModelID(149, 40)
    if ScenarioPed == -1 then
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(149, POIInfo)
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
        F_MakePlayerSafeForNIS(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_IND_PACKGET", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_IND_PACKGET", true) do
            Wait(0)
        end
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        ClothingGivePlayerOutfit("Fast Food", true, true)
        BlipRemove(ScenarioPedBlip)
        if not ClothingIsWearingOutfit("Fast Food") then
            PlayerSetControl(0)
            F_MakePlayerSafeForNIS(true)
            CameraFade(500, 0)
            Wait(501)
            LoadAnimationGroup("Try_Clothes")
            ClothingSetPlayerOutfit("Fast Food")
            ClothingBuildPlayer()
            bPlayerPimped = true
            PlayerSetPosSimple(389.1, 279.9, 8.8)
            PlayerFaceHeadingNow(103)
            CameraSetXYZ(385.51437, 280.40115, 9.351956, 386.4697, 280.26627, 9.614847)
            F_MakePlayerSafeForNIS(false)
            CameraFade(500, 1)
            PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/TryClothesAnims", "Act/Anim/Ambient.act")
            Wait(501)
            SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_DEJECTED", 0, "speech")
            while PedIsPlaying(gPlayer, "/Global/Ambient/MissionSpec/Clothing/TryClothesAnims", true) do
                Wait(0)
            end
            PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/Finished", "Act/Anim/Ambient.act")
            PlayerSetControl(1)
            CameraReturnToPlayer(false)
        end
        DoSocialErrands(true, "AS_FF_OBJCOUNT", deliveryTotal)
        RegisterGlobalEventHandler(7, cbMissionCritical)
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
    local x, y, z = 331.54, 278.08, 6.16
    Receiver1 = PedCreateXYZ(86, x, y, z)
    if PedIsValid(Receiver1) then
        PedMakeMissionChar(Receiver1)
        PedSetPedToTypeAttitude(Receiver1, 13, 2)
        GiveItemToPlayer(521)
        PedSetRequiredGift(Receiver1, 10, false, true)
        Receiver1Blip = AddBlipForChar(Receiver1, 9, 1, 4)
        MissionTimerStart(timeLimit)
        return true
    else
        return false
    end
    return true
end

function F_CheckGotDelivery1()
    if PedIsValid(Receiver1) and PedIsInAreaObject(gPlayer, Receiver1, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
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
        deliveryTotal = deliveryTotal - 1
        DoSocialErrands(true, "AS_FF_OBJCOUNT", deliveryTotal)
        PedWander(Receiver1, 0)
        PedMakeAmbient(Receiver1)
        if Receiver1Blip ~= 0 then
            BlipRemove(Receiver1Blip)
            Receiver1Blip = 0
        end
        local time = MissionTimerGetTimeRemaining() + 30
        MissionTimerStart(time)
        return true
    elseif MissionTimerHasFinished() then
        bTimesUp = true
        return true
    else
        return false
    end
end

function F_SetupReceiver2()
    if bTimesUp then
        return true
    end
    local x, y, z = 448.01, 204.91, 8.52
    Receiver2 = PedCreateXYZ(76, x, y, z)
    if PedIsValid(Receiver2) then
        PedMakeMissionChar(Receiver2)
        PedSetPedToTypeAttitude(Receiver2, 13, 2)
        GiveItemToPlayer(521)
        PedSetRequiredGift(Receiver2, 10, false, true)
        Receiver2Blip = AddBlipForChar(Receiver2, 9, 1, 4)
        return true
    else
        return false
    end
    return true
end

function F_CheckGotDelivery2()
    if PedIsValid(Receiver2) and PedIsInAreaObject(gPlayer, Receiver2, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
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
        deliveryTotal = deliveryTotal - 1
        DoSocialErrands(true, "AD_FF_OBJCOUNT1", deliveryTotal)
        PedWander(Receiver2, 0)
        PedMakeAmbient(Receiver2)
        if Receiver2Blip ~= 0 then
            BlipRemove(Receiver2Blip)
            Receiver2Blip = 0
        end
        local time = MissionTimerGetTimeRemaining() + 30
        MissionTimerStart(time)
        return true
    elseif MissionTimerHasFinished() then
        bTimesUp = true
        return true
    else
        return false
    end
end

function F_SetupReceiver3()
    if bTimesUp then
        return true
    end
    local x, y, z = 353.63, 375.79, 22.38
    Receiver3 = PedCreateXYZ(144, x, y, z)
    if PedIsValid(Receiver3) then
        PedMakeMissionChar(Receiver3)
        PedSetPedToTypeAttitude(Receiver3, 13, 2)
        GiveItemToPlayer(521)
        PedSetRequiredGift(Receiver3, 10, false, true)
        Receiver3Blip = AddBlipForChar(Receiver3, 9, 1, 4)
        return true
    else
        return false
    end
    return true
end

function F_CheckGotDelivery3()
    if PedIsValid(Receiver3) and PedIsInAreaObject(gPlayer, Receiver3, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
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
        PedWander(Receiver3, 0)
        PedMakeAmbient(Receiver3)
        if Receiver3Blip ~= 0 then
            BlipRemove(Receiver3Blip)
            Receiver3Blip = 0
        end
        return true
    elseif MissionTimerHasFinished() then
        bTimesUp = true
        return true
    else
        return false
    end
end

function F_ObjectiveMet()
    if bTimesUp then
        MinigameSetErrandCompletion(18, "AS_FAIL", false, 0, "AS_NO_TIME")
    else
        gFinishedTask = true
        MissionTimerStop()
        DoSocialErrands(false)
        MinigameSetErrandCompletion(18, "AS_COMPLETE", true, 2500)
        ClothingGivePlayerOutfit("Fast Food", true, true)
        shared.gCurrentAmbientScenarioObject.completed = true
        PedSetScenarioObjFlag(ScenarioPed, true)
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(ScenarioPed)
        return true
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
            MinigameSetErrandCompletion(18, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup   ========= Fast Food")
    MissionTimerStop()
    ItemSetCurrentNum(521, 0)
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if PedIsValid(Receiver1) == true then
        PedWander(Receiver1, 0)
        PedMakeAmbient(Receiver1)
        BlipRemove(Receiver1Blip)
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
    RegisterGlobalEventHandler(7, nil)
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end

function F_PlayerClothingBackup()
    ClothingBackup()
end

function F_PlayerClothingRestore()
    ClothingRestore()
    ClothingBuildPlayer()
end

function cbMissionCritical(pedID)
    --print("==== Violence Fail! ===")
    if (not ((pedID ~= Receiver1 or Receiver1GotDelivery) and (pedID ~= Receiver2 or Receiver2GotDelivery)) or pedID == Receiver3 and not Receiver3GotDelivery) and PedGetWhoHitMeLast(pedID) == gPlayer then
        bTimedOut = true
    end
end
