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
local peds = {
    144,
    237,
    78
}
local bActive = false
local gCheater01 = -1
local gCheater01Blip = 0
local gCheater02 = -1
local NearBribe = false
local GotPicture = false
local bNotKissing = false
local bFailDueToCheatersHit = false
local NumTimesPlayedGive = 0
local bSpotted = false
local bFailDueToCheatersHit = false
local bGotPhoto = false
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
    DoSocialErrands(false, "AS_TC_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(237, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(237, POIInfo)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 37, "generic", false, true)
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
        DoSocialErrands(true, "AS_TC_OBJECTIVE")
        bOnMission = true
        PedSetRequiredGift(ScenarioPed, 16, false, true)
        BlipRemove(ScenarioPedBlip)
        cheater01_x, cheater01_y, cheater01_z = 458.03, -200, 3.27
        cheater02_x, cheater02_y, cheater02_z = 457.25, -199.06, 3.27
        gCheater01Blip = BlipAddXYZ(cheater01_x, cheater01_y, cheater01_z, 1)
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
    return true
end

function F_CheckNearBribe()
    if PedIsInAreaXYZ(gPlayer, cheater01_x, cheater01_y, cheater01_z, 55, 0) == true then
        if not PedIsValid(gCheater01) and not PedIsValid(gCheater02) then
            gCheater01 = PedCreateXYZ(144, cheater01_x, cheater01_y, cheater01_z)
            gCheater02 = PedCreateXYZ(78, cheater02_x, cheater02_y, cheater02_z)
            gPhotoTargets = {
                {
                    id = gCheater01,
                    valid = false,
                    taken = false
                },
                {
                    id = gCheater02,
                    valid = false,
                    taken = false
                }
            }
            return false
        elseif PedIsValid(gCheater01) == true and PedIsValid(gCheater02) == true then
            BlipRemove(gCheater01Blip)
            PedMakeMissionChar(gCheater01)
            PedSetPedToTypeAttitude(gCheater01, 13, 2)
            PedLockTarget(gCheater01, gCheater02, 3)
            PedMakeMissionChar(gCheater02)
            PedSetPedToTypeAttitude(gCheater02, 13, 2)
            PedSetEmotionTowardsPed(gCheater01, gCheater02, 7, true)
            PedSetEmotionTowardsPed(gCheater02, gCheater01, 7, true)
            PedSetWantsToSocializeWithPed(gCheater01, gCheater02)
            PedSetWantsToSocializeWithPed(gCheater02, gCheater01)
            gCheater01Blip = AddBlipForChar(gCheater01, 0, 1, 4)
            PedSetActionNode(gCheater01, "/Global/Ambient/MissionSpec/KissMeAdult", "Act/Anim/Ambient.act")
            RegisterGlobalEventHandler(7, cbPedsHit)
            bNotKissing = true
            return true
        else
            return false
        end
    else
        return false
    end
end

local L25_1 = nil

function F_CheckGotPicture()
    if not bFailDueToCheatersHit and not bNotKissing then
        bNotKissing = true
        PedSetActionNode(gCheater01, "/Global/Ambient/MissionSpec/KissMeAdult", "Act/Anim/Ambient.act")
        Wait(10)
    end
    if PlayerIsInAreaObject(gCheater01, 2, 7.5, 0) then
        bSpotted = true
        return true
    end
    if not bFailDueToCheatersHit and bNotKissing and not PedIsPlaying(gCheater01, "/Global/Ambient/MissionSpec/KissMeAdult", true) then
        bNotKissing = false
    end
    local validTarget = false
    for i, target in gPhotoTargets do
        if not target.taken and PhotoTargetInFrame(target.id, 2) and PedIsPlaying(gCheater01, "/Global/Ambient/MissionSpec/KissMeAdult", true) then
            gPhotoTargets[i].valid = true
            validTarget = true
        else
            validTarget = false
        end
        gPhotoTargets[i].trulyValid = gPhotoTargets[i].valid or gPhotoTargets[i].wasValid
        gPhotoTargets[i].wasValid = gPhotoTargets[i].valid
    end
    PhotoSetValid(validTarget)
    local photohasbeentaken, wasValid = PhotoHasBeenTaken()
    if photohasbeentaken and wasValid then
        for i, target in gPhotoTargets do
            if target.trulyValid == true and not target.taken then
                target.taken = true
            end
        end
        if gPhotoTargets[1].trulyValid and gPhotoTargets[2].trulyValid then
            BlipRemove(gCheater01Blip)
            GiveItemToPlayer(526, 1)
            DoSocialErrands(true, "AS_TC_RETURN")
            ScenarioPedBlip = AddBlipForChar(ScenarioPed, 9, 1, 1)
            return true
        end
    end
    for i, target in gPhotoTargets do
        if target.valid == true and not target.taken then
            gPhotoTargets[i].valid = false
        end
    end
    return false
end

function cbPedsHit(pedID)
    if pedID == gCheater01 or pedID == gCheater02 then
        if PedID == gCheater01 and PedGetWhoHitMeLast(gCheater01) ~= gCheater02 then
            bFailDueToCheatersHit = true
        end
        if PedID == gCheater02 and PedGetWhoHitMeLast(gCheater02) ~= gCheater01 then
            bFailDueToCheatersHit = true
        end
    end
end

function F_ObjectiveMet()
    if PedIsInAreaObject(gPlayer, ScenarioPed, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_BUS_PhotoCash", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_BUS_PhotoCash", true) do
            Wait(0)
        end
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(ScenarioPed, -1)
        CameraReturnToPlayer()
        PlayerSetControl(1)
        F_MakePlayerSafeForNIS(false)
        bActive = false
        DoSocialErrands(false)
        MinigameSetErrandCompletion(47, "AS_COMPLETE", true, 2500)
        shared.gCurrentAmbientScenarioObject.completed = true
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 480000
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
    if PedIsValid(ScenarioPed) == true and PedGetFlag(ScenarioPed, 110) == true and PedGetPedToTypeAttitude(ScenarioPed, 13) == 2 and PedIsDead(gPlayer) == false and MissionActive() == false and F_PlayerSleptOnErrand() == false and bTimedOut == false and ObjectiveMet == false and bSpotted == false and shared.gBusTransition == nil and OutOfRange == false then
        if bFailDueToCheatersHit and not bGotPhoto then
            MinigameSetErrandCompletion(47, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
            return false
        end
        return true
    else
        if bTimedOut then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        end
        if bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(47, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup   ========= The Cheat")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemoveFromChar(ScenarioPedBlip)
    end
    if PedIsValid(gCheater01) then
        BlipRemoveFromChar(gCheater01)
        PedMakeAmbient(gCheater01, false)
        PedClearObjectives(gCheater01)
        PedWander(gCheater01, 0)
    end
    if PedIsValid(gCheater02) then
        BlipRemoveFromChar(gCheater02)
        PedMakeAmbient(gCheater02, false)
        PedClearObjectives(gCheater02)
        PedWander(gCheater02, 0)
    end
    RegisterGlobalEventHandler(7, nil)
    ItemSetCurrentNum(526, 0)
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
