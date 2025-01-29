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
    158,
    150,
    154
}
local bActive = false
local Crazy01 = -1
local Crazy02 = -1
local CrazyBlip1 = 0
local CrazyBlip2 = 0
local bCrazy01Spawned = false
local bCrazy02Spawned = false
local bCrazy01SpotPlayer = false
local bCrazy02SpotPlayer = false
local bCrazy01Caught = false
local bCrazy02Caught = false
local bCrazy01Home = false
local bCrazy02Home = false
local bGoingHome = false
local c1x, c1y, c1z = 5.5189, -331.574, 2.24495
local c2x, c2y, c2z = 130.637, -356.715, 2.75919
local runoffx, runoffy, runoffz = -108.6, -363.7, 4.9
local ObjFlag = false
local MissionScenarioComplete = false

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
    DoSocialErrands(false, "AS_CF_OBJECTIVE")
    OutOfRange = F_PlayerOutOfRange()
    ScenarioPed = PedFindAmbientPedOfModelID(158, 40)
    if ScenarioPed == -1 then
        LoadPedModels(peds)
        local x, y, z = POIGetPosXYZ(POIInfo)
        ScenarioPed = PedCreatePOIPoint(158, POIInfo)
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
        SoundPlayScriptedSpeechEvent(ScenarioPed, "AMBIENT_SCENARIO", 11, "generic", false, true)
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
        DoSocialErrands(true, "AS_CF_OBJECTIVE")
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
    local x, y, z = POIGetPosXYZ(POI._SCENARIO_CRAZYFARM)
    PedMoveToXYZ(ScenarioPed, 0, x, y, z)
    CrazyBlip1 = BlipAddXYZ(c1x, c1y, c1z, 1)
    CrazyBlip2 = BlipAddXYZ(c2x, c2y, c2z, 1)
    return true
end

function F_PlayerIsByCrazy(ped)
    return PlayerIsInAreaObject(ped, 2, 2, 0)
end

function F_CrazyIsHome(ped)
    return PedIsInAreaObject(ScenarioPed, ped, 2, 4, 0)
end

function F_Crazy01()
    if PedIsValid(Crazy01) then
        if bCrazy01Spawned then
            local x, y, z = PedGetPosXYZ(Crazy01)
            if z <= 0 then
                bTimedOut = true
            end
            if not bCrazy01Caught and PedCanSeeObject(Crazy01, gPlayer, 2) and not bCrazy01SpotPlayer then
                PedClearObjectives(Crazy01)
                PedFlee(Crazy01, gPlayer)
                bCrazy01SpotPlayer = true
            end
            if not bCrazy01Caught and F_PlayerIsByCrazy(Crazy01) then
                BlipRemove(CrazyBlip1)
                PedClearObjectives(Crazy01)
                PedStop(Crazy01)
                CrazyBlip1 = AddBlipForChar(Crazy01, 2, 27, 1)
                bCrazy01Caught = true
                if PedHasAllyFollower(gPlayer) then
                    local follower = PedGetAllyFollower(gPlayer)
                    PedRecruitAlly(follower, Crazy01)
                else
                    PedRecruitAlly(gPlayer, Crazy01)
                end
                if not bCrazy02Caught then
                    DoSocialErrands(true, "AS_CF_OTHER")
                else
                    DoSocialErrands(true, "AS_CF_RETURN")
                end
                SoundPlayScriptedSpeechEvent(Crazy01, "M_3_S11", 21, "genric", false, false)
                while SoundSpeechPlaying(Crazy01) do
                    Wait(0)
                end
            end
            if not bCrazy01Home and F_CrazyIsHome(Crazy01) then
                local follower = PedGetAllyFollower(gPlayer)
                if follower == Crazy01 then
                    local followerFollower = PedGetAllyFollower(Crazy01)
                    if PedIsValid(followerFollower) and followerFollower ~= 0 and not F_PedIsDead(followerFollower) then
                        PedDismissAlly(Crazy01, followerFollower)
                        if not bCrazy02Home then
                            PedRecruitAlly(gPlayer, followerFollower)
                        end
                    end
                elseif follower == Crazy02 then
                    local followerFollower = PedGetAllyFollower(Crazy02)
                    if PedIsValid(followerFollower) and not F_PedIsDead(followerFollower) then
                        PedDismissAlly(Crazy02, followerFollower)
                    end
                end
                PedSetStationary(Crazy01, true)
                DoSocialErrands(true, "AS_CF_ACTION")
                if not bCrazy02Caught then
                    Wait(1000)
                    DoSocialErrands(true, "AS_CF_OTHER")
                else
                    Wait(1000)
                    DoSocialErrands(true, "AS_CF_RETURN")
                end
                bCrazy01Home = true
            end
        end
    elseif not bCrazy01Spawned then
        if PlayerIsInAreaXYZ(c1x, c1y, c1z, 30, 0) then
            BlipRemove(CrazyBlip1)
            Crazy01 = PedCreateXYZ(150, c1x, c1y, c1z)
            PlayerSocialDisableActionAgainstPed(Crazy01, 35, true)
            PlayerSocialDisableActionAgainstPed(Crazy01, 23, true)
            PlayerSocialDisableActionAgainstPed(Crazy01, 30, true)
            PlayerSocialDisableActionAgainstPed(Crazy01, 29, true)
            PlayerSocialDisableActionAgainstPed(Crazy01, 28, true)
            PedMakeMissionChar(Crazy01)
            CrazyBlip1 = AddBlipForChar(Crazy01, 2, 1, 4)
            BlipSetFlashing(CrazyBlip1)
            PedSetPedToTypeAttitude(Crazy01, 13, 2)
            PedWander(Crazy01, 0)
            PedClearAllWeapons(Crazy01)
            bCrazy01Spawned = true
        end
    elseif not bCrazy01Home and bCrazy01Spawned then
        bCrazy01Home = true
    end
end

function F_Crazy02()
    if PedIsValid(Crazy02) then
        if bCrazy02Spawned then
            local x, y, z = PedGetPosXYZ(Crazy02)
            if z <= 0 then
                bTimedOut = true
            end
            if not bCrazy02Caught and PedCanSeeObject(Crazy02, gPlayer, 2) and not bCrazy02SpotPlayer then
                PedClearObjectives(Crazy02)
                PedFlee(Crazy02, gPlayer)
                bCrazy02SpotPlayer = true
            end
            if not bCrazy02Caught and F_PlayerIsByCrazy(Crazy02) then
                bCrazy02Caught = true
                PedClearObjectives(Crazy02)
                PedStop(Crazy02)
                BlipRemove(CrazyBlip2)
                CrazyBlip2 = AddBlipForChar(Crazy02, 2, 27, 1)
                if PedHasAllyFollower(gPlayer) then
                    local follower = PedGetAllyFollower(gPlayer)
                    PedRecruitAlly(follower, Crazy02)
                else
                    PedRecruitAlly(gPlayer, Crazy02)
                end
                if not bCrazy01Caught then
                    DoSocialErrands(true, "AS_CF_OTHER")
                else
                    DoSocialErrands(true, "AS_CF_RETURN")
                end
                SoundPlayScriptedSpeechEvent(Crazy02, "M_3_S11", 21, "genric", false, false)
                while SoundSpeechPlaying(Crazy02) do
                    Wait(0)
                end
            end
            if not bCrazy02Home and F_CrazyIsHome(Crazy02) then
                local follower = PedGetAllyFollower(gPlayer)
                if follower == Crazy02 then
                    local followerFollower = PedGetAllyFollower(Crazy02)
                    if PedIsValid(followerFollower) and not F_PedIsDead(followerFollower) and followerFollower ~= 0 then
                        PedDismissAlly(Crazy02, followerFollower)
                        if not bCrazy02Home then
                            PedRecruitAlly(gPlayer, followerFollower)
                        end
                    end
                elseif follower == Crazy01 then
                    local followerFollower = PedGetAllyFollower(Crazy01)
                    if PedIsValid(followerFollower) and not F_PedIsDead(followerFollower) then
                        PedDismissAlly(Crazy01, followerFollower)
                    end
                end
                PedSetStationary(Crazy02, true)
                DoSocialErrands(true, "AS_CF_ACTION")
                if not bCrazy01Caught then
                    Wait(1000)
                    DoSocialErrands(true, "AS_CF_OTHER")
                else
                    Wait(1000)
                    DoSocialErrands(true, "AS_CF_RETURN")
                end
                bCrazy02Home = true
            end
        end
    elseif PlayerIsInAreaXYZ(c2x, c2y, c2z, 30, 0) then
        BlipRemove(CrazyBlip2)
        Crazy02 = PedCreateXYZ(154, c2x, c2y, c2z)
        PlayerSocialDisableActionAgainstPed(Crazy02, 35, true)
        PlayerSocialDisableActionAgainstPed(Crazy02, 23, true)
        PlayerSocialDisableActionAgainstPed(Crazy02, 30, true)
        PlayerSocialDisableActionAgainstPed(Crazy02, 29, true)
        PlayerSocialDisableActionAgainstPed(Crazy02, 28, true)
        PedMakeMissionChar(Crazy02)
        CrazyBlip2 = AddBlipForChar(Crazy02, 2, 1, 4)
        BlipSetFlashing(CrazyBlip2)
        PedSetPedToTypeAttitude(Crazy02, 13, 2)
        PedWander(Crazy02, 0)
        PedClearAllWeapons(Crazy02)
        bCrazy02Spawned = true
    elseif bCrazy02Spawned and not bCrazy02Home then
        bCrazy02Home = true
    end
end

function F_MissionSpecificCheck()
    F_Crazy01()
    F_Crazy02()
    if not bGoingHome and bCrazy01Caught and bCrazy02Caught then
        ScenarioPedBlip = AddBlipForChar(ScenarioPed, 6, 1, 4)
        DoSocialErrands(true, "AS_CF_RETURN")
        bGoingHome = true
    end
    if bCrazy02Spawned and F_PedIsDead(Crazy02) or bCrazy01Spawned and F_PedIsDead(Crazy01) then
        bTimedOut = true
        return false
    end
    if bCrazy01Home and bCrazy02Home then
        return true
    else
        return false
    end
    return false
end

function F_ObjectiveMet()
    DoSocialErrands(false)
    MinigameSetErrandCompletion(10, "AS_COMPLETE", true, 3000)
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
        if bTimedOut and not bActive then
            PedSetTaskNode(ScenarioPed, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        elseif bTimedOut and bActive and not ObjectiveMet and not F_PedIsDead(gPlayer) then
            DoSocialErrands(false)
            MinigameSetErrandCompletion(10, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        if bActive and not bTimedOut and not ObjectiveMet and not F_PedIsDead(gPlayer) and shared.gBusTransition == nil then
            MinigameSetErrandCompletion(10, "AS_FAIL", false, 0, "AS_TRY_AGAIN")
        end
        return false
    end
end

function F_ScenarioCleanup()
    DoSocialErrands(false)
    --print("F_ScenarioCleanup   ========= Crazy Farm")
    if bCrazy02Home and bCrazy01Home then
        AreaSetDoorLockedToPeds(TRIGGER._ASYLUM_FRONT_GATE_DOOR, false)
    end
    if PedIsValid(Crazy01) == true then
        if bCrazy01Home then
            PedSetStationary(Crazy01, false)
            PedClearObjectives(Crazy01)
            PedMoveToXYZ(Crazy01, 1, runoffx, runoffy, runoffz)
        end
        PedMakeAmbient(Crazy01)
        BlipRemove(CrazyBlip1)
    end
    if PedIsValid(Crazy02) == true then
        if bCrazy02Home then
            PedSetStationary(Crazy02, false)
            PedClearObjectives(Crazy02)
            PedMoveToXYZ(Crazy02, 1, runoffx, runoffy, runoffz)
        end
        PedMakeAmbient(Crazy02)
        BlipRemove(CrazyBlip2)
    end
    if PedIsValid(ScenarioPed) == true then
        if bCrazy02Home then
            PedLockTarget(ScenarioPed, Crazy02, 3)
            PedSetFlag(ScenarioPed, 110, false)
            PedFollowFocus(ScenarioPed, Crazy02)
        else
            PedWander(ScenarioPed, 0)
        end
        PedMakeAmbient(ScenarioPed)
        PedClearPOI(ScenarioPed)
        BlipRemove(ScenarioPedBlip)
    end
    if ObjectiveMet == false and shared.gCurrentAmbientScenarioObject ~= nil then
        shared.gCurrentAmbientScenarioObject.time = GetTimer() + 45000
    end
    PedDismissAllAllies(gPlayer)
    shared.gCurrentAmbientScenarioObject = nil
    shared.gCurrentAmbientScenario = nil
end
