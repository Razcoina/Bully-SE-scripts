--[[ Changes to this file:
    * Modified function F_GetAllShots, may require testing
]]

POIInfo = shared.gCurrentAmbientScenario
local ScenarioPed = -1
local ScenarioPedBlip = 0
local ScenarioPedCreated = false
local SetupComplete = false
local OutOfRange = false
local GreetingComplete = false
local DialogComplete = false
local GotAllShots = false
local AcceptScenario = false
local GoalsCreated = false
local ObjectiveMet = false
local bTimedOut = false
local TimeOutTime = 15000
local TimeOutTimer = 0
local peds = { 77 }
local bActive = false
local bAllShots = false
local picsTaken = 0
local gPhotoTargets = false

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
            GoalsCreated = F_CreateGoals()
        elseif GotAllShots == false then
            --print("Did the player get all the shots?")
            GotAllShots = F_GetAllShots()
        elseif ObjectiveMet == false and bAllShots then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    OutOfRange = F_PlayerOutOfRange()
    DoSocialErrands(false, "AS_CP_OBJECTIVE")
    ScenarioPed = PedFindAmbientPedOfModelID(77, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(77, POIInfo)
        if PedIsValid(ScenarioPed) then
            PedMakeAmbient(ScenarioPed, false)
        end
    else
        PedClearAllWeapons(ScenarioPed)
        PedSetPOI(ScenarioPed, POIInfo, true)
        PedEnableGiftRequirement(ScenarioPed, false)
    end
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, true)
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
        --print("[CarniePhotographer.lua] >> PED IS SPEAKING")
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
        PedMakeMissionChar(ScenarioPed)
        DoSocialErrands(true, "AS_CP_OBJCOUNT", picsTaken)
        gPhotoTargets = {
            {
                x = 197.37193,
                y = 465.35828,
                z = 24.210342,
                valid = false,
                taken = false
            },
            {
                x = 166.04045,
                y = 458.79202,
                z = 10.155055,
                valid = false,
                taken = false
            },
            {
                x = 145.87129,
                y = 469.2989,
                z = 9.995712,
                valid = false,
                taken = false
            },
            {
                x = 122.16926,
                y = 434.7251,
                z = 12.463112,
                valid = false,
                taken = false
            }
        }
        for i, target in gPhotoTargets do
            gPhotoTargets[i].blipId = BlipAddXYZ(target.x, target.y, target.z, 1, 4)
        end
        BlipRemove(ScenarioPedBlip)
        if PlayerHasItem(426) then
            --print("PLAYER HAS DIGICAM")
            WeaponSetRangeMultiplier(gPlayer, 426, 4)
        else
            --print("PLAYER NOT HAS DIGICAM")
            WeaponSetRangeMultiplier(gPlayer, 328, 4)
        end
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

function F_CreateGoals()
    PedSetRequiredGift(ScenarioPed, 16, false, true)
    return true
end

local validTarget = false

function F_GetAllShots() -- ! Modified
    validTarget = false
    for i, target in gPhotoTargets do
        if not target.taken and PhotoTargetInFrame(target.x, target.y, target.z) then
            gPhotoTargets[i].valid = true
            validTarget = true
        end
        target.trulyValid = target.valid or target.wasValid -- Added this
        target.wasValid = target.valid                -- Added this
    end
    PhotoSetValid(validTarget)
    photohasbeentaken, wasValid = PhotoHasBeenTaken()
    if photohasbeentaken and wasValid then
        for i, target in gPhotoTargets do
            --[[
            if target.valid == true and not target.taken then
            ]] -- Changed to:
            if target.trulyValid == true and not target.taken then
                target.taken = true
                --print("NEW PICTURE TAKEN")
                if target.blipId then
                    BlipRemove(target.blipId)
                    target.blipId = nil
                end
                picsTaken = picsTaken + 1
                DoSocialErrands(true, "AS_CP_OBJCOUNT", picsTaken)
            end
        end
    end
    for i, target in gPhotoTargets do
        if target.valid == true and not target.taken then
            target.valid = false
        end
    end
    if bAllShots == false then
        if 4 <= picsTaken then
            bAllShots = true
            while not RequestModel(526) do
                Wait(0)
            end
            GiveItemToPlayer(526)
            --print("Player got photos!!")
            ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 1)
            DoSocialErrands(true, "AS_CP_RETURN")
            return true
        end
        return false
    end
    return false
end

function F_ObjectiveMet()
    --print("F_ObjectiveMet")
    --print("Player is in area?", tostring(PedIsInAreaObject(gPlayer, ScenarioPed, 2, 1.5, 0)))
    --print("Player is in area?", tostring(PedGetFlag(gPlayer, 1)))
    if PedIsInAreaObject(gPlayer, ScenarioPed, 2, 1.5, 0) and PedGetFlag(gPlayer, 1) then
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        F_PlayerDismountBike()
        PedLockTarget(gPlayer, ScenarioPed, 3)
        PedLockTarget(ScenarioPed, gPlayer, 3)
        PedSetActionNode(gPlayer, "/Global/Player/Gifts/Errand_BUS_PhotoCash", "Act/Player.act")
        while PedIsPlaying(gPlayer, "/Global/Player/Gifts/Errand_BUS_PhotoCash", true) do
            --print("Ped is playing...")
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
        MinigameSetErrandCompletion(7, "AS_COMPLETE", true, 2000)
        shared.gCurrentAmbientScenarioObject.completed = true
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(ScenarioPed)
        return true
    end
    return false
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
            MinigameSetErrandCompletion(7, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup  ================ Photo Work")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    ItemSetCurrentNum(526, 0)
    if gPhotoTargets then
        for i, target in gPhotoTargets do
            if target.blipId then
                BlipRemove(target.blipId)
                target.blipId = nil
            end
        end
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
    end
    WeaponSetRangeMultiplier(gPlayer, 328, 1)
    WeaponSetRangeMultiplier(gPlayer, 426, 1)
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
