--[[ Changes to this file:
    * Modified function F_CheckGotPicture, may require testing
]]

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
    83,
    97,
    108
}
local bActive = false
local DirtyCop = -1
local DirtyCopBlip = 0
local MotelOwner = -1
local NearBribe = false
local GotPicture = false
local bSpotted = false
local NumTimesPlayedGive = 0

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
        elseif NearBribe == false then
            NearBribe = F_CheckNearBribe()
        elseif GotPicture == false then
            GotPicture = F_CheckGotPicture()
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_DT_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(83, 40)
    LoadPedModels(peds)
    if ScenarioPed == -1 then
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(83, POIInfo)
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
        PedAddPedToIgnoreList(ScenarioPed, gPlayer)
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
        --print("SCENARIOACCEPTED")
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 3, "generic", false, true)
        PedMakeMissionChar(ScenarioPed)
        DoSocialErrands(true, "AS_DT_OBJECTIVE")
        bOnMission = true
        PedSetRequiredGift(ScenarioPed, 16, false, true)
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
    local dirtyCop_x, dirtyCop_y, dirtyCop_z = 458.03, -200, 3.27
    local motelOwner_x, motelOwner_y, motelOwner_z = 457.25, -199.06, 3.27
    DirtyCop = PedCreateXYZ(97, dirtyCop_x, dirtyCop_y, dirtyCop_z)
    MotelOwner = PedCreateXYZ(108, motelOwner_x, motelOwner_y, motelOwner_z)
    DirtyCopBlip = BlipAddXYZ(dirtyCop_x, dirtyCop_y, dirtyCop_z, 1)
    gPhotoTargets = {
        {
            id = DirtyCop,
            valid = false,
            taken = false
        },
        {
            id = MotelOwner,
            valid = false,
            taken = false
        }
    }
    return true
end

function F_CheckNearBribe()
    local x, y, z = PedGetPosXYZ(DirtyCop)
    if PedIsInAreaXYZ(gPlayer, x, y, z, 30, 0) == true then
        if PedIsValid(DirtyCop) == true and PedIsValid(MotelOwner) == true then
            BlipRemove(DirtyCopBlip)
            PedMakeMissionChar(DirtyCop)
            PedSetPedToTypeAttitude(DirtyCop, 13, 2)
            PedMakeMissionChar(MotelOwner)
            PedSetPedToTypeAttitude(MotelOwner, 13, 2)
            PedFaceObjectNow(MotelOwner, DirtyCop, 2)
            PedFaceObjectNow(DirtyCop, MotelOwner, 2)
            PedSetEmotionTowardsPed(DirtyCop, MotelOwner, 7, true)
            PedSetEmotionTowardsPed(MotelOwner, DirtyCop, 7, true)
            PedSetWantsToSocializeWithPed(DirtyCop, MotelOwner)
            PedSetWantsToSocializeWithPed(MotelOwner, DirtyCop)
            PedLockTarget(MotelOwner, DirtyCop, 3)
            PedLockTarget(DirtyCop, MotelOwner, 3)
            DirtyCopBlip = AddBlipForChar(DirtyCop, 7, 1, 4)
            return true
        else
            return false
        end
    else
        return false
    end
end

function F_CheckGotPicture() -- ! Modified
    if PlayerIsInAreaObject(DirtyCop, 2, 7.5, 0) then
        PedLockTarget(MotelOwner, -1)
        PedLockTarget(DirtyCop, -1)
        bSpotted = true
        return true
    end
    local validTarget = false
    for i, target in gPhotoTargets do
        if not target.taken and PhotoTargetInFrame(target.id, 2) and PedIsPlaying(MotelOwner, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", true) then
            gPhotoTargets[i].valid = true
            validTarget = true
        else
            validTarget = false
        end
        target.trulyValid = target.valid or target.wasValid -- Added this
        target.wasValid = target.valid                -- Added this
    end
    PhotoSetValid(validTarget)
    local photohasbeentaken, wasValid = PhotoHasBeenTaken()
    if photohasbeentaken and wasValid then
        for i, target in gPhotoTargets do
            --[[
            if target.valid == true and not target.taken then
            ]] -- Changed to:
            if target.trulyValid == true and not target.taken then
                target.taken = true
            end
        end
        --[[
        if gPhotoTargets[1].valid and gPhotoTargets[2].valid then
        ]] -- Changed to:
        if gPhotoTargets[1].trulyValid and gPhotoTargets[2].trulyValid then
            BlipRemove(DirtyCopBlip)
            GiveItemToPlayer(526, 1)
            DoSocialErrands(true, "AS_DT_RETURN")
            ScenarioPedBlip = AddBlipForChar(ScenarioPed, 9, 1, 1)
            return true
        end
    end
    for i, target in gPhotoTargets do
        if target.valid == true and not target.taken then
            gPhotoTargets[i].valid = false
        end
    end
    if PedIsPlaying(MotelOwner, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", false) == false then
        NumTimesPlayedGive = NumTimesPlayedGive + 1
        PedSetActionNode(MotelOwner, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
    end
    return false
end

function F_ObjectiveMet()
    if PedIsInAreaObject(gPlayer, ScenarioPed, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_BUS_Detective", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_BUS_Detective", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        bActive = false
        ClothingGivePlayer("SP_GymDisguise", 0, true)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(11, "AS_COMPLETE", true, 2500, "AS_INCOG")
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(ScenarioPed)
        PedSetFlag(ScenarioPed, 110, false)
        shared.gCurrentAmbientScenarioObject.completed = true
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 480000
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
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and bSpotted == false and shared.gBusTransition == nil and OutOfRange == false then
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bSpotted and bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) then
            MinigameSetErrandCompletion(11, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        elseif bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(11, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup   ========= Detective Jimmy")
    if PedIsValid(ScenarioPed) == true then
        BlipRemoveFromChar(ScenarioPed)
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
    end
    ItemSetCurrentNum(526, 0)
    if PedIsValid(DirtyCop) then
        BlipRemoveFromChar(DirtyCop)
        PedMakeAmbient(DirtyCop, false)
        PedClearObjectives(DirtyCop)
        PedWander(DirtyCop, 0)
    end
    if PedIsValid(MotelOwner) then
        BlipRemoveFromChar(MotelOwner)
        PedMakeAmbient(MotelOwner, false)
        PedClearObjectives(MotelOwner)
        PedWander(MotelOwner, 1)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
