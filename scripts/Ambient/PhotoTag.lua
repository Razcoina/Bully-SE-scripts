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
local peds = { 238 }
local bActive = false
local counter = 999
local ObjFlag = false
local MissionScenarioComplete = false
local tblPeds = {
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
}
local tblTaggers = {
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
}
local tblBmodels = {
    85,
    99,
    102,
    145,
    146,
    147
}
local gNewTaggerTimer = 0
local bPhotoGotten = false
local gTagTimer = 0
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
        elseif ObjectiveMet == false then
            ObjectiveMet = F_ObjectiveMet()
        end
        Wait(0)
    end
    F_ScenarioCleanup()
end

function F_ScenarioSetup()
    DoSocialErrands(false, "AS_PT_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(238, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(238, POIInfo)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 30, "generic", false, true)
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
        DoSocialErrands(true, "AS_PT_OBJECTIVE")
        bOnMission = true
        BlipRemove(ScenarioPedBlip)
        bActive = true
        pedbool, tblPeds[1], tblPeds[2], tblPeds[3], tblPeds[4], tblPeds[5], tblPeds[6], tblPeds[7], tblPeds[8], tblPeds[9], tblPeds[10], tblPeds[11], tblPeds[12], tblPeds[13], tblPeds[14], tblPeds[15], tblPeds[16], tblPeds[17], tblPeds[18], tblPeds[19], tblPeds[20], tblPeds[21], tblPeds[22], tblPeds[23], tblPeds[24] = PedFindInAreaObject(gPlayer, 100)
        if pedbool then
            local bIndex = 1
            for p, ped in tblPeds do
                if F_PedIsTagger(ped) then
                    tblTaggers[bIndex] = ped
                    bIndex = bIndex + 1
                    AddBlipForChar(ped, 0, 1, 4)
                end
            end
        end
        gNewTaggerTimer = GetTimer() + 2500
        gTagTimer = GetTimer() + 2000
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
    PedSetRequiredGift(ScenarioPed, 16, false, true)
    return true
end

function F_MissionSpecificCheck()
    F_MaintainTaggerList()
    F_FindTaggers()
    if F_CheckShot() then
        while not RequestModel(526) do
            Wait(0)
        end
        F_RemoveBlips()
        GiveItemToPlayer(526)
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 0, 1, 4)
        DoSocialErrands(true, "AS_PT_RETURN")
        return true
    end
    return false
end

function F_PedIsTagger(ped)
    if PedIsDoingTask(ped, "/Global/AI/Reactions/Criminal/FindTagSpot", true) or PedIsPlaying(ped, "/Global/Tags/PedPropsActions/PerformTag/PedDrawMedTag", true) then
        return true
    else
        for b, tagger in tblTaggers do
            if PedIsValid(tagger) and not PedIsDoingTask(tagger, "/Global/AI/Reactions/Criminal/FindTagSpot", true) and not PedIsPlaying(tagger, "/Global/Tags/PedPropsActions/PerformTag/PedDrawMedTag", true) then
                --print("===== Found a non tagging ped in the list ====", tagger)
                BlipRemoveFromChar(tagger)
                tblTaggers[b] = -1
                break
            end
        end
        return false
    end
end

function F_FindTaggers()
    if GetTimer() >= gTagTimer then
        for b, tagger in tblTaggers do
            if PedIsValid(tagger) and PhotoTargetInFrame(tagger, 2) and PedIsPlaying(tagger, "/Global/Tags/PedPropsActions/PerformTag/PedDrawMedTag", true) then
                BlipRemoveFromChar(tagger)
                AddBlipForChar(tagger, 0, 1, 4)
            end
        end
        gTagTimer = GetTimer() + 2000
    end
end

local L23_1 = false
local L24_1 = false

function F_CheckShot()
    local validTarget = false
    local validTagger = false
    for i, target in tblTaggers do
        if PedIsValid(target) then
            if not validTagger and PhotoTargetInFrame(target, 2) and PedIsPlaying(target, "/Global/Tags/PedPropsActions/PerformTag/PedDrawMedTag", true) then
                validTagger = true
                validTarget = true
                break
            else
                validTarget = false
                validTagger = false
            end
        end
    end
    local L2_2 = validTagger or L24_1
    L24_1 = validTagger
    local L3_2 = validTarget or L23_1
    L23_1 = validTarget
    PhotoSetValid(validTarget)
    local L4_2, L5_2 = PhotoHasBeenTaken()
    if L4_2 and L5_2 and L2_2 and L3_2 then
        return true
    end
    return false
end

function F_RemoveBlips()
    for b, tagger in tblTaggers do
        if PedIsValid(tagger) then
            BlipRemoveFromChar(tagger)
        end
    end
end

function F_MaintainTaggerList()
    pedbool, tblPeds[1], tblPeds[2], tblPeds[3], tblPeds[4], tblPeds[5], tblPeds[6], tblPeds[7], tblPeds[8], tblPeds[9], tblPeds[10], tblPeds[11], tblPeds[12], tblPeds[13], tblPeds[14], tblPeds[15], tblPeds[16], tblPeds[17], tblPeds[18], tblPeds[19], tblPeds[20], tblPeds[21], tblPeds[22], tblPeds[23], tblPeds[24] = PedFindInAreaObject(gPlayer, 100)
    if pedbool then
        local newTagger = -1
        for p, ped in tblPeds do
            local bNotInList = false
            local bInList = false
            if PedIsValid(ped) and F_PedIsTagger(ped) then
                local newTagger = -1
                for b, tagger in tblTaggers do
                    if ped == tagger and ped ~= -1 then
                        bInList = true
                    else
                        bNotInList = true
                    end
                    if bInList then
                        break
                    end
                end
                if bNotInList then
                    newTagger = ped
                    for a, tagger in tblTaggers do
                        if not PedIsValid(tagger) then
                            tblTaggers[a] = -1
                        end
                        if tagger == -1 then
                            --print("==== Adding a new tagger===")
                            tblTaggers[a] = newTagger
                            AddBlipForChar(newTagger, 0, 1, 4)
                            gNewTaggerTimer = GetTimer() + 2500
                            break
                        end
                    end
                end
            end
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
        PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        MinigameSetErrandCompletion(28, "AS_COMPLETE", true, 2500)
        shared.gCurrentAmbientScenarioObject.completed = true
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
            MinigameSetErrandCompletion(28, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup    ========= Photo Tagger")
    if PedIsValid(ScenarioPed) == true then
        PedSetFlag(ScenarioPed, 110, false)
        PedWander(ScenarioPed, 0)
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    ItemSetCurrentNum(526, 0)
    F_RemoveBlips()
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 120000
    end
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
